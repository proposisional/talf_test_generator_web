<?php

use yii\helpers\Url;

ini_set('display_errors', 1);
error_reporting(E_ALL);

$this->registerCssFile('@web/css/results.css?v=' . time());
$this->registerJsFile('@web/js/results.js');

$eval = $evaluation ?? 'classic';
$testId = isset($testId) ? (int) $testId : 0;
$evalLabel = [
    'classic' => 'Clásica (-33% por pregunta errada)',
    'no_penalty' => 'Sin penalización por fallo',
][$eval] ?? $eval;
?>

<div class="result-container">
    <h2>Resultado del examen</h2>
    <div class="result-metrics">
        <span><strong>Evaluación:</strong> <?= htmlspecialchars($evalLabel) ?></span>
        <span><strong>Nota:</strong> <?= number_format((float) $score, 2) ?> / 10</span>
    </div>
    <div class="result-metrics">
        <span><strong>Total preguntas:</strong> <?= (int) $total ?></span>
        <span><strong>Aciertos:</strong> <?= (int) $correct ?></span>
        <span><strong>Fallos:</strong> <?= (int) $wrong ?></span>
        <span><strong>Sin responder:</strong> <?= (int) $blank ?></span>
    </div>

    <div class="result-actions">
        <a class="btn-primary" href="<?= Url::to(['site/index']) ?>">Volver al inicio</a>
    </div>
</div>