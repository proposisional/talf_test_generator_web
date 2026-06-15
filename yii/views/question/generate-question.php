<?php
$this->registerCssFile('@web/css/generate-question.css');
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('@web/js/download-question.js');
use yii\helpers\Html;

$question = $generatedQuestion ?? null;

$imgHtml = '';
if ($question && !empty($question->image)) {
    $imgHtml = \app\components\QuestionImageRenderer::render((string) $question->image, [
        'escapeText' => false,
        'svgStyle' => 'width:70%; height:auto; max-width:100%; max-height:100%;',
        'imgStyle' => 'max-width:70%; height:auto; max-height:100%;',
    ]);
}

$questionForJs = [
    'title' => '',
    'stem' => '',
    'image' => '',
    'choices' => [],
    'correct_choices' => [],
    'subject' => null,
];

if ($question) {
    $questionForJs['title'] = (string) ($question->title ?? '');
    $questionForJs['stem'] = (string) ($question->stem ?? '');
    $questionForJs['image'] = (string) ($question->image ?? '');
    $questionForJs['choices'] = is_array($question->choices) ? array_values($question->choices) : [];
    $questionForJs['correct_choices'] = is_array($question->correct_choices) ? array_values($question->correct_choices) : [];
    $questionForJs['subject'] = $question->subject ?? null;
}

$this->registerJs(
    'window.generatedQuestion = ' . json_encode($questionForJs, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . ';',
    \yii\web\View::POS_HEAD
);
?>

<form method="post" action="<?= \yii\helpers\Url::to(['generate-question']) ?>" style="flex:1;">
    <?= Html::hiddenInput(Yii::$app->request->csrfParam, Yii::$app->request->csrfToken) ?>

    <div class="container-flex">

        <p>Ejercicios:</p>
        <ul style="list-style:none; padding-left:0;">
            <li><label><input type="radio" name="subject" value="1"> Unión</label></li>
            <li><label><input type="radio" name="subject" value="2"> Diferencia</label></li>
            <li><label><input type="radio" name="subject" value="3"> Intersección</label></li>
            <li><label><input type="radio" name="subject" value="4"> Autómata</label></li>
            <li><label><input type="radio" name="subject" value="5"> No determinista</label></li>
            <li><label><input type="radio" name="subject" value="300"> Algoritmia</label></li>
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
        <button type="button" class="btn btn-secondary" id="download-question-btn">
            Descargar pregunta
        </button>
        <button type="button" class="btn btn-secondary" id="download-question-moodle-btn">
            Descargar Moodle XML
        </button>
    </div>
</form>

<script>
    (function () {
        const btn = document.getElementById('download-question-btn');
        const moodleBtn = document.getElementById('download-question-moodle-btn');
        function buildQuestion() {
            const selected = document.querySelector('input[name="subject"]:checked');
            const subject = selected ? Number(selected.value) : null;
            const base = (window.generatedQuestion && typeof window.generatedQuestion === 'object') ? window.generatedQuestion : {};
            const q = Object.assign({
                title: '',
                stem: '',
                image: '',
                choices: [],
                correct_choices: [],
                subject: null,
            }, base);
            if (subject !== null && Number.isFinite(subject)) q.subject = subject;
            return q;
        }
        if (!btn) return;
        btn.addEventListener('click', function () {
            const q = buildQuestion();
            if (typeof window.downloadQuestionAsTxt === 'function') {
                window.downloadQuestionAsTxt(q, 'generated-question');
            }
        });

        if (moodleBtn) {
            moodleBtn.addEventListener('click', function () {
                const q = buildQuestion();
                if (typeof window.downloadQuestionAsMoodleXml === 'function') {
                    window.downloadQuestionAsMoodleXml(q, 'generated-question-moodle');
                }
            });
        }
    })();
</script>