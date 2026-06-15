<?php
/** test.php **/

// Suponiendo que generas tu LaTeX desde Octave y lo guardas en $latexString
// Por simplicidad aquí lo definimos manualmente
$latexString = <<<LATEX
K = \{q_0,q_1,q_2\} \\
\Sigma = \{a,b\} \\
s = q_0 \\
F = \{q_2\} \\
\delta: \delta(q_0,a) = q_1, \delta(q_0,b) = q_0, \delta(q_1,a) = q_2, \delta(q_1,b) = q_1, \delta(q_2,a) = q_2, \delta(q_2,b) = q_2
LATEX;
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <title>Visualización de DFA</title>
    <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
    <style>
        body {
            text-align: left;
            /* todo el LaTeX alineado a la derecha */
            font-family: sans-serif;
        }
    </style>
</head>

<body>
    <h2>DFA Example</h2>
    <div id="automaton">
        \(
        <?= $latexString ?>
        \)
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            MathJax.typesetPromise();
        });
    </script>
</body>

</html>