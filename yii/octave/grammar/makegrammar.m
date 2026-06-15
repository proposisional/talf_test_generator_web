function grammar = makegrammar(typegrammar, N, T)
    ## grammar = makegrammar(typegrammar, N, T)
    ##
    ## Make a grammar of a given type (0..3).
    ## Optionally, non-terminal and terminal alphabets can be provided as arguments.
    ##
    ## Examples:
    ##   grammar = makegrammar(2);
    ##   grammar = makegrammar(0, 'ABC', '01');
    ##
    ## =========================================================================
    ##
    ##   fjv, 08/11/2022   GNU GPL v3.0
    ##
    ## =========================================================================

    addpath("../util");

    maxrules = 5;

    if !exist('N', 'var')
        # non-terminal alphabet
        N = 'A':'G';
    end

    if !exist('T', 'var')
        # terminal alphabet
        T = 'a':'g';
    end

    function prettyprintgrammar(grammar)

        fprintf(stderr, "type %d: (", typegrammar);

        # print N
        fprintf(stderr, "{");

        for idsymbol = 1:numel(grammar.N) - 1
            fprintf(stderr, "%s, ", grammar.N(idsymbol));
        end

        fprintf(stderr, "%s}, ", grammar.N(end));

        # print T
        fprintf(stderr, "{");

        for idsymbol = 1:numel(grammar.T) - 1
            fprintf(stderr, "%s, ", grammar.T(idsymbol));
        end

        fprintf(stderr, "%s}, ", grammar.T(end));

        # print P
        fprintf(stderr, "{");

        for idrule = 1:size(grammar.P, 1) - 1
            leftside = grammar.P{idrule, 1};
            rightside = grammar.P{idrule, 2};
            fprintf(stderr, "(%s, %s), ", leftside, rightside);
        end

        leftside = grammar.P{end, 1};
        rightside = grammar.P{end, 2};
        fprintf(stderr, "(%s, %s)}", leftside, rightside);

        # print P
        fprintf(stderr, ", %s)\n", grammar.S);
    end

    # alphabets
    grammar.N = N;
    grammar.T = T;

    # generate random rule types, make sure there is a rule of the lowest type
    do
        ruletypes = ceil((3 - typegrammar + 1) * rand(1, ceil(maxrules * rand))) + typegrammar - 1;
    until !isempty(find(ruletypes == typegrammar))

    # case of regular grammar
    if typegrammar == 3
        # chose a side, left or right
        if rand < 0.5
            type3 = 'right-regular';
        else
            type3 = 'left-regular';
        end

    end

    # generate random rules
    for idrule = 1:numel(ruletypes)

        do
            # case of regular grammar
            if typegrammar == 3
                # make sure the rule fits that type
                do
                    rule = makerule(ruletypes(idrule), N, T, false);
                until strcmp(rule.type.name, type3) || strcmp(rule.type.name, 'terminal-regular')

            else
                # rules of types 0, 1 and 2
                rule = makerule(ruletypes(idrule), N, T, false);
            end

            # check if rule already exists
            isnewrule = true;

            for idpastrule = 1:idrule - 1

                if strcmp(grammar.P{idpastrule, 1}, rule.side{1}) && ...
                        strcmp(grammar.P{idpastrule, 2}, rule.side{2})
                    isnewrule = false;
                    break
                end

            end

        until isnewrule

        grammar.P{idrule, 1} = rule.side{1};
        grammar.P{idrule, 2} = rule.side{2};
    end

    # random axiom
    grammar.S = N(ceil(rand * numel(N)));

    prettyprintgrammar(grammar);

end
