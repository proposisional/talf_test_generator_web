<?php
$this->registerCssFile('@web/css/add-question.css');

$this->registerJsFile('https://polyfill.io/v3/polyfill.min.js?features=es6', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', ['position' => \yii\web\View::POS_HEAD]);

$this->registerJs(<<<'JS'
(function() {
    const container = document.getElementById('choices-container');
    const addBtn = document.getElementById('add-choice');
    const titleInput = document.getElementById('question-title');
    const stemInput = document.getElementById('latex-input');
    const preview = document.getElementById('preview-content');

    function renumberChoices() {
        const items = container.querySelectorAll('.choice-item');
        items.forEach((item, idx) => {
            const text = item.querySelector('input[type="text"]');
            const checkbox = item.querySelector('input[type="checkbox"]');
            const removeBtn = item.querySelector('.remove-choice');

            text.name = 'Question[choices][' + idx + ']';
            text.placeholder = 'Opción ' + (idx + 1);
            checkbox.name = 'Question[correct_choices][]';
            checkbox.value = idx;

            removeBtn.disabled = items.length <= 2;
        });
        updatePreview();
    }

    function addChoice(value = '', checked = false) {
        const div = document.createElement('div');
        div.className = 'choice-item';

        const input = document.createElement('input');
        input.type = 'text';
        input.className = 'form-control';
        input.value = value;

        const label = document.createElement('label');
        label.className = 'correct-checkbox';
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        if (checked) checkbox.checked = true;
        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(' Correcta'));

        const removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.className = 'btn btn-sm btn-danger remove-choice';
        removeBtn.title = 'Eliminar opción';
        removeBtn.innerHTML = '×';

        div.appendChild(input);
        div.appendChild(label);
        div.appendChild(removeBtn);

        container.appendChild(div);
        renumberChoices();
    }

    function updatePreview() {
        const title = document.getElementById('question-title').value;
        const stem = document.getElementById('latex-input').value;
        const container = document.getElementById('choices-container');
        const preview = document.getElementById('preview-content');

        const choices = Array.from(container.querySelectorAll('.choice-item')).map(item => {
            return {
                text: item.querySelector('input[type="text"]').value,
                checked: item.querySelector('input[type="checkbox"]').checked
            };
        });

        const isMultiple = choices.filter(c => c.checked).length > 1;

        let html = `<h2>${title}</h2>`;
        html += `<p>${stem}</p>`;
        html += `<ul style="list-style:none; padding-left:0;">`;

        choices.forEach(c => {
            const type = isMultiple ? 'checkbox' : 'radio';
            html += `<li>
                        <label>
                            <input type="${type}" disabled ${c.checked ? 'checked' : ''} />
                            ${c.text}
                        </label>
                    </li>`;
        });

        html += `</ul>`;
        preview.innerHTML = html;

        MathJax.typesetPromise([preview]);
    }


    container.addEventListener('click', function(e) {
        if (e.target.matches('.remove-choice')) {
            const items = container.querySelectorAll('.choice-item');
            if (items.length <= 2) return;
            e.target.closest('.choice-item').remove();
            renumberChoices();
        }
    });

    container.addEventListener('input', updatePreview);
    container.addEventListener('change', updatePreview);
    titleInput.addEventListener('input', updatePreview);
    stemInput.addEventListener('input', updatePreview);

    addBtn.addEventListener('click', function() {
        addChoice('', false);
    });

    document.addEventListener('DOMContentLoaded', function() {
        renumberChoices();
        updatePreview();
    });

    window._quizChoices = { addChoice, renumberChoices };
})();
JS
);


?>

<?php
use yii\helpers\Html;
use yii\widgets\ActiveForm;
?>

<style>
    body {
        font-family: 'Computer Modern Serif', serif;
        !important;
        margin: 20px !important;
    }
</style>

<div style="display:flex; gap:30px;">

    <!-- Formulario -->
    <div style="flex:1;">
        <h1>Añadir pregunta</h1>

        <?php $form = ActiveForm::begin(['id' => 'question-form']); ?>

        <?= $form->field($model, 'title')->textInput(['id' => 'question-title']) ?>
        <?= $form->field($model, 'stem')->textarea(['id' => 'latex-input']) ?>

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

        <button type="button" id="add-choice" class="btn btn-secondary mt-2">➕ Añadir opción</button>

        <div class="form-group image-inputs">
            <?= $form->field($model, 'image')->fileInput(['class' => 'form-control'])->label(false) ?>
            <?= $form->field($model, 'image')->textInput(['placeholder' => 'o pega un enlace de imagen'])->label(false) ?>
        </div>

        <div class="form-group">
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary']) ?>
        </div>

        <?php ActiveForm::end(); ?>
    </div>

    <!-- Vista previa -->
    <div style="flex:1; border:1px solid #ccc; padding:15px; border-radius:8px; background:#fafafa;">
        <div id="preview-content"></div>
    </div>
</div>