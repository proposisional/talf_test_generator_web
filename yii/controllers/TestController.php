<?php

namespace app\controllers;

use Yii;
use yii\db\Expression;
use yii\web\Controller;
use app\models\database\Question;
use app\models\database\Test;
use app\models\database\Answer;

class TestController extends Controller
{
    private function randomOrderExpression(): Expression
    {
        return new Expression(Yii::$app->db->driverName === 'pgsql' ? 'RANDOM()' : 'RAND()');
    }

    public function actionSetup()
    {
        return $this->render('setup');
    }

    public function actionTest()
    {
        $request = Yii::$app->request;
        $numQuestions = (int) $request->get('numQuestions', 10);
        $subjects = $request->get('subjects', []);
        $evaluationRaw = $request->get('evaluation', 'classic');
        $evaluation = $this->normalizeEvaluation($evaluationRaw);

        if (!is_array($subjects)) {
            $subjects = [$subjects];
        }

        $subjects = array_values(array_filter(array_map('intval', $subjects), static function ($s) {
            return $s > 0;
        }));

        if ($numQuestions < 1 || empty($subjects)) {
            return $this->redirect(['test/setup']);
        }

        $nSubjects = count($subjects);
        $base = intdiv($numQuestions, $nSubjects);
        $remainder = $numQuestions % $nSubjects;

        $perSubject = [];
        foreach ($subjects as $idx => $subj) {
            $perSubject[$subj] = $base + ($idx < $remainder ? 1 : 0);
        }

        $questions = [];
        $usedIds = [];

        foreach ($perSubject as $subj => $limit) {
            if ($limit <= 0) {
                continue;
            }

            $query = Question::find()
                ->where(['subject' => $subj])
                ->orderBy($this->randomOrderExpression())
                ->limit($limit);

            $rows = $query->all();

            foreach ($rows as $row) {
                $usedIds[] = (int) $row->id;
                $questions[] = [
                    'title' => $row->title ?? '',
                    'stem' => $row->stem ?? '',
                    'image' => $row->image ?? '',
                    'choices' => $row->choices ?? [],
                    'correct_choices' => $row->correct_choices ?? [],
                    'is_multiple' => (bool) $row->is_multiple,
                    'subject' => $row->subject,
                ];
            }
        }

        $remaining = $numQuestions - count($questions);
        if ($remaining > 0) {
            $extra = Question::find()
                ->where(['subject' => $subjects])
                ->andFilterWhere(['not in', 'id', $usedIds])
                ->orderBy($this->randomOrderExpression())
                ->limit($remaining)
                ->all();

            foreach ($extra as $row) {
                $usedIds[] = (int) $row->id;
                $questions[] = [
                    'title' => $row->title ?? '',
                    'stem' => $row->stem ?? '',
                    'image' => $row->image ?? '',
                    'choices' => $row->choices ?? [],
                    'correct_choices' => $row->correct_choices ?? [],
                    'is_multiple' => (bool) $row->is_multiple,
                    'subject' => $row->subject,
                ];
            }
        }

        $testId = 0;
        try {
            $test = new Test();
            $test->evaluation = $evaluation;
            $test->setQuestionsFromArray($questions);
            if (!$test->save()) {
                Yii::error(['msg' => 'Error guardando Test', 'errors' => $test->errors, 'attributes' => $test->getAttributes()], 'test');
            } else {
                $testId = (int) $test->id;
                Yii::info(['msg' => 'Test creado', 'testId' => $testId, 'count' => count($questions), 'evaluation' => $evaluation], 'test');
            }
        } catch (\Throwable $e) {
            Yii::error(['msg' => 'Excepción creando Test', 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()], 'test');
        }

        return $this->render('test', [
            'questions' => $questions,
            'evaluation' => $evaluation,
            'testId' => $testId,
        ]);
    }

    public function actionResults()
    {
        $request = Yii::$app->request;
        $testId = (int) $request->get('testId', 0);
        $score = (float) $request->get('score', 0);
        $correct = (int) $request->get('correct', 0);
        $wrong = (int) $request->get('wrong', 0);
        $blank = (int) $request->get('blank', 0);
        $total = (int) $request->get('total', 0);
        $evaluation = $request->get('evaluation', 'classic');

        if ($score < 0)
            $score = 0;
        if ($score > 10)
            $score = 10;
        if ($correct < 0)
            $correct = 0;
        if ($wrong < 0)
            $wrong = 0;
        if ($blank < 0)
            $blank = 0;
        if ($total < 0)
            $total = 0;

        return $this->render('results', [
            'testId' => $testId,
            'score' => $score,
            'correct' => $correct,
            'wrong' => $wrong,
            'blank' => $blank,
            'total' => $total,
            'evaluation' => $evaluation,
        ]);
    }

