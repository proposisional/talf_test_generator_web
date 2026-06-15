function G = prettyprintgrammar(G, outputformat)
    % G = prettyprintgrammar(G, outputformat)
    %
    % Prints out a formatted grammar, either a string of plain ASCII or LaTeX,
    % returns the four elements of the grammar.
    %   outputformat : "text" (default) / "string" / "stringLaTeX" / "none"
    %
    % For example:
    %
    %    >> prettyprint("add")
    %    q0 * l q1
    %    q0 | | q0
    %    q1 * | q2
    %    q1 | l q1
    %    q2 * l q3
    %    q2 | r q2
    %    q3 * l q4
    %    q3 | * q3
    %    q4 * h q4
    %    q4 | * q4
    %
    %    >> prettyprint("add", "string");
    %    ({q0,q1,q2,q3,q4},q0,{|},
    %     {(q0,*,l),(q0,|,|),(q1,*,|),(q1,|,l),(q2,*,l),(q2,|,r),(q3,*,l),(q3,|,*),(q4,*,h),(q4,|,*)},
    %     {(q0,*,q1),(q0,|,q0),(q1,*,q2),(q1,|,q1),(q2,*,q3),(q2,|,q2),(q3,*,q4),(q3,|,q3),(q4,*,q4),(q4,|,q4)})
    %
    % ===============================================================
    %
    %   fjv, 21/09/2023   GNU GPL v3.0
    %
    % ===============================================================

    ## database of Turing machines
    turingmachinesdatabasename = 'turingmachines';

    addpath("../util/");

    arrow = '→';
    epsilon = 'ε';

    if ischar(G)
        ## load grammar definition from file
        G = loadgrammar(G, 'none');
    elseif !isstruct(G)
        error("Wrong grammar...");
    end

    ## normal table by default
    if !exist('outputformat', 'var')
        outputformat = 'text';
    end

    ## print out grammar

    switch outputformat
        case 'text'
            fprintf('(\n');
            ## print N
            fprintf('  {');
            fprintf("%s", G.N{1});

            for idsymbol = 2:numel(G.N)
                fprintf(", %s", G.N{idsymbol});
            end

            fprintf('},\n');
            ## print T
            fprintf('  {');
            fprintf("%s", G.T{1});

            for idsymbol = 2:numel(G.T)
                fprintf(", %s", G.T{idsymbol});
            end

            fprintf('},\n');
            ## print P
            fprintf('  {\n');

            for idrule = 1:size(G.P, 2)
                leftside = G.P{idrule}{1};
                rightside = G.P{idrule}{2};

                if isempty(rightside)
                    rightside = epsilon;
                end

                fprintf("    %s %s %s\n", leftside, arrow, rightside);
            end

            fprintf('  },\n');
            ## print S
            fprintf('  %s\n', G.S);
            fprintf(')\n');

        case 'LaTeX'
            fprintf('(\n');
            ## print N
            ##   spaces are Em Quad (U+2001) characters here
            fprintf('  \\{');
            fprintf("%s", G.N{1});

            for idsymbol = 2:numel(G.N)
                fprintf(", %s", G.N{idsymbol});
            end

            fprintf('\\},\n');
            ## print T
            fprintf('  \\{');
            fprintf("%s", G.T{1});

            for idsymbol = 2:numel(G.T)
                fprintf(", %s", G.T{idsymbol});
            end

            fprintf('\\},\n');
            ## print P
            fprintf('  \\{\n');

            for idrule = 1:size(G.P, 2)
                leftside = G.P{idrule}{1};
                rightside = G.P{idrule}{2};

                if isempty(rightside)
                    rightside = epsilon;
                end

                fprintf("    %s %s %s\n", leftside, arrow, rightside);
            end

            fprintf('  \\},\n');
            ## print S
            fprintf('  %s\n', G.S);
            fprintf(')\n');

        case 'string'
            fprintf('( ');
            ## print N
            fprintf('{');
            fprintf("%s ", G.N{1});

            for idsymbol = 2:numel(G.N)
                fprintf(", %s", G.N{idsymbol});
            end

            fprintf('}, ');
            ## print T
            fprintf('{');
            fprintf("%s", G.T{1});

            for idsymbol = 2:numel(G.T)
                fprintf(", %s", G.T{idsymbol});
            end

            fprintf('}, ');
            ## print P
            fprintf('{ ');

            for idrule = 1:size(G.P, 2)
                leftside = G.P{idrule}{1};
                rightside = G.P{idrule}{2};

                if isempty(rightside)
                    rightside = epsilon;
                end

                fprintf("(%s, %s)", leftside, rightside);

                if idrule < size(G.P, 1)
                    fprintf(", ");
                end

            end

            fprintf(' }, ');
            ## print S
            fprintf('%s', G.S);
            fprintf(' )\n');

        case 'stringLaTeX'
            fprintf('$$( ');
            ## print N
            fprintf('\\{');
            fprintf("%s ", G.N{1});

            for idsymbol = 2:numel(G.N)
                fprintf(", %s", G.N{idsymbol});
            end

            fprintf('\\}, ');
            ## print T
            fprintf('\\{');
            fprintf("%s", G.T{1});

            for idsymbol = 2:numel{G.T}
                fprintf(", %s", G.T{idsymbol});
            end

            fprintf('\\}, ');
            ## print P
            fprintf('\\{');

            for idrule = 1:size(G.P, 2)
                leftside = G.P{idrule}{1};
                rightside = G.P{idrule}{2};

                if isempty(rightside)
                    rightside = epsilon;
                end

                fprintf("(%s, %s)", leftside, rightside);

                if idrule < size(G.P, 1)
                    fprintf(", ");
                end

            end

            fprintf('\\}, ');
            ## print S
            fprintf('%s', G.S);
            fprintf(' )$$\n');

        case 'none'

        otherwise
            error("Wrong output format...");
    end

end
