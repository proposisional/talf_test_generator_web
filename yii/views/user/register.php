<?php

use yii\bootstrap5\ActiveForm;
use yii\bootstrap5\Html;

$this->title = 'Crear cuenta';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="site-register">
    <h1><?= Html::encode($this->title) ?></h1>

    <div class="row">
        <div class="col-lg-5">

            <?php $form = ActiveForm::begin([
                'id' => 'register-form',
                'fieldConfig' => [
                    'template' => "{label}\n{input}\n{error}",
                    'labelOptions' => ['class' => 'col-lg-1 col-form-label mr-lg-3'],
                    'inputOptions' => ['class' => 'col-lg-3 form-control'],
                    'errorOptions' => ['class' => 'col-lg-7 invalid-feedback'],
                ],
            ]); ?>

            <?= $form->field($model, 'username')->textInput(['autofocus' => true]) ?>

            <?= $form->field($model, 'password')->passwordInput() ?>

            <?= $form->field($model, 'password_confirm')->passwordInput() ?>

            <div class="form-group mt-3">
                <?= Html::submitButton('Crear cuenta', ['class' => 'btn btn-success', 'name' => 'register-button']) ?>
            </div>

            <?php ActiveForm::end(); ?>

            <p class="mt-3">
                ¿Ya tienes cuenta? <?= Html::a('Inicia sesión', ['site/login']) ?>
            </p>

        </div>
    </div>
</div>
