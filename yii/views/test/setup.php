<?php

/** @var yii\web\View $this */
use yii\helpers\Url;
?>

<div class="site-index">

    <div class="jumbotron text-center bg-transparent mt-5 mb-5">
        <h1>Configuración</h1>

        <br>

        <form action="<?= Url::to(['test/test']) ?>" method="get">
            <div class="form-group">
                <label for="numQuestions">Número de preguntas:</label>
                <input type="number" id="numQuestions" name="numQuestions" class="form-control text-center mx-auto"
                    style="max-width: 200px;" min="1" max="100" value="10" required>
            </div>

            <div class="form-group mt-4">
                <p><strong>Tipo de evaluación</strong></p>
                <div class="mx-auto text-start" style="max-width: 500px;">
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="evaluation" id="evalClassic" value="classic"
                            checked>
                        <label class="form-check-label" for="evalClassic">
                            <b>Clásico</b>: cada fallo resta el 33% del valor de la pregunta
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="evaluation" id="evalNoPenalty"
                            value="no_penalty">
                        <label class="form-check-label" for="evalNoPenalty">
                            Sin penalización por fallo
                        </label>
                    </div>
                </div>
            </div>

            <div class="form-group mt-4">
                <p><strong>Temas a evaluar</strong></p>

                <div class="mx-auto text-start" style="max-width: 300px;">
                    <div class="form-check">
                        <label class="form-check-label" for="subject1">1. Preamble to Discrete Mathematics</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="1" id="subject1">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject2">2. Languages and Grammars</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="2" id="subject2">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject3">3. Regular Expressions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="3" id="subject3">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject4">4. Finite Automata</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="4" id="subject4">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject5">5. Regularity Conditions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="5" id="subject5">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject6">6. Context-free Languages</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="6" id="subject6">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject7">7. The Turing Machine</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="7" id="subject7">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject8">8. Recursive Functions</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="8" id="subject8">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject9">9. The WHILE Language</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="9" id="subject9">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject10">10. Turing Completeness</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="10" id="subject10">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject11">11. Universality</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="11" id="subject11">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject12">12. Theoretical Limits of Computing</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="12" id="subject12">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject13">13. Algorithmics and Complexity</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="13" id="subject13">
                    </div>

                    <div class="form-check">
                        <label class="form-check-label" for="subject14">14. Theory of Programming Languages</label>
                        <input class="form-check-input" type="checkbox" name="subjects[]" value="14" id="subject14">
                    </div>
                </div>
            </div>


            <button type="submit" class="btn btn-lg btn-success mt-4">Comenzar examen</button>
        </form>
    </div>
</div>

<script>
    (function () {
        const qInput = document.getElementById('numQuestions');
        const qValue = document.getElementById('qValue');
        const qPenalty = document.getElementById('qPenalty');

        function updateValues() {
            const n = Math.max(1, parseInt(qInput.value || '1', 10));
            const val = 10 / n;
            const pen = val * 0.33;
            qValue.textContent = val.toFixed(2);
            qPenalty.textContent = pen.toFixed(2);
        }

        qInput.addEventListener('input', updateValues);
        updateValues();
    })();
</script>