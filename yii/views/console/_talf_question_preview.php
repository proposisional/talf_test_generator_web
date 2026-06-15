<?php

$choices = $question['choices'] ?? [];
$correctChoices = $question['correct_choices'] ?? [];
$isMultiple = count($correctChoices) > 1;

$imgHtml = \app\components\QuestionImageRenderer::render(
    isset($question['image']) ? (string) $question['image'] : '',
    [
        'escapeText' => false,
        'svgStyle' => 'width:70%; height:auto; max-width:100%; max-height:100%;',
        'imgStyle' => 'max-width:70%; height:auto; max-height:100%;',
    ]
);
?>

<div id="preview-content"
    style="white-space:normal; overflow-wrap:anywhere; word-break:break-word; max-width:100%; box-sizing:border-box;">
    <?php if ($question): ?>
        <h2><?= $question['title'] ?? '' ?></h2>
        <p><?= $question['stem'] ?? '' ?></p>

        <?= $imgHtml ?>

        <ul style="list-style:none; padding-left:0;">
            <?php foreach ($choices as $i => $text): ?>
                <li
                    style="<?= in_array($i, $correctChoices) ? 'background-color: #d4edda; padding: 5px; border-radius: 4px;' : '' ?>">
                    <label>
                        <input type="<?= $isMultiple ? 'checkbox' : 'radio' ?>" disabled <?= in_array($i, $correctChoices) ? 'checked' : '' ?> />
                                <?= $text ?>
                    </label>
                </li>
            <?php endforeach; ?>
        </ul>

    <?php else: ?>
        <p><i>No hay ninguna pregunta generada todavía.</i></p>
    <?php endif; ?>
</div>