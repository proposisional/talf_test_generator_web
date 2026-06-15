<?php

/** @var yii\web\View $this */

use yii\bootstrap5\Html;

$this->title = 'Documentación';
$this->params['breadcrumbs'][] = $this->title;

$this->registerCss(<<<'CSS'
.site-documentation ul > li,
.site-documentation ol > li {
    margin-bottom: 0.65rem;
}

.site-documentation ul > li:last-child,
.site-documentation ol > li:last-child {
    margin-bottom: 0;
}
CSS);

$links = [
    'inicio' => ['site/index'],
    'login' => ['site/login'],
    'consola' => ['console/talf-console'],
    'historial' => ['test/history'],
];

$helpCommands = [];
$helpOctaveCommands = [];

try {
    $helpPath = Yii::getAlias('@app/data/help.json');
    if (is_file($helpPath)) {
        $helpCommands = json_decode((string) file_get_contents($helpPath), true) ?: [];
    }

    $helpOctavePath = Yii::getAlias('@app/data/helpOctave.json');
    if (is_file($helpOctavePath)) {
        $helpOctaveCommands = json_decode((string) file_get_contents($helpOctavePath), true) ?: [];
    }
} catch (Throwable $e) {
    $helpCommands = [];
    $helpOctaveCommands = [];
}

$exampleQuestion = [
    'title' => 'Autómatas finitos y lenguajes',
    'stem' => 'Dado el siguiente AFD, ¿cuál de las opciones describe el lenguaje aceptado?',
    'image' => '',
    'choices' => [
        'Cadenas sobre {0,1} que terminan en 1',
        'Cadenas sobre {0,1} con número par de 1s',
        'Cadenas sobre {0,1} que contienen la subcadena 01',
        'Cadenas sobre {0,1} de longitud exactamente 3',
    ],
    'correct_choices' => [1],
    'subject' => 4,
];

$exampleQuestionJson = json_encode(
    $exampleQuestion,
    JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
);

?>

<div class="site-documentation">
    <h3>
        <?= Html::encode($this->title) ?>
    </h3>

    <p class="text-muted">
        Esta documentación tiene como objetivo proporcionar una guía rápida para el uso de la creación de preguntas tipo
        test con la aplicación web.
    </p>

    <div class="card mb-4">
        <div class="card-body">
            <ul class="mb-0">
                <li><a href="#introduccion">Introducción</a></li>
                <li><a href="#consola-talf">Consola TALF (generador)</a></li>
                <li><a href="#consultar-ia">Consultar IA</a></li>
                <li><a href="#guardar-pregunta">Guardar pregunta</a></li>
                <li><a href="#comandos-octave">Comandos Octave</a></li>
                <li><a href="#tests">Realizar tests</a></li>
                <li><a href="#historial">Historial</a></li>
            </ul>
        </div>
    </div>

    <br>
    <h3 id="introduccion">Introducción</h3>

    La aplicación web permite a los usuarios generar preguntas tipo test para exámenes, estas preguntas tienen el
    siguiente formato:
    <div class="card mt-2">
        <div class="card-body">
            <pre class="mb-0"><code><?= Html::encode($exampleQuestionJson) ?></code></pre>
        </div>
    </div>

    <br>
    Los parametros obligatorios para poder considerarse una pregunta válida son:
    <ul>
        <li>stem (descripción)</li>
        <li>choices (posibles respuestas)</li>
        <li>correct_choices (respuestas correctas)</li>
    </ul>


    <br>
    <h3 id="consola-talf">Comandos Consola TALF</h3>
    <p>
        Esta es la lista de comandos disponibles en la <a
            href="<?= Html::encode(Yii::$app->urlManager->createUrl($links['consola'])) ?>">consola TALF</a>
        :
    </p>
    <ul>
        <?php if (!empty($helpCommands) && is_array($helpCommands)): ?>
            <?php foreach ($helpCommands as $cmd => $desc): ?>
                <li>
                    <strong><?= Html::encode((string) $cmd) ?></strong>:
                    <?= nl2br(Html::encode((string) $desc)) ?>
                </li>
            <?php endforeach; ?>
        <?php else: ?>
            <li class="text-muted"><i>No se pudieron cargar los comandos desde data/help.json</i></li>
        <?php endif; ?>
    </ul>

    <br>
    <h3 id="comandos-octave">Comandos Octave</h3>
    <p>
        Estos comandos corresponden a generadores/funciones disponibles. Puedes listarlos desde la consola con
        <strong>octave</strong>.
    </p>
    <ul>
        <?php if (!empty($helpOctaveCommands) && is_array($helpOctaveCommands)): ?>
            <?php foreach ($helpOctaveCommands as $cmd => $desc): ?>
                <li>
                    <strong><?= Html::encode((string) $cmd) ?></strong>:
                    <?= nl2br(Html::encode((string) $desc)) ?>
                </li>
            <?php endforeach; ?>
        <?php else: ?>
            <li class="text-muted"><i>No se pudieron cargar los comandos desde data/helpOctave.json</i></li>
        <?php endif; ?>
    </ul>

    <br>
    <h3 id="consultar-ia">Consultar IA</h3>
    <p>
        En la consola, está habilitado el botón de "Consultar IA" que permite enviar la pregunta con el formato indicado
        a la API de Gemini, esta responderá con sugerencias principalmente de ortografía y gramática y, sobretodo, si la
        pregunta está bien estructurada para un estudiante de los primeros años de Ingeniería Informática.
    </p>

    <p>
        Dada la complejidad matemática de la asignatura y la falta de contexto visual en algunas preguntas, no debe
        consultarse a la IA para saber si una respuesta es correcta o no. Su uso es meramente orientativo en el aspecto
        textual.
    </p>

    <br>
    <h3 id="guardar-pregunta">Guardar pregunta</h3>
    <p>
        Cuando tengas una pregunta lista en las distintas pantallas de la aplicación, si esta cumple con los
        parámetros necesarios, podrás guardarla en la base de datos mediante el botón. En caso contrario, se te indicará
        el error.
    </p>

    <br>
    <h3 id="tests">Ejecutar examen</h3>
    <p>
        Desde el apartado de tests podrás responder preguntas y obtener tu resultado.
        Si tu sesión requiere autenticación, inicia sesión antes.
    </p>

    <br>
    <h3 id="historial">Historial</h3>
    <p>
        Cuando estés autenticado, puedes consultar tus intentos anteriores:
        <a href="<?= Html::encode(Yii::$app->urlManager->createUrl($links['historial'])) ?>">ver historial</a>
    </p>
</div>