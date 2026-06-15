<?php
use yii\helpers\Html;

$this->registerCssFile('@web/css/talf-console.css');
$this->registerJsFile('https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js', ['position' => \yii\web\View::POS_HEAD]);
$this->registerJsFile('@web/js/talf-console.js', ['depends' => [\yii\web\JqueryAsset::class]]);
$this->registerJsFile('@web/js/download-question.js', ['depends' => [\yii\web\JqueryAsset::class]]);
$this->registerJsFile('@web/js/import-question.js', ['depends' => [\yii\web\JqueryAsset::class]]);

$docUrl = \yii\helpers\Url::to(['/site/documentation']);
$importUrl = \yii\helpers\Url::to(['/console/import-question']);
$this->registerJs(
    'window.talfDocumentationUrl = ' . json_encode($docUrl) . ';',
    \yii\web\View::POS_HEAD
);
$this->registerJs(
    'window.talfImportQuestionUrl = ' . json_encode($importUrl) . ';',
    \yii\web\View::POS_HEAD
);

$question = $_SESSION['question'] ?? null;

$questionForJs = is_array($question) ? $question : [
    'title' => '',
    'stem' => '',
    'image' => '',
    'choices' => [],
    'correct_choices' => [],
    'subject' => null,
];

$this->registerJs(
    'window.currentQuestion = ' . json_encode(['Question' => $questionForJs], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) . ';',
    \yii\web\View::POS_HEAD
);
?>

<div class="save-container">
    <a href="<?= \yii\helpers\Url::to(['console/save-current-question']) ?>" class="btn btn-primary"
        id="save-question-btn">
        Guardar pregunta
    </a>
    <button type="button" class="btn btn-secondary" id="download-question-btn" style="margin-left:8px;">
        Descargar pregunta
    </button>
    <button type="button" class="btn btn-secondary" id="download-question-moodle-btn" style="margin-left:8px;">
        Descargar Moodle XML
    </button>
    <button type="button" class="btn btn-secondary" id="import-question-btn" style="margin-left:8px;">
        Importar pregunta
    </button>
    <button type="button" class="btn btn-info" id="ask-ai-btn" style="margin-left:8px;">
        Consultar IA
    </button>
</div>


