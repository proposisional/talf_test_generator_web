<?php
/** @var array $items */
use yii\bootstrap5\Html;
use yii\web\View;

$this->title = 'Historial de exámenes';
$this->registerCssFile('@web/css/history.css?v=' . time());
$this->registerJsFile('@web/js/history.js');
?>

<div class="history-container">
    <h1>Historial de exámenes</h1>
    <?php if (empty($items)): ?>
        <p>No hay exámenes realizados aún.</p>
    <?php else: ?>
        <div class="history-list">
            <?php foreach ($items as $it): ?>
                <a class="history-item"
                    href="<?= Html::encode(\yii\helpers\Url::to(['test/history-test', 'id' => $it['answer_id']])) ?>">
                    <div class="item-title"><?= Html::encode($it['name']) ?></div>
                    <div class="item-meta">
                        <span class="date"><?= Html::encode($it['date']) ?></span>
                        <span class="score">Nota: <?= number_format((float) $it['score'], 2) ?></span>
                        <span class="total">Preguntas: <?= (int) $it['total'] ?></span>
                        <?php if ($it['correct'] !== null): ?>
                            <span class="correct">Aciertos: <?= (int) $it['correct'] ?></span>
                        <?php endif; ?>
                    </div>
                </a>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</div>