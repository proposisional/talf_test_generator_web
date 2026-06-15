function jsonQ = nfa(sigma)

    if nargin < 1
        sigma = 1;
    end

    if sigma == 1
        alphabet = {'a', 'b', 'c'};
    elseif sigma == 2
        alphabet = {'0', '1'};
    else
        alphabet = {'|'};
    end

    automata = randomautomaton(alphabet, randi([3, 8]), 'NFA');
    q1.title = "";
    q1.image = dotToSvg(automata, 'nfa');
    q1.stem = "";
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end
