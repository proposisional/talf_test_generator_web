<?php

namespace app\controllers;

use Yii;
use yii\web\Controller;
use app\models\database\Question;
use app\components\AiClient;

class QuestionController extends Controller
{

    public function actionCreateQuestion()
    {
        $model = new Question();

        if ($model->load(Yii::$app->request->post())) {
            $model->is_multiple = count($model->correct_choices) > 1;
            if (!$model->validate()) {
                Yii::$app->session->setFlash(
                    'error',
                    'Error: ' . implode('<br>', $model->getFirstErrors())
                );
            } else {
                if ($model->save()) {
                    Yii::$app->session->setFlash('success', 'Pregunta guardada correctamente');
                    return $this->refresh();
                } else {
                    Yii::$app->session->setFlash('error', 'Error del servidor al guardar la pregunta');
                }
            }
        }

        return $this->render('create-question', ['model' => $model]);
    }

    public function actionGenerateQuestion()
    {
        $postAction = Yii::$app->request->post('action');
        if ($postAction === 'save') {
            return $this->actionSaveCurrentQuestion();
        }

        [$generatedQuestion, $debugText] = $this->runGenerateQuestion();

        return $this->render('generate-question', [
            'generatedQuestion' => $generatedQuestion,
            'debugText' => $debugText,
        ]);
    }

    public function actionAskAi()
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
        $q = $_SESSION['question'] ?? null;
        if (!$q) {
            return ['ok' => false, 'error' => 'No hay pregunta en sesión'];
        }

        $title = $q['title'] ?? '';
        $stem = $q['stem'] ?? '';
        $choices = $q['choices'] ?? [];
        $correct = $q['correct_choices'] ?? [];

        $lines = [];
        if ($title)
            $lines[] = "Título: " . $title;
        if ($stem)
            $lines[] = "Enunciado: " . $stem;
        if (is_array($choices) && count($choices)) {
            $lines[] = "Opciones:";
            foreach ($choices as $i => $c) {
                $mark = in_array($i, $correct) ? ' (correcta)' : '';
                $lines[] = sprintf("%d) %s%s", $i + 1, $c, $mark);
            }
        }
        $questionText = implode("\n", $lines);

        $client = new AiClient();
        $result = $client->ask($questionText);
        return $result;
    }

    public function runGenerateQuestion()
    {
        $debug = [];
        $action = Yii::$app->request->post('action');
        $type = Yii::$app->request->post('subject');

        if ($action === 'generate') {
            $debug[] = "Acción: generate";
            switch ($type) {
                case 1:
                    $func = 'unionSets';
                    break;
                case 2:
                    $func = 'diffSets';
                    break;
                case 3:
                    $func = 'intersectSets';
                    break;
                case 4:
                    $func = 'automataString';
                    break;
                case 5:
                    $func = 'isNFA';
                    break;
                case 6:
                    $func = 'turingMachine';
                    break;
                case 7:
                    $func = 'whichRF';
                    break;
                case 300:
                    $func = 'algoritmia';
                    break;
                case 400:
                    $func = 'tlp';
                    break;
                default:
                    $func = 'test';
                    break;
            }

            $eval = "addpath(genpath('" . OCTAVE_SCRIPTS_PATH . "')); 
            cd('" . OCTAVE_SCRIPTS_PATH . "/generators'); 
            jsonQ = " . $func . "();";
            $cmd = OCTAVE_BIN . ' --quiet --no-gui --eval ' . escapeshellarg($eval);
            exec($cmd, $output, $status);

            $outputStr = implode("\n", $output);

            $jsonLine = '';
            foreach (array_reverse($output) as $line) {
                $trim = trim($line);
                if ($trim !== '' && ($trim[0] === '{' || $trim[0] === '[')) {
                    $jsonLine = $trim;
                    break;
                }
            }

            if ($status !== 0 || strpos($outputStr, 'error:') !== false) {
                return [null, implode("\n\n", $debug)];
            }

            $jsonQ = $jsonLine ? json_decode($jsonLine, true) : json_decode($outputStr, true);
            if (!$jsonQ) {
                return [null, implode("\n\n", $debug)];
            }

            $question = new Question();
            $question->title = $jsonQ['title'] ?? '';
            $question->stem = $jsonQ['stem'] ?? '';
            $question->image = $jsonQ['image'] ?? '';
            $question->choices = $jsonQ['choices'] ?? [];
            $question->correct_choices = $jsonQ['correct_choices'] ?? [];
            $question->is_multiple = count($jsonQ['correct_choices']) > 1;
            $question->subject = $jsonQ['subject'] ?? null;

            $debug[] = "JSON decodificado correctamente";

            $session = Yii::$app->session;
            if (!$session->isActive) {
                $session->open();
            }

            $session->set('question', [
                'title' => $question->title,
                'stem' => $question->stem,
                'image' => $question->image,
                'choices' => $question->choices,
                'correct_choices' => $question->correct_choices,
                'subject' => $question->subject,
            ]);

            return [$question, implode("\n\n", $debug)];
        }

        return [null, 'Sin acción'];
    }

    public function actionSaveCurrentQuestion()
    {
        $referrer = Yii::$app->request->referrer;
        $questionData = $_SESSION['question'] ?? null;

        if (!$questionData) {
            Yii::$app->session->setFlash('error', 'Error al guardar: pregunta vacía');
            return $this->redirect($referrer ?: ['question/generate-question']);
        }

        $errors = [];
        if (empty($questionData['stem']))
            $errors[] = 'La descripción (stem) está vacía';
        if (empty($questionData['choices']) || count($questionData['choices']) < 2)
            $errors[] = 'Debe haber al menos dos opciones';
        if (empty($questionData['correct_choices']) || count($questionData['correct_choices']) < 1)
            $errors[] = 'Debe haber al menos una opción correcta';

        if ($errors) {
            Yii::$app->session->setFlash('error', implode('<br>', $errors));
            return $this->redirect($referrer ?: ['question/generate-question']);
        }

        $model = new Question();
        $model->title = $questionData['title'] ?? '';
        $model->stem = $questionData['stem'];
        $model->image = $questionData['image'] ?? '';
        $model->choices = $questionData['choices'];
        $model->correct_choices = $questionData['correct_choices'];
        $model->is_multiple = count($model->correct_choices) > 1;

        if (array_key_exists('subject', $questionData) && $questionData['subject'] !== null && $questionData['subject'] !== '') {
            if (filter_var($questionData['subject'], FILTER_VALIDATE_INT) === false) {
                Yii::$app->session->setFlash('error', 'El campo subject debe ser un entero si se informa.');
                return $this->redirect($referrer ?: ['question/generate-question']);
            }
            $model->subject = (int) $questionData['subject'];
            $model->setAttribute('subject', $model->subject);
        } else {
            $model->subject = null;
            $model->setAttribute('subject', null);
        }

        if (!$model->validate()) {
            Yii::$app->session->setFlash('error', implode('<br>', $model->getFirstErrors()));
            return $this->redirect($referrer ?: ['question/generate-question']);
        }

        if ($model->save())
            Yii::$app->session->setFlash('success', 'Pregunta guardada correctamente');
        else
            Yii::$app->session->setFlash('error', 'Error desconocido al guardar la pregunta');

        return $this->redirect($referrer ?: ['question/generate-question']);
    }
}