<div class="talf-console-container">

    <div class="preview-pane">
        <div id="preview-content"
            style="white-space:normal; overflow-wrap:anywhere; word-break:break-word; max-width:100%; box-sizing:border-box;">
            <?php if ($question): ?>
                <?php
                $choices = is_array($question['choices']) ? $question['choices'] : [];
                $correctChoices = is_array($question['correct_choices']) ? $question['correct_choices'] : [];
                $isMultiple = count($correctChoices) > 1;
                ?>
                <h2><?= Html::encode($question['title'] ?? '') ?></h2>
                <p><?= Html::encode($question['stem'] ?? '') ?></p>

                <div id="img-preview-console"
                    style="text-align:center; margin-bottom:10px; max-width:100%; overflow:hidden;"></div>

                <ul style="list-style:none; padding-left:0; margin:0;">
                    <?php foreach ($choices as $i => $text): ?>
                        <li
                            style="<?= in_array($i, $correctChoices) ? 'background-color: #d4edda; padding: 5px; border-radius: 4px;' : '' ?> white-space:normal; overflow-wrap:anywhere; word-break:break-word;">
                            <label>
                                <input type="<?= $isMultiple ? 'checkbox' : 'radio' ?>" disabled <?= in_array($i, $correctChoices) ? 'checked' : '' ?> />
                                <?= Html::encode($text) ?>
                            </label>
                        </li>
                    <?php endforeach; ?>
                </ul>

                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const imgVal = <?= json_encode($question['image'] ?? '') ?>;
                        const container = document.getElementById('img-preview-console');
                        if (imgVal && typeof imgVal === 'string') {
                            const trimmed = imgVal.trim();
                            const isUrl = /^(https?:\/\/|\/|\.\/|\.\.\/)/i.test(trimmed);
                            const isDataImage = /^data:image\/(png|jpe?g|gif|webp|svg\+xml);base64,/i.test(trimmed);
                            const isSvg = /<svg\b/i.test(trimmed);
                            const looksLikeBase64 = (s) => {
                                const clean = s.replace(/\s+/g, '');
                                if (clean.length < 80) return false;
                                return /^[A-Za-z0-9+/=]+$/.test(clean);
                            };
                            const guessMime = (b64) => {
                                if (b64.startsWith('/9j/')) return 'image/jpeg';
                                if (b64.startsWith('R0lGOD')) return 'image/gif';
                                if (b64.startsWith('PHN2Zy')) return 'image/svg+xml';
                                if (b64.startsWith('iVBORw0KGgo')) return 'image/png';
                                return 'image/png';
                            };

                            if (isSvg) {
                                try {
                                    const temp = document.createElement('div');
                                    temp.innerHTML = trimmed;
                                    const svg = temp.querySelector('svg');
                                    if (svg) {
                                        svg.style.width = '70%';
                                        svg.style.height = 'auto';
                                        svg.style.maxWidth = '100%';
                                        svg.style.maxHeight = '100%';
                                        container.innerHTML = '';
                                        container.appendChild(svg);
                                    } else {
                                        container.textContent = 'Error: el contenido de la imagen no parece un SVG válido.';
                                    }
                                } catch (e) {
                                    container.textContent = 'Error al renderizar el SVG.';
                                }
                            } else if (isUrl || isDataImage || looksLikeBase64(trimmed)) {
                                const img = new Image();
                                img.style.maxWidth = '70%';
                                img.style.height = 'auto';
                                container.textContent = 'Cargando imagen...';
                                img.onload = () => {
                                    container.innerHTML = '';
                                    container.appendChild(img);
                                };
                                img.onerror = () => {
                                    container.textContent = 'Error: no se pudo cargar la imagen.';
                                };
                                if (isDataImage || isUrl) {
                                    img.src = trimmed;
                                } else {
                                    const clean = trimmed.replace(/\s+/g, '');
                                    img.src = `data:${guessMime(clean)};base64,${clean}`;
                                }
                            } else {
                                const p = document.createElement('p');
                                p.style.margin = '0';
                                p.style.display = 'inline-block';
                                p.style.maxWidth = '100%';
                                p.style.overflowWrap = 'anywhere';
                                p.style.wordBreak = 'break-word';
                                p.textContent = trimmed;
                                container.innerHTML = '';
                                container.appendChild(p);
                            }
                        } else {
                            container.textContent = '';
                        }

                        if (window.MathJax) MathJax.typesetPromise();
                    });
                </script>
            <?php else: ?>
                <p><i>No hay ninguna pregunta generada todavía.</i></p>
            <?php endif; ?>
        </div>
    </div>

    <div id="terminal">
        <div id="output"></div>
        <div id="input-line">
            <span class="prompt">talf:\></span>
            <input type="text" id="command-input" autocomplete="off" placeholder="Escriba su comando..." />
        </div>
    </div>

</div>

<div id="ai-response"
    style="margin-top:15px; padding:10px; border:1px dashed #6c757d; border-radius:6px; background:#f8f9fa;"></div>

<script>
    (function () {
        const btn = document.getElementById('ask-ai-btn');
        const box = document.getElementById('ai-response');
        if (!btn || !box) return;
        btn.addEventListener('click', async function () {
            box.textContent = 'Consultando IA...';
            try {
                const resp = await fetch('<?= \yii\helpers\Url::to(['console/ask-ai']) ?>', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-Token': '<?= Yii::$app->request->getCsrfToken() ?>',
                        'Accept': 'application/json'
                    }
                });
                let data = null;
                try { data = await resp.json(); } catch (e) {
                    box.textContent = 'Error: respuesta no JSON (' + e.message + ')';
                    return;
                }
                if (!resp.ok) {
                    box.textContent = 'Error HTTP ' + resp.status + ': ' + (data && data.error ? data.error : 'sin detalle');
                    return;
                }
                if (data && data.ok) {
                    // html formateado desde la api
                    box.innerHTML = data.text;
                } else {
                    box.textContent = (data && data.error) ? ('Error: ' + data.error) : 'Error desconocido consultando IA';
                }
            } catch (e) {
                box.textContent = 'Error de red: ' + e.message;
            }
        });
    })();
</script>

<script>
    (function () {
        const btn = document.getElementById('download-question-btn');
        const moodleBtn = document.getElementById('download-question-moodle-btn');
        if (!btn) return;
        btn.addEventListener('click', function () {
            const q = (window.currentQuestion && window.currentQuestion.Question) ? window.currentQuestion.Question : {};
            if (typeof window.downloadQuestionAsTxt === 'function') {
                window.downloadQuestionAsTxt(q, 'talf-question');
            }
        });

        if (moodleBtn) {
            moodleBtn.addEventListener('click', function () {
                const q = (window.currentQuestion && window.currentQuestion.Question) ? window.currentQuestion.Question : {};
                if (typeof window.downloadQuestionAsMoodleXml === 'function') {
                    window.downloadQuestionAsMoodleXml(q, 'talf-question-moodle');
                }
            });
        }
    })();
</script>