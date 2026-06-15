function jsonQ = grammar(typegrammar)

    if nargin < 1
        typegrammar = 1;
    end

    N = 'ABC';
    T = '01';

    grammar = makegrammar(typegrammar, N, T);

    q1.title = printGrammarLatex(grammar);
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end
