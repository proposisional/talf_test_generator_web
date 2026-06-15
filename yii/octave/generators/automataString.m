function jsonQ = automataString()
    % Create a DFA
    if rand() < 0.5
        alphabet = {'a', 'b', 'c'};
    else
        alphabet = {'0', '1'};
    end

    dfa = randomautomaton(alphabet, randi([3, 8]), 'DFA');

    % Prepare choices
    examples = generate_examples(dfa);
    n = randi([1, 3]);
    q1.choices = cell(1, 3);
    q1.choices{n} = ["\\(", examples{1}, "\\)"];
    rest = setdiff(1:3, n);
    q1.choices{rest(1)} = ["\\(", examples{2}, "\\)"];
    q1.choices{rest(2)} = ["\\(", examples{3}, "\\)"];
    q1.correct_choices = {n - 1};

    % Prepare and send question JSON
    q1.title = "";
    q1.image = "";
    q1.stem = strcat("¿Qué cadena puede ser procesada por el siguiente autómata?", ...
        automatonToStringLatex(dfa));
    q1.subject = 4;
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end

function examples = generate_examples(dfa)
    % GENERATE_EXAMPLES genera una cadena aceptada y dos rechazadas
    % examples = {correcto, fake1, fake2}

    % Construir grafo de transiciones
    adj = containers.Map();

    for i = 1:numel(dfa.t)
        tr = dfa.t{i};
        from = tr{1}; symb = tr{2}; to = tr{3};

        if ~isKey(adj, from)
            adj(from) = {};
        end

        tmp = adj(from);
        tmp{end + 1} = {symb, to};
        adj(from) = tmp;
    end

    % Encontrar cadena aceptada más larga usando BFS con prioridad
    queue = {{dfa.s, ""}};
    visited = containers.Map();
    accepted = "";

    while ~isempty(queue)
        current = queue{1}; queue(1) = [];
        state = current{1}; str = current{2};

        if isKey(visited, state)
            continue;
        end

        visited(state) = true;

        % si es final, actualizar si es más larga que la anterior
        if ismember(state, dfa.F)

            if length(str) > length(accepted)
                accepted = str;
            end

        end

        if isKey(adj, state)
            trans = adj(state);

            for j = 1:numel(trans)
                symb = trans{j}{1};
                to = trans{j}{2};
                queue{end + 1} = {to, [str symb]};
            end

        end

    end

    % Si el DFA no acepta nada
    if isempty(accepted)
        accepted = "ε"; % cadena vacía como símbolo
    end

    % Generar dos cadenas rechazadas largas
    rejected = {};
    alphabet = dfa.A;

    % Rechazada 1: alterar el último símbolo
    if ~isempty(alphabet)
        wrong1 = accepted;
        wrong1(end) = pickOtherSymbol(wrong1(end), alphabet);
        rejected{end + 1} = wrong1;
    else
        rejected{end + 1} = "x"; % arbitrario
    end

    % Rechazada 2: agregar símbolo extra al final
    if ~isempty(alphabet)
        wrong2 = [accepted alphabet{1}];
        rejected{end + 1} = wrong2;
    else
        rejected{end + 1} = "y";
    end

    % Devolver como vector de strings: {correcto, fake1, fake2}
    examples = {accepted, rejected{1}, rejected{2}};
end

function alt = pickOtherSymbol(symb, alphabet)
    % devuelve un símbolo distinto al actual dentro del alfabeto
    others = setdiff(alphabet, {symb});

    if isempty(others)
        alt = symb; % si no hay otro, repetir el mismo
    else
        alt = others{1};
    end

end
