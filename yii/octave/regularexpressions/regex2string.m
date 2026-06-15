function s = regex2string(regex)
    % regex2string: genera una cadena que pertenece al lenguaje definido por regex
    % regex: expresión regular simple como 'a*', 'ab', '(a+b)*'

    if isempty(regex)
        s = '';
        return;
    end

    % Manejar paréntesis
    if regex(1) == '(' && regex(end) == ')'
        s = regex2string(regex(2:end - 1));
        return;
    end

    % Unión '+' -> elegir una rama al azar
    idx = strfind(regex, '+');

    if ~isempty(idx)
        left = regex(1:idx(1) - 1);
        right = regex(idx(1) + 1:end);

        if randi([0, 1]) == 0
            s = regex2string(left);
        else
            s = regex2string(right);
        end

        return;
    end

    % Estrella de Kleene '*'
    if regex(end) == '*'
        base = regex(1:end - 1);
        n = randi([0, 3]); % número de repeticiones aleatorio entre 0 y 3
        s = '';

        for i = 1:n
            s = [s regex2string(base)];
        end

        return;
    end

    % Concatenación por defecto
    if length(regex) > 1
        s = [regex2string(regex(1)) regex2string(regex(2:end))];
        return;
    end

    % Caso base: un solo símbolo
    s = regex;
end
