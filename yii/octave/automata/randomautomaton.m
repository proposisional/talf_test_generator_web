function automaton = randomautomaton(alphabet, numberstates, automatontype, probabilityfinalstate)
    #
    # randomautomaton(alphabet, numberstates, automatontype, probabilityfinalstate)
    #
    # optional: automatontype, probabilityfinalstate
    #
    # Generates a random automaton and its graph in DOT format.
    # The automaton can be either DFA, NFA or NPDA, and it is
    # defined in a JSON file (for further use), like this:
    #
    #   {
    #     "K" : ["q0", "q1", "q2"],
    #     "A" : ["a", "b"],
    #     "s" : "q0",
    #     "F" : ["q2"],
    #     "t" : [["q0", "a", "q1"],
    #            ["q1", "a", "q1"],
    #            ["q1", "b", "q2"],
    #            ["q2", "b", "q2"]]
    #   }
    #
    # examples
    #   randomautomaton({'0', '1'}, 5)
    #   randomautomaton({'a', 'b', 'c'}, 8, 'NFA')
    #   randomautomaton({'|'}, 10, 'DFA', 0.3)
    #
    #=============================================================
    #
    #   fjv, 08/02/2022   GNU GPL v3.0
    #
    #=============================================================

    addpath("../util/jsonlab/");

    #  emptystring      = "ε";
    emptystring = "*";
    transitionsymbol = "⊢";

    probabilityfinalstate = 0.5;
    factorstatestransitions = 2;

    if nargin < 2
        error("Calling format: randomfiniteautomata(alphabet, numerstates, automatontype, probabilityfinalstate)");
    end

    # determine if DFA (default), NFA or NPDA
    if !exist('automatontype', 'var')
        automatontype = 'DFA';
    else

        if !ismember(automatontype, {'DFA', 'NFA', 'NPDA'})
            error("Type of automaton must be either 'DFA', 'NFA' or 'NPDA'");
        end

    end

    # create list of states and final states
    states = {'q0'};
    finalstates = {};

    for stateid = 1:numberstates - 1
        statename = sprintf("q%d", stateid);
        states{end + 1} = statename;

        if rand > probabilityfinalstate
            finalstates{end + 1} = statename;
        end

    end

    # make the first final if no one selected
    if isempty(finalstates)
        finalstates = {states{1}};
    end

    # create transitions
    transitions = {};

    if strcmp(automatontype, 'DFA')
        # DFA's transition function
        for stateid = 1:numel(states)

            for symbolid = 1:numel(alphabet)
                randomstate = states{ceil(numberstates * rand)};
                transitions{end + 1} = {states{stateid}, alphabet{symbolid}, randomstate};
            end

        end

    elseif strcmp(automatontype, 'NFA')
        # NFA's transition application
        # transitions as a Poissonian function of number of states
        numbertransitions = randp(factorstatestransitions * numel(states));

        for transitionid = 1:numbertransitions
            sourcerandomstate = states{ceil(numberstates * rand)};
            targetrandomstate = states{ceil(numberstates * rand)};
            transitions{end + 1} = {sourcerandomstate, randomstring(alphabet), targetrandomstate};
        end

    else
        # NPDA's transition application
        # transitions as a Poissonian function of number of states
        numbertransitions = randp(factorstatestransitions * numel(states));

        for transitionid = 1:numbertransitions
            sourcerandomstate = states{ceil(numberstates * rand)};
            targetrandomstate = states{ceil(numberstates * rand)};
            transitions{end + 1} = {sourcerandomstate, ...
                                    cstrcat(randomstring(alphabet, 1), '/', randomstring(alphabet, 1), '/', randomstring(alphabet, 1)), ...
                                    targetrandomstate};
        end

    end

    # create automaton
    automaton = struct();
    automaton = setfield(automaton, 'K', states);
    automaton = setfield(automaton, 'A', alphabet);
    automaton = setfield(automaton, 's', 'q0');
    automaton = setfield(automaton, 'F', finalstates);
    automaton = setfield(automaton, 't', transitions);

    savejson('', automaton, 'randomautomaton.json');

    function string = randomstring(alphabet, meanstringlenght)
        # generate a random string

        if !exist('meanstringlenght', 'var')
            meanstringlenght = 2;
        end

        # length of string with Poissonian distribution
        stringlenght = randp(meanstringlenght);

        if stringlenght == 0
            string = emptystring;
        else
            # generate random indexes and get symbols from alphabet
            string = char(alphabet(ceil(numel(alphabet) * rand(1, stringlenght))){:})';
        end

    end

end
