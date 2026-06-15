<?php

use \yii\helpers\Url;

$this->title = 'Generador de tests';
$this->registerCssFile('@web/css/index.css');
?>
<div class="site-index">
    <div class="jumbotron text-center bg-transparent mt-5 mb-5">
        <h1 class="display-5">Trabajo de Fin de Grado</h1>

        <p class="lead">Generador de exámenes tipo test para Teoría de Autómatas y Lenguajes Formales</p>

        <div class="container mt-4">
            <div>
                <a class="button-index" href="<?= Url::to(['console/talf-console']) ?>">Consola
                    TALF</a>
                <br>
                <br>
                <a class="button-index" href="<?= Url::to(['question/generate-question']) ?>">
                    Generador de preguntas
                </a>
                <br>
                <br>
                <a class="button-index" href="<?= Url::to(['question/create-question']) ?>">
                    Editor de preguntas
                </a>
                <br>
                <br>
                <a class="button-test" href="<?= Url::to(['test/setup']) ?>">
                    Ejecutar examen
                </a>
            </div>
        </div>
    </div>
</div>