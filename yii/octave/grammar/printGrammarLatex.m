function out = printGrammarLatex(G)

    if !isstruct(G) ||!isfield(G, 'N') ||!isfield(G, 'T') ||!isfield(G, 'P') ||!isfield(G, 'S')
        error("printGrammarLatex: expected a struct with fields N, T, P, S");
    end

    N = normalizeAlphabet(G.N);
    T = normalizeAlphabet(G.T);
    P = normalizeProductions(G.P);
    S = normalizeSymbol(G.S);

    out = sprintf('$$G = (%s, \\ %s, \\ %s, \\ %s)$$', latexSet(N), latexSet(T), latexProductionSet(P), latexSymbol(S));
end

function symbols = normalizeAlphabet(alpha)

    if iscell(alpha)
        symbols = alpha;
        return;
    end

    if ischar(alpha)
        symbols = arrayfun(@(c) char(c), alpha(:).', 'UniformOutput', false);
        return;
    end

    error('printGrammarLatex: alphabet must be a char vector or a cell array of strings');
end

function s = normalizeSymbol(sym)

    if ischar(sym)
        s = sym;
    elseif iscell(sym) && numel(sym) == 1 && ischar(sym{1})
        s = sym{1};
    else
        error('printGrammarLatex: S must be a string');
    end

end

function Pout = normalizeProductions(P)

    if !iscell(P)
        error('printGrammarLatex: P must be a cell array');
    end

    if isempty(P)
        Pout = cell(0, 2);
        return;
    end

    if columns(P) == 2
        Pout = P;
        return;
    end

    if iscell(P{1}) && numel(P{1}) == 2
        Pout = cell(numel(P), 2);

        for i = 1:numel(P)
            Pout{i, 1} = P{i}{1};
            Pout{i, 2} = P{i}{2};
        end

        return;
    end

    error('printGrammarLatex: unsupported P structure');
end

function s = latexSymbol(x)
    s = latexEscape(toString(x));
    s = strrep(s, 'ε', '\\varepsilon');
end

function out = latexSet(symbols)

    if isempty(symbols)
        out = '\\{\\}';
        return;
    end

    escaped = cellfun(@(x) latexSymbol(x), symbols, 'UniformOutput', false);
    out = ['\{', strjoin(escaped, ', '), '\}'];
end

function out = latexProductionSet(P)

    if isempty(P)
        out = '\\{\\}';
        return;
    end

    tuples = cell(size(P, 1), 1);

    for i = 1:size(P, 1)
        lhs = latexSymbol(P{i, 1});
        rhs = latexSymbol(P{i, 2});

        if isempty(strtrim(rhs))
            rhs = '\\varepsilon';
        end

        tuples{i} = ['(', lhs, ', ', rhs, ')'];
    end

    out = ['\{', strjoin(tuples, ', '), '\}'];
end

function out = productionPairsText(P)

    if isempty(P)
        out = '';
        return;
    end

    tuples = cell(size(P, 1), 1);

    for i = 1:size(P, 1)
        lhs = toString(P{i, 1});
        rhs = toString(P{i, 2});

        if isempty(strtrim(rhs))
            rhs = 'ε';
        end

        tuples{i} = ['(', lhs, ', ', rhs, ')'];
    end

    out = ['{', strjoin(tuples, ', '), '}'];
end

function s = toString(x)

    if ischar(x)
        s = x;
        return;
    end

    if iscell(x) && numel(x) == 1 && ischar(x{1})
        s = x{1};
        return;
    end

    if isnumeric(x)
        s = num2str(x);
        return;
    end

    try
        s = char(x);
    catch
        error('printGrammarLatex: value cannot be converted to string');
    end

end

function s = latexEscape(s)
    s = strrep(s, '\\', '\\textbackslash{}');
    s = strrep(s, '_', '\\_');
    s = strrep(s, '%', '\\%');
    s = strrep(s, '$', '\\$');
    s = strrep(s, '#', '\\#');
    s = strrep(s, '&', '\\&');
    s = strrep(s, '{', '\\{');
    s = strrep(s, '}', '\\}');
    s = strrep(s, '^', '\\^{}');
    s = strrep(s, '~', '\\~{}');
end
