function jsonQ = isNFA()

    if rand() < 0.33
        alphabet = {'a', 'b', 'c'};
    elseif rand() < 0.66
        alphabet = {'0', '1'};
    else
        alphabet = {'|'};
    end

    isNFA = rand() < 0.5;

    if isNFA
        automata = randomautomaton(alphabet, randi([3, 8]), 'NFA');
    else
        automata = randomautomaton(alphabet, randi([3, 8]), 'DFA');
    end

    % Prepare choices
    n = randi([1, 2]);
    q1.choices = cell(1, 2);
    q1.choices{n} = boolToStr(isNFA);
    rest = setdiff(1:2, n);
    q1.choices{rest(1)} = boolToStr(~isNFA);
    q1.correct_choices = {n - 1};

    % Prepare and send question JSON
    q1.title = "";
    q1.image = dotToSvg(automata, 'isNFA');
    q1.stem = ["¿Es el autómata de la imagen determinista?"];
    q1.subject = 4;
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end

function s = boolToStr(b)

    if b
        s = "Falso";
    else
        s = "Verdadero";
    end

end
