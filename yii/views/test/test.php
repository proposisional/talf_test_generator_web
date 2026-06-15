<?php

use yii\web\View;

ini_set('display_errors', 1);
error_reporting(E_ALL);

$octave = OCTAVE_BIN;
$scripts_path = OCTAVE_SCRIPTS_PATH;

$this->registerCssFile('@web/css/test.css?v=' . time());
$this->registerJsFile('@web/js/test.js');
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', [
    'position' => View::POS_HEAD
]);

$this->title = 'Examen Tipo Test';
$this->registerLinkTag([
    'rel' => 'stylesheet',
    'href' => 'https://fonts.googleapis.com/css2?family=Computer+Modern+Serif&display=swap',
]);
$this->registerCss("body{font-family:'Computer Modern Serif',serif;margin:20px;}");
?>

<h1>Examen Tipo Test</h1>

<?php
$total = count($questions);
$questionValue = $total > 0 ? 10 / $total : 0;
$eval = isset($evaluation) ? $evaluation : 'classic';
$evalLabel = [
    'classic' => 'Clásico',
    'no_penalty' => 'Sin penalización por fallo',
][$eval] ?? $eval;
?>

<div class="exam-meta" style="margin: 10px 0 20px;">
    <strong>Tipo de evaluación:</strong> <?= htmlspecialchars($evalLabel) ?>
</div>

<form id="testForm" data-evaluation="<?= htmlspecialchars($eval) ?>"
    data-test-id="<?= isset($testId) ? (int) $testId : 0 ?>"
    data-save-url="<?= htmlspecialchars(\yii\helpers\Url::to(['test/save-answers'])) ?>">

    <div class="indicator" id="indicator" class="nav-buttons">
        <button type="button" id="prevBtn" disabled>←</button>
        <?php foreach ($questions as $i => $q): ?>
            <span data-index="<?= $i ?>"><?= $i + 1 ?></span>
        <?php endforeach; ?>
        <button type="button" id="nextBtn">→</button>
    </div>

    <div class="question-box">
        <?php foreach ($questions as $i => $q): ?>
            <div class="question <?= $i === 0 ? 'active' : '' ?>" id="question-<?= $i ?>"
                data-correct="<?= htmlspecialchars(implode(',', $q['correct_choices'])) ?>"
                data-multiple="<?= $q['is_multiple'] ? '1' : '0' ?>">
                <h4><?= htmlspecialchars($q['title']) ?></h4>

                <?php
                if (!empty($q['image'])) {
                    echo \app\components\QuestionImageRenderer::render((string) $q['image'], [
                        'escapeText' => true,
                        'forceLatexText' => true,
                        'svgStyle' => 'width:70%; height:auto; max-width:100%; max-height:70vh; display:block; margin:10px auto;',
                        'imgStyle' => 'max-width:70%; height:auto; max-height:70vh; display:block; margin:10px auto;',
                    ]);
                }
                ?>

                <p><?= htmlspecialchars($q['stem']) ?></p>

                <div class="choices">
                    <?php foreach ($q['choices'] as $key => $option): ?>
                        <label>
                            <input type="<?= $q['is_multiple'] ? 'checkbox' : 'radio' ?>" name="q<?= $i ?>[]"
                                value="<?= $key ?>">
                            <?= htmlspecialchars($option) ?>
                        </label><br>
                    <?php endforeach; ?>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</form>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (window.MathJax && MathJax.typesetPromise) {
            MathJax.typesetPromise();
        }
    });
</script>