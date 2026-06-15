 function automaton = CFG2NPA(grammar)
% npa = CFG2NPA(cfg)
%
% Finds an NPA equivalent to a given CFG.
%
%
% For example:
%
%    >> finiteautomaton("aa*bb*", "ab")
%
%    M = ( {q0, q1, q2}, {a, b}, {(q0, a, q1), (q1, a, q1), (q1, b, q2), (q2, b, q2)}, q0, {q0, q1, q2} )
%
%    w = ab
%
%    (q0, ab) ⊢ (q1, b) ⊢ (q2, ε)
%
%    w ∈ 𝓛(M)
%
%    >> finiteautomaton("aa*bb*", "ab", "LaTeX")
% ===============================================================
%
%   fjv, 13/10/2023   GNU GPL v3.0
%
% ===============================================================

  addpath('../grammar/');
  grammar = loadgrammar(grammar);

  %p,e,e  q,s
  %q,e,A  q,alpha  A->alpha
  %q,a,a  q,e

  %N={E}
  %T={0,1,),(,∅,+,*}
  %P={
  %E->∅,
  %E->0,
  %E->1,
  %E->(EE),
  %E->(E+E),
  %E->E*
  %}
  %S=E
grammar.P
grammar.T
  # STATES
  automaton.K = {'q0','q1'};
  # STRING ALPHABET
  automaton.I = {};
  for symbol = grammar.T
    automaton.I = [automaton.I, symbol];
  end
  # STACK ALPHABET
  automaton.S = automaton.I;
  for symbol = grammar.N
    automaton.S = [automaton.S, symbol];
  end
  # INITIAL STATE
  automaton.s = 'q0';
  # FINAL STATE
  automaton.F = 'q1';
  # TRANSITION RELATION
  automaton.t = {{{'q0','ε','ε'}, {'q1',grammar.S}}};
  for rule = grammar.P
  rule
    automaton.t = [automaton.t, {{{'q1','ε',rule{1}}, {'q1',rule{1}}}}];
  end
  for symbol = grammar.T
  symbol
    automaton.t = [automaton.t, {{{'q1',symbol,symbol}, {'q1','ε'}}}];
  end

  %      "K" : ["q0", "q1"],
  %      "I" : ["0", "1", "*", "+", "(", ")"],
  %      "S" : ["0", "1", "*", "+", "(", ")", "E"],
  %      "s" : "q0",
  %      "F" : ["q1"],
  %      "t" : [[["q0", "ε", "ε"],["q1", "E"]],
  %             [["q1", "ε", "E"],["q1", "∅"]],
  %             [["q1", "ε", "E"],["q1", "0"]],
  %             [["q1", "ε", "E"],["q1", "1"]],
  %             [["q1", "ε", "E"],["q1", "(EE)"]],
  %             [["q1", "ε", "E"],["q1", "(E+E)"]],
  %             [["q1", "ε", "E"],["q1", "E*"]],
  %             [["q1", "0", "0"],["q1", "ε"]],
  %             [["q1", "1", "1"],["q1", "ε"]],
  %             [["q1", "(", "("],["q1", "ε"]],
  %             [["q1", ")", ")"],["q1", "ε"]],
  %             [["q1", "+", "+"],["q1", "ε"]],
  %             [["q1", "*", "*"],["q1", "ε"]]]

end
