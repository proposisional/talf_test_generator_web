<?php
$this->registerCssFile('@web/css/generate-question.css');

$this->registerJsFile('https://polyfill.io/v3/polyfill.min.js?features=es6', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', ['position' => \yii\web\View::POS_HEAD]);
use yii\helpers\Html;

$question = $generatedQuestion ?? null;
?>

<h2>Escoge el tipo de pregunta a generar</h2>

<form method="post" action="<?= \yii\helpers\Url::to(['site/generate-question']) ?>" style="flex:1;">
    <?= Html::hiddenInput(Yii::$app->request->csrfParam, Yii::$app->request->csrfToken) ?>

    <div class="container-flex">

        <ul style="list-style:none; padding-left:0;">
            <li><label><input type="radio" name="subject" value="1"> Ejercicio 1</label></li>
            <li><label><input type="radio" name="subject" value="2"> Ejercicio 2</label></li>
            <li><label><input type="radio" name="subject" value="3"> Ejercicio 3</label></li>
            <li><label><input type="radio" name="subject" value="4"> Ejercicio 4</label></li>
            <li><label><input type="radio" name="subject" value="5"> Ejercicio 5</label></li>
            <li><label><input type="radio" name="subject" value="6"> Ejercicio 6</label></li>
            <li><label><input type="radio" name="subject" value="7"> Ejercicio 7</label></li>
            <li><label><input type="radio" name="subject" value="8"> Ejercicio 8</label></li>
            <li><label><input type="radio" name="subject" value="9"> Ejercicio 9</label></li>
            <li><label><input type="radio" name="subject" value="10"> Ejercicio 10</label></li>
        </ul>

        <div style="flex:1; border:1px solid #ccc; padding:15px; border-radius:8px; background:#fafafa;">
            <div id="preview-content">
                <?php if ($question): ?>
                    <?php
                    $choices = is_array($question->choices) ? $question->choices : [];
                    $correctChoices = is_array($question->correct_choices) ? $question->correct_choices : [];
                    $isMultiple = count($correctChoices) > 1;

                    ?>
                    <h2><?= $question->title ?? '' ?></h2>
                    <p><?= $question->stem ?? '' ?></p>

                    <?php if ($question->image): ?>
                        <div style="text-align:center; margin-bottom:10px;">
                            <?= $question->image ?>
                        </div>
                    <?php endif; ?>



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
                    <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            MathJax.typesetPromise();
                        });
                    </script>
                <?php endif; ?>
            </div>
        </div>

    </div>

    <div class="button-group">
        <button type="submit" name="action" value="generate" class="btn btn-success">
            Generar pregunta
        </button>
        <button type="submit" name="action" value="save" class="btn btn-primary">
            Guardar en la base de datos
        </button>
    </div>
</form>