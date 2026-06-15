<?php

use yii\web\View;

ini_set('display_errors', 1);
error_reporting(E_ALL);

$octave = 'C:/Users/usuario/AppData/Local/Programs/GNUOctave/mingw64/bin/octave.exe';
$path = 'C:/xampp/htdocs/yii/octave';

$this->registerCssFile('@web/css/test.css?v=' . time());
$this->registerJsFile('@web/js/test.js');
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', [
    'position' => View::POS_HEAD
]);
?>

<head>
    <link href="https://fonts.googleapis.com/css2?family=Computer+Modern+Serif&display=swap" rel="stylesheet">
    <title></title>
</head>

<style>
    body {
        font-family: 'Computer Modern Serif', serif;
        !important;
        margin: 20px !important;
    }
</style>

<body>
    <h1>Examen Tipo Test</h1>

    <form id="testForm">

        <div class="indicator" id="indicator" class="nav-buttons">
            <button type="button" id="prevBtn" disabled>←</button>
            <?php foreach ($questions as $i => $q): ?>
                <span data-index="<?= $i ?>"><?= $i + 1 ?></span>
            <?php endforeach; ?>
            <button type="button" id="nextBtn">→</button>
        </div>

        <div class="question-box">
            <?php foreach ($questions as $i => $q): ?>
                <div class="question <?= $i === 0 ? 'active' : '' ?>" id="question-<?= $i ?>">
                    <h4><?= htmlspecialchars($q['title']) ?></h4>

                    <?php if (!empty($q['image'])): ?>
                        <img src="<?= htmlspecialchars($q['image']) ?>" alt="Imagen pregunta <?= $i + 1 ?>" />
                    <?php endif; ?>

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
</body>