    public function actionRepeat(int $id)
    {
        $original = Test::findOne($id);
        if (!$original) {
            return $this->redirect(['test/setup']);
        }

        $questions = is_array($original->questions) ? $original->questions : [];
        if (empty($questions)) {
            return $this->redirect(['test/setup']);
        }

        $evaluation = $this->normalizeEvaluation($original->evaluation ?? 'classic');

        $newTestId = 0;
        try {
            $clone = new Test();
            $clone->evaluation = $evaluation;
            $clone->setQuestionsFromArray($questions);
            if (!$clone->save()) {
                Yii::error(['msg' => 'Error clonando Test para repetir', 'errors' => $clone->errors, 'attributes' => $clone->getAttributes()], 'test');
            } else {
                $newTestId = (int) $clone->id;
                Yii::info(['msg' => 'Test repetido (clonado)', 'from' => (int) $original->id, 'to' => $newTestId, 'count' => count($questions)], 'test');
            }
        } catch (\Throwable $e) {
            Yii::error(['msg' => 'Excepción clonando Test para repetir', 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()], 'test');
        }

        return $this->render('test', [
            'questions' => $questions,
            'evaluation' => $evaluation,
            'testId' => $newTestId,
        ]);
    }

    public function actionSaveAnswers()
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
        $request = Yii::$app->request;
        if (!$request->isPost) {
            return ['ok' => false, 'error' => 'Invalid method'];
        }
        $data = $request->getBodyParams();
        $testId = isset($data['testId']) ? (int) $data['testId'] : 0;
        $answers = $data['answers'] ?? null;
        if ($testId <= 0 || !is_array($answers)) {
            return ['ok' => false, 'error' => 'Invalid payload'];
        }

        $test = Test::findOne($testId);
        if (!$test) {
            return ['ok' => false, 'error' => 'Test not found'];
        }

        $evaluation = $this->normalizeEvaluation($test->evaluation);

        $userId = null;
        if (!Yii::$app->user->isGuest) {
            $userId = (int) Yii::$app->user->id;
        }
        Yii::info(['msg' => 'Intento guardar respuestas', 'testId' => $testId, 'userId' => $userId, 'answersCount' => is_array($answers) ? count($answers) : null], 'answer');

