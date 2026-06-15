% regex2dfa_full.m
function dfa = regex2dfa(regex, varargin)
    % regex2dfa: convierte una expresión regular a DFA (usando tus operaciones)
    % regex2dfa(regex) -> devuelve dfa
    % regex2dfa(regex, filename) -> además exporta a DOT al filename
    global state_id;
    state_id = 0; % contador global para crear nombres de estados únicos

    % 1) tokenizar
    tokens = tokenizeRegex(regex);

    % 2) parsear (recursive-descent)
    [dfa, nextIdx] = parseExpr(tokens, 1);

    if nextIdx <= numel(tokens)
        error("Parse error: tokens residuales a partir de la pos %d", nextIdx);
    end

    % 3) export optional a DOT
    if nargin > 1
        filename = varargin{1};
        formatautomaton(dfa, filename);
        fprintf("DFA exportado a %s\n", filename);
    end

end

%% ----------------------
%% TOKENIZER
function tokens = tokenizeRegex(regex)
    tokens = {};

    for i = 1:length(regex)
        c = regex(i);

        if c == '(' || c == ')' || c == '+' || c == '*' || c == '∅'
            tokens{end + 1} = c;
        else
            % cualquier otro caracter se considera símbolo del alfabeto
            tokens{end + 1} = c;
        end

    end

end

%% ----------------------
%% PARSER (recursive descent)
function [dfa, idx] = parseExpr(tokens, idx)
    % Expr := Term { '+' Term }
    [dfa, idx] = parseTerm(tokens, idx);
    n = numel(tokens);

    while idx <= n && strcmp(tokens{idx}, '+')
        idx = idx + 1;
        [right, idx] = parseTerm(tokens, idx);
        dfa = union(dfa, right);
    end

end

function [dfa, idx] = parseTerm(tokens, idx)
    % Term := Factor { Factor }    (concatenation is implicit)
    [dfa, idx] = parseFactor(tokens, idx);
    n = numel(tokens);
    % concatenation continues until ) or + or end
    while idx <= n &&~strcmp(tokens{idx}, ')') &&~strcmp(tokens{idx}, '+')
        [nextDfa, idx] = parseFactor(tokens, idx);
        dfa = concat(dfa, nextDfa);
    end

end

function [dfa, idx] = parseFactor(tokens, idx)
    % Factor := Atom { '*' }  (Kleene is postfixed, may be multiple)
    [dfa, idx] = parseAtom(tokens, idx);
    n = numel(tokens);

    while idx <= n && strcmp(tokens{idx}, '*')
        idx = idx + 1;
        dfa = kleene(dfa);
    end

end

function [dfa, idx] = parseAtom(tokens, idx)
    % Atom := '(' Expr ')' | '∅' | symbol
    n = numel(tokens);

    if idx > n
        error("Parse error: atom esperado pero fin de tokens");
    end

    tok = tokens{idx};

    if strcmp(tok, '(')
        idx = idx + 1;
        [dfa, idx] = parseExpr(tokens, idx);

        if idx > n ||~strcmp(tokens{idx}, ')')
            error("Parse error: se esperaba ')'");
        end

        idx = idx + 1;
        return;
    elseif strcmp(tok, '∅')
        dfa = dfaEmptySet();
        idx = idx + 1;
        return;
    else
        % símbolo del alfabeto (cualquier otro char)
        dfa = dfaSymbol_unique(tok); % crea DFA para símbolo con nombres de estado únicos
        idx = idx + 1;
        return;
    end

end

%% ----------------------
%% CREATORS / HELPERS (generan DFAs base con nombres únicos)
function dfa = dfaSymbol_unique(symbol)
    % genera un DFA para un símbolo con nombres de estado únicos (usa state_id)
    global state_id;
    s = ['q' num2str(state_id)]; state_id = state_id + 1;
    f = ['q' num2str(state_id)]; state_id = state_id + 1;

    dfa.K = {s, f};
    dfa.A = {symbol};
    dfa.s = s;
    dfa.F = {f};
    dfa.t = {{s, symbol, f}};
end

function dfa = dfaEmptySet()
    dfa.K = {"q_empty"}; % nombre fijo pero normalmente no se concatenará tal cual
    dfa.A = {};
    dfa.s = "q_empty";
    dfa.F = {};
    dfa.t = {};
end

function dfa = dfaEpsilon()
    dfa.K = {"q_eps"};
    dfa.A = {};
    dfa.s = "q_eps";
    dfa.F = {"q_eps"};
    dfa.t = {}; % sin transiciones necesarias
end

%% ----------------------
%% OPERACIONES (usamos tus reglas implementadas)
% union, concat, kleene, replaceStateTransitions tal como definiste.
% (Copiar/usar tus implementaciones; aquí incluyo versiones compatibles.)

