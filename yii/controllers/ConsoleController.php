<?php

namespace app\controllers;

use Yii;
use yii\web\Controller;
use yii\helpers\HtmlPurifier;
use app\models\database\Question;
use app\components\AiClient;

class ConsoleController extends Controller
{
    public function actionImportQuestion()
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;

        $session = Yii::$app->session;
        if (!$session->isActive) {
            $session->open();
        }

        $payload = Yii::$app->request->post('question');
        if (!is_array($payload)) {
            return ['ok' => false, 'error' => 'Payload inválido'];
        }

        $normalized = $this->normalizeImportedQuestion($payload);
        $_SESSION['question'] = $normalized;

        return [
            'ok' => true,
            'question' => $normalized,
            'questionHtml' => $this->renderPartial('_talf_question_preview', ['question' => $normalized]),
        ];
    }

    public function actionTalfConsole()
    {
        $session = Yii::$app->session;
        if (!$session->isActive) {
            $session->open();
        }
        if (!isset($_SESSION['talf_console_initialized'])) {
            unset($_SESSION['question']);
            $_SESSION['talf_console_initialized'] = true;
        }

        return $this->render('talf-console');
    }

    public function actionTalfExecute()
    {
        $commandFull = Yii::$app->request->post('command');
        $response = ['output' => '', 'questionHtml' => '', 'question' => null];

        if (!$commandFull) {
            $response['output'] = 'Comando vacío';
            $response['question'] = $_SESSION['question'] ?? $this->createEmptyQuestion();
            return $this->asJson($response);
        }

        $commandFull = trim($commandFull);
        $parts = explode(' ', $commandFull, 2);
        $cmdName = $parts[0];
        $cmdArg = $parts[1] ?? '';
        $_SESSION['question'] ??= $this->createEmptyQuestion();

        // -------------------- PHP COMMANDS --------------------
        $phpCommands = ['help', 'new', 'title', 'stem', 'image', 'addChoice', 'delChoice', 'correct', 'false', 'subject'];

        if (in_array($cmdName, $phpCommands)) {
            $response = $this->processCommand($cmdName, $cmdArg);
            $response['questionHtml'] = $this->renderPartial('_talf_question_preview', ['question' => $_SESSION['question']]);
            $response['question'] = $_SESSION['question'];
            return $this->asJson($response);
        }

        // -------------------- OCTAVE COMMANDS --------------------
        $result = $this->executeOctaveFunction(OCTAVE_BIN, $cmdName, $cmdArg);
        if ($result !== null) {
            $current = is_array($_SESSION['question'] ?? null) ? $_SESSION['question'] : [];
            $merged = $this->mergeQuestionPreservingNonEmpty($current, $result);
            $_SESSION['question'] = $merged;
            $response['questionHtml'] = $this->renderPartial('_talf_question_preview', ['question' => $merged]);
            $response['output'] = "Comando Octave ejecutado: '$cmdName'";
            $response['question'] = $merged;
            return $this->asJson($response);
        }

        $octaveScriptRoot = OCTAVE_SCRIPTS_PATH . DIRECTORY_SEPARATOR . $cmdName . OCTAVE_SCRIPT_EXTENSION;
        $octaveScriptGen = OCTAVE_SCRIPTS_PATH . DIRECTORY_SEPARATOR . 'generators' . DIRECTORY_SEPARATOR . $cmdName . OCTAVE_SCRIPT_EXTENSION;
        $scriptPath = null;
        if (file_exists($octaveScriptRoot))
            $scriptPath = $octaveScriptRoot;
        elseif (file_exists($octaveScriptGen))
            $scriptPath = $octaveScriptGen;

        if ($scriptPath) {
            $result = $this->executeOctaveScript(OCTAVE_BIN, $scriptPath);
            if ($result !== null) {
                $current = is_array($_SESSION['question'] ?? null) ? $_SESSION['question'] : [];
                $merged = $this->mergeQuestionPreservingNonEmpty($current, $result);
                $_SESSION['question'] = $merged;
                $response['questionHtml'] = $this->renderPartial('_talf_question_preview', ['question' => $merged]);
                $response['output'] = "Script Octave ejecutado: '$cmdName'";
                $response['question'] = $merged;
                return $this->asJson($response);
            }
        }

        // -------------------- UNKNOWN COMMAND --------------------
        $response['output'] = "No existe el comando: '$cmdName'";
        $response['question'] = $_SESSION['question'] ?? $this->createEmptyQuestion();
        return $this->asJson($response);
    }

    public function actionAskAi()
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
        $q = $_SESSION['question'] ?? null;
        if (!$q) {
            Yii::error('AskAI error: pregunta vacía en sesión', __METHOD__);
            return ['ok' => false, 'error' => 'No hay pregunta en sesión'];
        }

        $payload = [
            'title' => (string) ($q['title'] ?? ''),
            'stem' => (string) ($q['stem'] ?? ''),
            'choices' => is_array($q['choices'] ?? null) ? array_values($q['choices']) : [],
            'correct_choices' => is_array($q['correct_choices'] ?? null) ? array_values($q['correct_choices']) : [],
            'subject' => $q['subject'] ?? null,
        ];

        $jsonQuestion = json_encode(
            $payload,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT
        );

        $questionText = "Devuelve tu respuesta SOLO en HTML válido (sin Markdown). "
            . "Usa etiquetas como <p>, <ul>, <li>, <strong>, <em>, <code>, <pre>, <br>. "
            . "No incluyas <script>, <style>, iframes ni imágenes. "
            . "Explica brevemente la solución y, si aplica, justifica por qué las opciones correctas lo son."
            . "\n\nPregunta (JSON):\n" . $jsonQuestion;

        Yii::info('AskAI sending question JSON: ' . substr($jsonQuestion ?: '', 0, 1000), __METHOD__);
        $client = new AiClient();
        $result = $client->ask($questionText);

        if (isset($result['ok']) && $result['ok'] && isset($result['text']) && is_string($result['text'])) {
            $html = trim($result['text']);

            if (preg_match('/^```(?:html)?\s*(.*?)\s*```$/is', $html, $m)) {
                $html = trim($m[1]);
            }

            if (strpos($html, '<') === false && (strpos($html, '&lt;') !== false || strpos($html, '&#60;') !== false)) {
                $html = html_entity_decode($html, ENT_QUOTES | ENT_HTML5, 'UTF-8');
            }

            $result['text'] = HtmlPurifier::process(
                $html,
                [
                    'HTML.Allowed' => 'p,br,ul,ol,li,strong,em,code,pre,h1,h2,h3,h4,blockquote',
                    'AutoFormat.AutoParagraph' => true,
                    'AutoFormat.RemoveEmpty' => true,
                ]
            );
        }

        if (!$result['ok']) {
            Yii::error('AskAI failed: ' . ($result['error'] ?? 'desconocido'), __METHOD__);
        }
        return $result;
    }

    // -------------------------------------------------------------
    // CREATE / UPDATE QUESTION IN SESSION
    // -------------------------------------------------------------
    protected function createEmptyQuestion()
    {
        return [
            'title' => '',
            'stem' => '',
            'image' => '',
            'choices' => [],
            'correct_choices' => [],
            'subject' => null,
        ];
    }

    private function normalizeImportedQuestion(array $incoming): array
    {
        $base = $this->createEmptyQuestion();

        $base['title'] = is_string($incoming['title'] ?? null) ? (string) $incoming['title'] : '';
        $base['stem'] = is_string($incoming['stem'] ?? null) ? (string) $incoming['stem'] : '';
        $base['image'] = is_string($incoming['image'] ?? null) ? (string) $incoming['image'] : '';

        $choices = $incoming['choices'] ?? [];
        if (is_array($choices)) {
            $base['choices'] = array_values(array_map(
                fn($v) => is_string($v) ? $v : '',
                $choices
            ));
        }

        $correct = $incoming['correct_choices'] ?? [];
        $base['correct_choices'] = [];
        if (is_array($correct)) {
            foreach ($correct as $v) {
                if (is_int($v)) {
                    $base['correct_choices'][] = $v;
                } elseif (is_string($v) && ctype_digit($v)) {
                    $base['correct_choices'][] = (int) $v;
                }
            }
        }
        // Filtrar índices fuera de rango
        $max = count($base['choices']);
        $base['correct_choices'] = array_values(array_filter(
            $base['correct_choices'],
            fn($n) => is_int($n) && $n >= 0 && $n < $max
        ));

        $subject = $incoming['subject'] ?? null;
        if (is_int($subject)) {
            $base['subject'] = $subject;
        } elseif (is_float($subject)) {
            $base['subject'] = (int) $subject;
        } elseif (is_string($subject) && is_numeric($subject)) {
            $base['subject'] = (int) $subject;
        } else {
            $base['subject'] = null;
        }

        return $base;
    }

    protected function mergeQuestionPreservingNonEmpty(array $current, array $incoming): array
    {
        $merged = array_merge($this->createEmptyQuestion(), $current);

        foreach ($incoming as $key => $value) {
            if ($this->isEmptyForQuestionMerge($value)) {
                continue;
            }
            $merged[$key] = $value;
        }

        return $merged;
    }

    private function isEmptyForQuestionMerge($value): bool
    {
        if ($value === null) {
            return true;
        }

        if (is_string($value)) {
            return trim($value) === '';
        }

        if (is_array($value)) {
            return count($value) === 0;
        }

        return false;
    }


    protected function processCommand(string $cmdName, string $cmdArg): array
    {
        $response = ['output' => '', 'questionHtml' => ''];

        switch ($cmdName) {
            case 'new':
                $response['output'] = $this->cmdNew()['output'];
                break;
            case 'title':
                $response['output'] = $this->cmdTitle($cmdArg)['output'];
                break;
            case 'stem':
                $response['output'] = $this->cmdStem($cmdArg)['output'];
                break;
            case 'image':
                $response['output'] = $this->cmdImage($cmdArg)['output'];
                break;
            case 'addChoice':
                $response['output'] = $this->cmdAddChoice($cmdArg)['output'];
                break;
            case 'delChoice':
                $response['output'] = $this->cmdDelChoice($cmdArg)['output'];
                break;
            case 'correct':
                $response['output'] = $this->cmdCorrect($cmdArg)['output'];
                break;
            case 'false':
                $response['output'] = $this->cmdFalse($cmdArg)['output'];
                break;
            case 'subject':
                $response['output'] = $this->cmdSubject($cmdArg)['output'];
                break;
            default:
                $response['output'] = "No existe el comando '$cmdName'";
        }

        return $response;
    }

    // -------------------------------------------------------------
    // PHP COMMAND IMPLEMENTATION
    // -------------------------------------------------------------
    protected function cmdNew(): array
    {
        $_SESSION['question'] = $this->createEmptyQuestion();
        return ['output' => 'Nueva pregunta creada.'];
    }

    protected function cmdTitle(string $arg): array
    {
        if (!preg_match('/^["\'].*["\']$/', trim($arg))) {
            return ['output' => "Error: el argumento de 'title' debe ir entre comillas simples o dobles."];
        }
        $_SESSION['question']['title'] = trim($arg, "\"'");
        return ['output' => "Título actualizado."];
    }

    protected function cmdStem(string $arg): array
    {
        if (!preg_match('/^["\'].*["\']$/', trim($arg))) {
            return ['output' => "Error: el argumento de 'stem' debe ir entre comillas simples o dobles."];
        }
        $_SESSION['question']['stem'] = trim($arg, "\"'");
        return ['output' => "Enunciado actualizado."];
    }

    protected function cmdImage(string $arg): array
    {
        if (!preg_match('/^["\'].*["\']$/', trim($arg))) {
            return ['output' => "Error: el argumento de 'image' debe ir entre comillas simples o dobles."];
        }
        $_SESSION['question']['image'] = trim($arg, "\"'");
        return ['output' => "Imagen actualizada."];
    }

    protected function cmdAddChoice(string $arg): array
    {
        $question = $_SESSION['question'];
        if (!preg_match('/^["\'].*["\'](\s+\d+)?$/', trim($arg))) {
            return ['output' => "Error: formato incorrecto. Ejemplo: addChoice 'Opción' 1"];
        }
        preg_match('/^["\'](.*)["\']/', $arg, $matches);
        $text = $matches[1];
        $remaining = trim(str_replace($matches[0], '', $arg));
        $pos = is_numeric($remaining) ? (int) $remaining : null;
        if ($pos === null || $pos >= count($question['choices'])) {
            $question['choices'][] = $text;
        } else {
            $question['choices'][$pos] = $text;
        }
        $_SESSION['question'] = $question;
        return ['output' => "Opción agregada o modificada."];
    }

    protected function cmdDelChoice(string $arg): array
    {
        $question = $_SESSION['question'];
        $pos = (int) $arg;
        if (isset($question['choices'][$pos])) {
            array_splice($question['choices'], $pos, 1);
            $question['correct_choices'] = array_values(array_filter($question['correct_choices'], fn($i) => $i !== $pos));
            foreach ($question['correct_choices'] as &$i)
                if ($i > $pos)
                    $i--;
            $_SESSION['question'] = $question;
            return ['output' => "Opción eliminada."];
        }
        return ['output' => "No existe la opción en la posición $pos."];
    }

    protected function cmdCorrect(string $arg): array
    {
        $question = $_SESSION['question'];
        $index = (int) $arg;

        // Verifica que la opción exista
        if ($index < 1 || $index > count($question['choices'])) {
            return ['output' => "Error: la opción $index no existe. Solo hay " . count($question['choices']) . " opciones."];
        }

        // Evita duplicados
        if (!in_array($index, $question['correct_choices'])) {
            $question['correct_choices'][] = $index;
        }

        $_SESSION['question'] = $question;
        return ['output' => "Opción marcada como correcta."];
    }


    protected function cmdFalse(string $arg): array
    {
        $question = $_SESSION['question'];
        $index = (int) $arg;

        $question['correct_choices'] = array_values(array_filter(
            $question['correct_choices'],
            fn($i) => $i !== $index
        ));

        $_SESSION['question'] = $question;
        return ['output' => "Opción marcada como falsa."];
    }

    protected function cmdSubject(string $arg): array
    {
        $question = $_SESSION['question'];

        if (trim($arg) === '') {
            $current = $question['subject'] ?? null;
            if ($current === null)
                return ['output' => "No hay tema asignado."];
            return ['output' => "Tema actual: {$current}"];
        }

        if (!preg_match('/^\d+$/', trim($arg))) {
            return ['output' => "Error: subject está relacionado a los temas de la asignatura TALF, ingresa un número del 1 al 14."];
        }

        $num = (int) $arg;
        if ($num <= 0 || $num > 14) {
            return ['output' => "Error: el valor de 'subject' debe estar entre 1 y 14."];
        }

        $question['subject'] = $num;
        $_SESSION['question'] = $question;

        return ['output' => "Tema establecido en {$num}."];
    }


    // -------------------------------------------------------------
    // OCTAVE INTEGRATION
    // -------------------------------------------------------------
    private function executeOctaveScript(string $octave, string $scriptPath)
    {
        $cmd = "\"$octave\" --no-gui --quiet \"$scriptPath\"";
        exec($cmd, $output, $status);

        $outputStr = implode("\n", $output);
        if ($status !== 0 || strpos($outputStr, 'error:') !== false) {
            Yii::error("Octave execution error: $outputStr", __METHOD__);
            return null;
        }

        $jsonQ = json_decode($outputStr, true);
        if (!$jsonQ)
            return null;

        return [
            'title' => $jsonQ['title'] ?? '',
            'stem' => $jsonQ['stem'] ?? '',
            'image' => $jsonQ['image'] ?? '',
            'choices' => $jsonQ['choices'] ?? [],
            'correct_choices' => $jsonQ['correct_choices'] ?? [],
            'subject' => $jsonQ['subject'] ?? null,
        ];
    }

    private function executeOctaveFunction(string $octave, string $funcName, string $cmdArg = '')
    {
        $octaveRoot = OCTAVE_SCRIPTS_PATH;
        $generatorsPath = OCTAVE_SCRIPTS_PATH . DIRECTORY_SEPARATOR . 'generators';

        $args = $this->parseOctaveArgs($cmdArg);
        $argExprParts = [];
        foreach ($args as $arg) {
            $arg = trim($arg);
            if ($arg === '') {
                $argExprParts[] = "''";
                continue;
            }

            if (preg_match('/^-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$/', $arg)) {
                $argExprParts[] = $arg;
                continue;
            }

            $argExprParts[] = "'" . str_replace("'", "''", $arg) . "'";
        }

        $call = !empty($argExprParts)
            ? ($funcName . '(' . implode(',', $argExprParts) . ')')
            : ($funcName . '()');
        $eval = "addpath(genpath('" . $octaveRoot . "')); cd('" . $generatorsPath . "'); jsonQ = " . $call . ";";
        $cmd = "\"$octave\" --no-gui --quiet --eval " . escapeshellarg($eval);
        exec($cmd, $output, $status);

        $outputStr = implode("\n", $output);
        if ($status !== 0 || strpos($outputStr, 'error:') !== false) {
            return null;
        }

        // Buscar la última línea con JSON
        $jsonLine = '';
        foreach (array_reverse($output) as $line) {
            $trim = trim($line);
            if ($trim !== '' && ($trim[0] === '{' || $trim[0] === '[')) {
                $jsonLine = $trim;
                break;
            }
        }

        $jsonQ = $jsonLine ? json_decode($jsonLine, true) : json_decode($outputStr, true);
        if (!$jsonQ)
            return null;

        return [
            'title' => $jsonQ['title'] ?? '',
            'stem' => $jsonQ['stem'] ?? '',
            'image' => $jsonQ['image'] ?? '',
            'choices' => $jsonQ['choices'] ?? [],
            'correct_choices' => $jsonQ['correct_choices'] ?? [],
            'subject' => $jsonQ['subject'] ?? null,
        ];
    }

    private function parseOctaveArgs(string $cmdArg): array
    {
        $cmdArg = trim($cmdArg);
        if ($cmdArg === '') {
            return [];
        }

        $tokens = [];
        preg_match_all('/"((?:\\\\.|[^"\\\\])*)"|\'((?:\'\'|[^\'])*)\'|([^\s]+)/', $cmdArg, $matches, PREG_SET_ORDER);
        foreach ($matches as $m) {
            if ($m[1] !== '') {
                $tokens[] = stripcslashes($m[1]);
            } elseif ($m[2] !== '') {
                $tokens[] = str_replace("''", "'", $m[2]);
            } else {
                $tokens[] = $m[3];
            }
        }

        return $tokens;
    }

    // -------------------------------------------------------------
    // SAVE QUESTION
    // -------------------------------------------------------------
    public function actionSaveCurrentQuestion()
    {
        $questionData = $_SESSION['question'] ?? null;
        if (!$questionData) {
            Yii::$app->session->setFlash('error', 'Error al guardar: pregunta vacía');
            return $this->redirect(['talf-console']);
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
            return $this->redirect(['talf-console']);
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
                return $this->redirect(['talf-console']);
            }
            $model->subject = (int) $questionData['subject'];
            $model->setAttribute('subject', $model->subject);
        } else {
            $model->subject = null;
            $model->setAttribute('subject', null);
        }

        if (!$model->validate()) {
            Yii::$app->session->setFlash('error', implode('<br>', $model->getFirstErrors()));
            return $this->redirect(['talf-console']);
        }


        if ($model->save())
            Yii::$app->session->setFlash('success', 'Pregunta guardada correctamente');
        else
            Yii::$app->session->setFlash('error', 'Error desconocido al guardar la pregunta');

        return $this->redirect(['talf-console']);
    }
}
