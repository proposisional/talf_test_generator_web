function json_str = algoritmia()
    q1.title = "Cuestiones de P y NP";
    q1.image = "";
    q1.choices = {
            "Verdadero",
            "Falso",
            "\\( P = NP \\)",
            "\\( P \\neq NP \\)"
            };
    q1.subject = 13;

    pnp_problems = pnp_problems();
    keys = cell2mat(pnp_problems.keys);
    k = keys(randi(numel(keys)));
    q1.stem = pnp_problems(k){1};
    q1.correct_choices = {pnp_problems(k){2}};

    json_str = jsonencode(q1);
    disp(json_str);
end

function dict = pnp_problems()
    dict = containers.Map('KeyType', 'double', 'ValueType', 'any');
    # 0 = True
    # 1 = False
    # 2 = P = NP
    # 3 = P != NP
    dict(0) = {"Existe un lenguaje en P que puede ser decidido en tiempo polinómico", 0};
    dict(1) = {"Existe un lenguaje en NP que puede ser decidido en tiempo polinómico", 0};
    dict(2) = {"Existe un lenguaje NP-completo que puede ser decidido en tiempo polinómico", 2};
    dict(3) = {"Existe un lenguaje NP-difícil que puede ser decidido en tiempo polinómico", 2};
    dict(4) = {"Existe un lenguaje en NP que no puede ser decidido en tiempo polinómico", 3};
    dict(5) = {"Existe un lenguaje NP-completo que puede ser decidido en tiempo polinómico", 2};
    dict(6) = {"Existe un lenguaje NP-difícil que no está en NP", 0};
    dict(7) = {"Cada lenguaje en NP es verificable en tiempo polinómico (existe un verificador)", 0};
    dict(8) = {"Cada lenguaje en NP es decidible en tiempo polinómico (existe un decisor)", 2};
    dict(9) = {"No existe un lenguaje \\( L \\in P \\) tal que \\( L \\leq_P 3SAT \\)", 1};
    dict(10) = {"No existe un lenguaje \\( L \\in NP \\) tal que \\( L \\leq_P 3SAT \\)", 1};
    dict(11) = {"Existe un lenguaje \\( L \\in NPC \\) tal que \\( L \\leq_P 3SAT \\)", 0};
    dict(12) = {"Existe un lenguaje \\( L \\in P \\) tal que \\( 3SAT \\leq_P L \\)", 2};
    dict(13) = {"Todos los lenguajes en PSPACE son decidibles", 0};
    dict(14) = {"Todos los lenguajes en EXP son decidibles", 0};
end