function dfaU = union(dfa1, dfa2)
    q_new = ['q' num2str(getNextId()) '_union'];

    K1 = setdiff(dfa1.K, {dfa1.s});
    K2 = setdiff(dfa2.K, {dfa2.s});
    dfaU.K = [{q_new}, K1, K2];

    if isempty(dfa1.A) && isempty(dfa2.A)
        dfaU.A = {};
    else
        dfaU.A = unique([dfa1.A, dfa2.A]);
    end

    dfaU.s = q_new;

    t1 = replaceStateTransitions(dfa1.t, dfa1.s, q_new);
    t2 = replaceStateTransitions(dfa2.t, dfa2.s, q_new);
    dfaU.t = [t1, t2];

    s1_was_final = ismember(dfa1.s, dfa1.F);
    s2_was_final = ismember(dfa2.s, dfa2.F);

    if ~s1_was_final &&~s2_was_final

        if isempty(dfa1.F) && isempty(dfa2.F)
            dfaU.F = {};
        else
            dfaU.F = unique([dfa1.F, dfa2.F]);
        end

    else
        F1_noinit = setdiff(dfa1.F, {dfa1.s});
        F2_noinit = setdiff(dfa2.F, {dfa2.s});
        dfaU.F = unique([{q_new}, F1_noinit, F2_noinit]);
    end

end

function dfaC = concat(dfa1, dfa2)
    K2 = setdiff(dfa2.K, {dfa2.s});
    dfaC.K = unique([dfa1.K, K2]);

    if isempty(dfa1.A) && isempty(dfa2.A)
        dfaC.A = {};
    else
        dfaC.A = unique([dfa1.A, dfa2.A]);
    end

    dfaC.s = dfa1.s;

    t1 = dfa1.t;
    t2 = replaceStateTransitions(dfa2.t, dfa2.s, dfa1.s);
    dfaC.t = [t1, t2];

    if ismember(dfa2.s, dfa2.F)
        F2_noinit = setdiff(dfa2.F, {dfa2.s});
        dfaC.F = unique([dfa1.F, F2_noinit]);
    else
        dfaC.F = dfa2.F;
    end

end

function dfaS = kleene(dfa)
    % implementa la estrella clásica con ε
    base = [dfa.s '_star'];
    q_new = base;
    k = 1;

    while ismember(q_new, dfa.K)
        q_new = [base num2str(k)];
        k = k + 1;
    end

    dfaS.K = [{q_new}, dfa.K];
    dfaS.A = unique([dfa.A, {"ε"}]);
    dfaS.s = q_new;
    dfaS.F = unique([dfa.F, {q_new}]);

    T = dfa.t;
    T{end + 1} = {q_new, "ε", dfa.s};

    for i = 1:numel(dfa.F)
        f = dfa.F{i};
        T{end + 1} = {f, "ε", dfa.s};
    end

    dfaS.t = uniqueTransitions(T);
end

function t_union = replaceStateTransitions(t, oldState, newState)
    t_union = {};

    for i = 1:numel(t)
        tr = t{i};
        from = tr{1};
        symb = tr{2};
        to = tr{3};

        if strcmp(from, oldState)
            from = newState;
        end

        if strcmp(to, oldState)
            to = newState;
        end

        t_union{end + 1} = {from, symb, to};
    end

end

%% ----------------------
%% UTILIDADES

function id = getNextId()
    global state_id;
    id = state_id;
    state_id = state_id + 1;
end

function Tuniq = uniqueTransitions(T)
    Tuniq = {};
    keys = {};

    for i = 1:numel(T)
        tr = T{i};
        from = tr{1}; sym = tr{2}; to = tr{3};
        key = [from '|' sym '|' to];

        if ~any(strcmp(keys, key))
            keys{end + 1} = key;
            Tuniq{end + 1} = tr;
        end

    end

end

%% ----------------------
%% EXPORT DOT (formatautomaton)
function formatautomaton(dfa, filename)
    fid = fopen(filename, 'w');
    if fid == -1, error('No se puede abrir %s', filename); end

    fprintf(fid, 'digraph finite_state_machine {\n');
    fprintf(fid, '  rankdir=LR;\n');
    fprintf(fid, '  node [shape=point]; qi;\n');
    fprintf(fid, '  qi -> %s;\n', dfa.s);
    % finales
    for i = 1:numel(dfa.F)
        fprintf(fid, '  %s [shape=doublecircle];\n', dfa.F{i});
    end

    % transiciones
    for i = 1:numel(dfa.t)
        tr = dfa.t{i};
        fprintf(fid, '  %s -> %s [ label = "%s" ];\n', tr{1}, tr{3}, tr{2});
    end

    fprintf(fid, '}\n');
    fclose(fid);
end
