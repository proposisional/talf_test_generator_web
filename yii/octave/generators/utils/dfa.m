function jsonQ = dfa(sigma)

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

    automata = randomautomaton(alphabet, randi([3, 8]), 'DFA');
    q1.image = dotToSvg(automata, 'nfa');
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end
