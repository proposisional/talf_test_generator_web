<?php

$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('@web/js/create-question.js');
$this->registerJsFile('@web/js/download-question.js');
$this->registerJsFile('@web/js/import-question.js');
$this->registerCssFile('@web/css/create-question.css?v=' . time());

use yii\helpers\Html;
use yii\widgets\ActiveForm;
?>


<div class="question-layout">

    <div class="question-column left">
        <h1>Añadir pregunta</h1>

        <?php $form = ActiveForm::begin(['id' => 'question-form']); ?>

        <?= $form->field($model, 'title')->textInput(['id' => 'question-title']) ?>
        <?= $form->field($model, 'stem')->textarea(['id' => 'latex-input']) ?>

        <?php
        $subjects = [
            1 => '1. Preamble to Discrete Mathematics',
            2 => '2. Languages and Grammars',
            3 => '3. Regular Expressions',
            4 => '4. Finite Automata',
            5 => '5. Regularity Conditions',
            6 => '6. Context-free Languages',
            7 => '7. The Turing Machine',
            8 => '8. Recursive Functions',
            9 => '9. The WHILE Language',
            10 => '10. Turing Completeness',
            11 => '11. Universality',
            12 => '12. Theoretical Limits of Computing',
            13 => '13. Algorithmics and Complexity',
            14 => '14. Theory of Programming Languages',
        ];
        ?>
        <?= $form->field($model, 'subject')->dropDownList($subjects, [
            'prompt' => 'Sin tema',
        ]) ?>

        <h3>Opciones de respuesta</h3>

        <div id="choices-container">
            <?php
            $initialChoices = [];
            if (!empty($model->choices) && is_array($model->choices)) {
                $initialChoices = $model->choices;
            } else {
                $initialChoices = ['', ''];
            }

            $correct = !empty($model->correct_choices) && is_array($model->correct_choices)
                ? $model->correct_choices
                : [];
            ?>

            <?php foreach ($initialChoices as $i => $val): ?>
                <div class="choice-item">
                    <input type="text" name="Question[choices][<?= $i ?>]" value="<?= htmlspecialchars($val) ?>"
                        placeholder="Opción <?= $i + 1 ?>" class="form-control" />
                    <label class="correct-checkbox">
                        <input type="checkbox" name="Question[correct_choices][]" value="<?= $i ?>" <?= in_array($i, $correct) ? 'checked' : '' ?> />
                        Correcta
                    </label>
                    <button type="button" class="btn btn-sm btn-danger remove-choice"
                        title="Eliminar opción">&times;</button>
                </div>
            <?php endforeach; ?>
        </div>

        <div>
            <button type="button" id="add-choice">Añadir opción</button>
        </div>

        <div class="form-group image-inputs">
            <?= $form->field($model, 'image')->textInput(['id' => 'image-input', 'placeholder' => 'Pega un enlace de imagen (URL) o un SVG completo (<svg>...</svg>)'])->label(false) ?>
        </div>

        <div class="form-group">
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary']) ?>
            <button type="button" class="btn btn-secondary" id="download-question-btn" style="margin-left:8px;">
                Descargar pregunta
            </button>
            <button type="button" class="btn btn-secondary" id="download-question-moodle-btn" style="margin-left:8px;">
                Descargar Moodle XML
            </button>
            <button type="button" class="btn btn-secondary" id="import-question-btn" style="margin-left:8px;">
                Importar pregunta
            </button>
        </div>

        <?php ActiveForm::end(); ?>
    </div>

    <!-- Vista previa -->
    <div class="question-column right preview">
        <div id="preview-content"></div>
    </div>
</div>