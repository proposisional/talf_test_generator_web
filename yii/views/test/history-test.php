<?php

use yii\bootstrap5\Html;
use yii\web\View;

$this->title = 'Revisión Test #' . Html::encode($test->id);
$this->registerCssFile('@web/css/history-test.css?v=' . time());
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', [
    'position' => View::POS_HEAD
]);
?>
<div class="history-test-container">
    <h1>Revisión Test #<?= Html::encode($test->id) ?></h1>
    <div class="summary">
        <span>Nota: <strong><?= number_format((float) $metrics['score'], 2) ?></strong></span>
        <span>Aciertos: <strong><?= (int) $metrics['correct'] ?></strong></span>
        <span>Fallos: <strong><?= (int) $metrics['wrong'] ?></strong></span>
        <span>Sin responder: <strong><?= (int) $metrics['blank'] ?></strong></span>
        <span>Total de preguntas: <strong><?= (int) $metrics['total'] ?></strong></span>
    </div>
    <div class="questions-review">
        <?php foreach ($questions as $i => $q): ?>
            <?php
            $correctChoices = isset($q['correct_choices']) && is_array($q['correct_choices']) ? array_map('intval', $q['correct_choices']) : [];
            $isMultiple = !empty($q['is_multiple']);
            $selected = isset($answers[$i]) && is_array($answers[$i]) ? array_map('intval', $answers[$i]) : [];
            $isCorrect = $isMultiple
                ? (count(array_diff($selected, $correctChoices)) === 0 && count(array_diff($correctChoices, $selected)) === 0)
                : (count($selected) === 1 && count($correctChoices) === 1 && $selected[0] === $correctChoices[0]);
            ?>
            <div class="question-block <?= $isCorrect ? 'correct' : 'wrong' ?>">
                <h4><?= Html::encode(($i + 1) . '. ' . ($q['title'] ?? '')) ?></h4>
                <?php
                if (!empty($q['image'])) {
                    echo \app\components\QuestionImageRenderer::render((string) $q['image'], [
                        'escapeText' => true,
                        'svgStyle' => 'width:70%; height:auto; max-width:100%; max-height:70vh;',
                        'imgStyle' => 'max-width:70%; height:auto; max-height:70vh;',
                    ]);
                }

                echo \app\components\QuestionImageRenderer::render((string) ($q['stem'] ?? ''), [
                    'escapeText' => true,
                    'wrapperStyle' => 'margin:10px 0; width:100%; max-width:100%; box-sizing:border-box;',
                    'svgStyle' => 'width:70%; height:auto; max-width:100%; max-height:70vh;',
                    'imgStyle' => 'max-width:70%; height:auto; max-height:70vh;',
                ]);
                ?>
                <ul class="choices">
                    <?php foreach (($q['choices'] ?? []) as $k => $choice): ?>
                        <?php $idx = (int) $k;
                        $isRight = in_array($idx, $correctChoices, true);
                        $wasChosen = in_array($idx, $selected, true);
                        $class = $isRight ? 'choice-correct' : ($wasChosen ? 'choice-selected' : ''); ?>
                        <li class="<?= $class ?>">
                            <?php
                            echo \app\components\QuestionImageRenderer::render((string) $choice, [
                                'escapeText' => true,
                                'wrapperTag' => 'span',
                                'textTag' => 'span',
                                'wrapperStyle' => 'display:inline;',
                                'textStyle' => 'display:inline; overflow-wrap:anywhere; word-break:break-word;',
                                'imgStyle' => 'max-width:300px; height:auto; vertical-align:middle;',
                                'svgStyle' => 'width:300px; height:auto; vertical-align:middle; max-width:100%;',
                            ]);
                            ?>
                            <?php if ($isRight): ?> <span class="tag right">&#x2713;</span><?php endif; ?>
                            <?php if (!$isRight && $wasChosen): ?> <span class="tag chosen">X</span><?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                </ul>
            </div>
        <?php endforeach; ?>
    </div>
    <div class="back-link" style="margin-top:20px;">
        <?= Html::a('← Volver al historial', ['test/history'], ['class' => 'btn btn-secondary']) ?>
    </div>
</div>