        try {
            $model = $userId ? Answer::findOne(['test_id' => $testId, 'user_id' => $userId]) : null;
            $isNew = false;
            if (!$model) {
                $model = new Answer();
                $model->test_id = $testId;
                $model->user_id = $userId;
                $isNew = true;
            }
            $model->setAnswers($answers);
            $metrics = $this->computeScoreServer($test->questions, $answers, $evaluation);
            $model->score = $metrics['score'];
            if ($model->save()) {
                Yii::info([
                    'msg' => 'Answer guardada',
                    'id' => $model->id,
                    'new' => $isNew,
                    'userId' => $userId,
                    'score' => $model->score,
                    'testId' => $testId,
                    'countAnswers' => count($answers),
                ], 'answer');
                return [
                    'ok' => true,
                    'id' => (int) $model->id,
                    'score' => $metrics['score'],
                    'correct' => $metrics['correct'],
                    'wrong' => $metrics['wrong'],
                    'blank' => $metrics['blank'],
                    'total' => $metrics['total'],
                    'evaluation' => $evaluation,
                    'new' => $isNew,
                ];
            }
            Yii::error(['msg' => 'Fallo guardando Answer', 'errors' => $model->errors, 'attributes' => $model->getAttributes()], 'answer');
            Yii::$app->response->setStatusCode(400);
            return ['ok' => false, 'error' => 'Save failed', 'details' => $model->errors];
        } catch (\Throwable $e) {
            Yii::error(['msg' => 'Excepción guardando Answer', 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()], 'answer');
            Yii::$app->response->setStatusCode(500);
            return ['ok' => false, 'error' => 'Exception', 'details' => $e->getMessage()];
        }
    }


    public function actionHistory()
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['site/login']);
        }

        $userId = (int) Yii::$app->user->id;
        $answers = Answer::find()
            ->where(['user_id' => $userId])
            ->orderBy(['date_created' => SORT_DESC])
            ->all();

        $items = [];
        foreach ($answers as $ans) {
            $test = $ans->test;
            if (!$test)
                continue;
            $evaluation = $this->normalizeEvaluation($test->evaluation ?? 'classic');
            $questions = is_array($test->questions) ? $test->questions : [];
            $metrics = ['score' => $ans->score, 'correct' => null, 'wrong' => null, 'blank' => null, 'total' => is_array($questions) ? count($questions) : 0];
            if ($metrics['score'] === null || $metrics['score'] === '') {
                $metrics = $this->computeScoreServer($questions, $ans->answers ?? [], $evaluation);
            }

            $items[] = [
                'answer_id' => (int) $ans->id,
                'test_id' => (int) $test->id,
                'name' => 'Test #' . (int) $test->id,
                'date' => $ans->date_created ?? $test->date_created ?? null,
                'score' => $metrics['score'],
                'total' => $metrics['total'],
                'correct' => $metrics['correct'],
            ];
        }

        return $this->render('history', [
            'items' => $items,
        ]);
    }


    public function actionHistoryTest(int $id)
    {
        if (Yii::$app->user->isGuest) {
            return $this->redirect(['site/login']);
        }
        $answer = Answer::findOne(['id' => $id, 'user_id' => Yii::$app->user->id]);
        if (!$answer) {
            throw new \yii\web\NotFoundHttpException('Intento no encontrado.');
        }
        $test = $answer->test;
        if (!$test) {
            throw new \yii\web\NotFoundHttpException('Test no encontrado.');
        }

        $questions = is_array($test->questions) ? $test->questions : [];
        $answers = is_array($answer->answers) ? $answer->answers : [];
        $evaluation = $this->normalizeEvaluation($test->evaluation ?? 'classic');
        $metrics = $this->computeScoreServer($questions, $answers, $evaluation);

        return $this->render('history-test', [
            'test' => $test,
            'answer' => $answer,
            'questions' => $questions,
            'answers' => $answers,
            'metrics' => $metrics,
        ]);
    }


    private function normalizeEvaluation(string $evaluation): string
    {
        $map = [
            'classic_33' => 'classic',
            'classic' => 'classic',
            'no_penalty' => 'no_penalty',
            'all_or_nothing' => 'no_penalty',
            'partial_credit' => 'partial_credit',
        ];
        return $map[$evaluation] ?? 'classic';
    }


    private function computeScoreServer(array $questionsSnapshot, array $answersPayload, string $evaluation): array
    {
        $total = count($questionsSnapshot);
        if ($total === 0) {
            return ['score' => 0.0, 'correct' => 0, 'wrong' => 0, 'blank' => 0, 'total' => 0];
        }
        $indexedAnswers = [];
        for ($i = 0; $i < $total; $i++) {
            $row = $answersPayload[$i] ?? [];
            $indexedAnswers[$i] = is_array($row) ? array_map('intval', $row) : [];
        }

        $per = 10 / $total;
        $correct = 0;
        $wrong = 0;
        $blank = 0;
        $score = 0.0;

        for ($i = 0; $i < $total; $i++) {
            $q = $questionsSnapshot[$i] ?? [];
            $correctChoices = isset($q['correct_choices']) && is_array($q['correct_choices']) ? array_map('intval', $q['correct_choices']) : [];
            $isMultiple = !empty($q['is_multiple']);
            $chosen = $indexedAnswers[$i] ?? [];
            $isBlank = count($chosen) === 0;
            $isCorrect = false;

            if ($isMultiple) {
                $isCorrect = $this->arraysEqualSorted($chosen, $correctChoices);
            } else {
                $isCorrect = count($chosen) === 1 && count($correctChoices) === 1 && $chosen[0] === $correctChoices[0];
            }

            if ($isBlank) {
                $blank++;
            } elseif ($isCorrect) {
                $correct++;
                $score += $per;
            } else {
                $wrong++;
                if ($evaluation === 'classic') {
                    $score -= $per * 0.33;
                } elseif ($evaluation === 'partial_credit') {
                    if ($isMultiple && count($correctChoices) > 0) {
                        $hits = 0;
                        foreach ($chosen as $val) {
                            if (in_array($val, $correctChoices, true)) {
                                $hits++;
                            }
                        }
                        $frac = max(0.0, min(1.0, $hits / max(1, count($correctChoices))));
                        $score += $per * $frac;
                    }
                }
            }
        }

        if ($score < 0)
            $score = 0.0;
        if ($score > 10)
            $score = 10.0;
        $score = round($score, 2);

        return [
            'score' => $score,
            'correct' => $correct,
            'wrong' => $wrong,
            'blank' => $blank,
            'total' => $total,
        ];
    }

    private function arraysEqualSorted(array $a, array $b): bool
    {
        if (count($a) !== count($b))
            return false;
        sort($a);
        sort($b);
        for ($i = 0, $len = count($a); $i < $len; $i++) {
            if ($a[$i] !== $b[$i])
                return false;
        }
        return true;
    }
}