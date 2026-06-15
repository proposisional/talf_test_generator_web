function json_str = test()
    q1.title = "Expresiones regulares";
    q1.stem = "Si \\( \\alpha \\) es una expresión regular, entonces:";
    q1.image = "";
    q1.choices = {
            "\\( \\alpha\\alpha^* - \\alpha^* = \\emptyset \\)",
            "\\( \\alpha\\alpha^* - \\alpha^* = \\{\\varepsilon\\} \\)",
            "\\( \\alpha\\alpha^* - \\alpha^* = \\alpha \\)"
            };
    q1.correct_choices = {2};

    json_str = jsonencode(q1);
    disp(json_str);
end
