<?php

/** @var yii\web\View $this */
use yii\helpers\Url;
?>

<div class="site-index">

    <div class="jumbotron text-center bg-transparent mt-5 mb-5">
        <h1 class="display-4">Configuración</h1>

        <p class="lead">Establece los parámetros del examen:</p>

        <form action="<?= Url::to(['site/test']) ?>" method="get">
            <div class="form-group">
                <label for="numQuestions">Número de preguntas:</label>
                <input type="number" id="numQuestions" name="numQuestions" class="form-control text-center mx-auto"
                    style="max-width: 200px;" min="1" max="100" value="10" required>
            </div>

            <div class="form-group mt-4">
                <p>Seleccione los temas:</p>

                <div class="mx-auto text-start" style="max-width: 300px;">
                    <div class="form-check">
                        <label class="form-check-label" for="subject1">1. Preamble to Discrete Mathematics</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject1" id="subject1">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject2">2. Languages and Grammars</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject2" id="subject2">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject3">3. Regular Expressions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject3" id="subject3">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject4">4. Finite Automata</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject4" id="subject4">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject5">5. Regularity Conditions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject5" id="subject5">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject6">6. Context-free Languages</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject6" id="subject6">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject7">7. The Turing Machine</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject7" id="subject7">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject8">8. Recursive Functions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject8" id="subject8">
                    </div>
                    
                    <div class="form-check">
                        <label class="form-check-label" for="subject9">9. The WHILE Language</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject9" id="subject9">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject10">10. Turing Completeness</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject10" id="subject10">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject11">11. Universality</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject11" id="subject11">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject12">12. Theoretical Limits of Computing</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="subject12" id="subject12">
                    </div>
                </div>
            </div>


            <button type="submit" class="btn btn-lg btn-success mt-4">Comenzar examen</button>
        </form>
    </div>
</div>