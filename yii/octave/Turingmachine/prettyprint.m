function [states, alphabet, instructionfunction, nextstatefunction, initialstate, emptysymbol, matrix] = prettyprint(turingmachinename, outputformat)
    % prettyprint(turingmachinename, outputformat)
    %
    % Prints out a formatted table, either a string of plain ASCII or LaTeX,
    % returns the elements of the machine.
    %   outputformat : "table" (default) / "string" / "stringLaTeX" / "LaTeX" / "graphLaTeX" / "none"
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
    %   fjv, 18/12/2021   GNU GPL v3.0
    %   fjv, 02/01/2022   load Turing Machine from database
    %
    % ===============================================================

    ## database of Turing machines (absolute path to avoid load-path warnings)
    scriptPath = fileparts(mfilename("fullpath"));
    turingmachinesdatabasename = fullfile(scriptPath, 'turingmachines');

    addpath("../util/");

    if ischar(turingmachinename)
        ## load Turing Machine definition from JSON file
        representation = loadrepresentation(turingmachinesdatabasename, turingmachinename);
        matrix = representation.matrix;
    elseif iscell(turingmachinename)
        matrix = turingmachinename;
    else
        error("Wrong input machine...");
    end

    ## normal table by default
    if !exist('outputformat', 'var')
        outputformat = 'table';
    end

    ## get table elements
    ## define the empty symbol
    emptysymbol = matrix{1}{2};

    ## define the alphabet
    alphabet = {};

    for idline = 2:numel(matrix)

        if strcmp(matrix{idline}{2}, emptysymbol)
            ## stop searching when the empty symbol occurs again
            break;
        else
            ## add new symbol to the alphabet
            alphabet{idline - 1} = matrix{idline}{2};
        end

    end

    ## define the set of states
    states = {};

    for idstate = 1:numel(alphabet) + 1:numel(matrix)
        states{end + 1} = matrix{idstate}{1};
    end

    ## define the instruction and next state functions
    instructionfunction = {};
    nextstatefunction = {};

    for idline = 1:numel(matrix)
        ## add new symbol to the alphabet
        instructionfunction{idline} = matrix{idline}{3};
        nextstatefunction{idline} = matrix{idline}{4};
    end

    ## define initial state
    initialstate = states{1};

    ## print out table
    switch outputformat
        case 'string'
            fprintf("({%s", initialstate);

            for idstate = 2:numel(states)
                fprintf(",%s", states{idstate});
            end

            fprintf("},%s,{%s", initialstate, alphabet{1});

            for idsymbol = 2:numel(alphabet)
                fprintf(",%s", alphabet{});
            end

            fprintf("},{(%s,%s,%s)", matrix{1}{1}, matrix{1}{2}, matrix{1}{3});

            for idline = 2:numel(matrix)
                fprintf(",(%s,%s,%s)", matrix{idline}{1}, ...
                    matrix{idline}{2}, ...
                    matrix{idline}{3});
            end

            fprintf("},{(%s,%s,%s)", matrix{1}{1}, matrix{1}{2}, nextstatefunction{1});

            for idline = 2:numel(matrix)
                fprintf(",(%s,%s,%s)", matrix{idline}{1}, ...
                    matrix{idline}{2}, ...
                    matrix{idline}{4});
            end

            fprintf("})\n");

        case 'stringLaTeX'
            fprintf("$$(\\{%s", initialstate);

            for idstate = 2:numel(states)
                fprintf(",%s", states{idstate});
            end

            fprintf("\\},%s,\\{%s", initialstate, alphabet{1});

            for idsymbol = 2:numel(alphabet)
                fprintf(",%s", alphabet{idsymbol});
            end

            fprintf("\\},\\{(%s,%s,%s)", matrix{1}{1}, matrix{1}{2}, matrix{1}{3});

            for idline = 2:numel(matrix)
                fprintf(",(%s,%s,%s)", matrix{idline}{1}, ...
                    matrix{idline}{2}, ...
                    matrix{idline}{3});
            end

            fprintf("\\},\\{(%s,%s,%s)", matrix{1}{1}, matrix{1}{2}, nextstatefunction{1});

            for idline = 2:numel(matrix)
                fprintf(",(%s,%s,%s)", matrix{idline}{1}, ...
                    matrix{idline}{2}, ...
                    matrix{idline}{4});
            end

            fprintf("\\})$$\n");

        case 'table'

            for idline = 1:numel(matrix)
                fprintf("%s %s %s %s\n", matrix{idline}{1}, ...
                    matrix{idline}{2}, ...
                    matrix{idline}{3}, ...
                    matrix{idline}{4});
            end

        case 'LaTeX'
            ## $$\begin{array}{l c c l}
            ## q_0 & * & l & q_0 \\
            ## q_0 & | & * & q_1 \\
            ## q_1 & * & h & q_1 \\
            ## q_1 & | & | & q_1 \\
            ## \end{array}$$
            fprintf("$$\\begin{array}{l c c l}\n");

            for idline = 1:numel(matrix)
                fprintf("%s_%s & %s & %s & %s_%s \\\\\n", matrix{idline}{1}(1), ...
                    matrix{idline}{1}(2:end), ...
                    matrix{idline}{2}, ...
                    matrix{idline}{3}, ...
                    matrix{idline}{4}(1), ...
                    matrix{idline}{4}(2:end));
            end

            fprintf("\\end{array}$$\n");

        case 'graphLaTeX'
            ## $$\begin{tikzpicture}[shorten >=1pt,node distance=4cm,on grid]
            ## \node[state, initial, initial text={Start}, initial distance=1.3cm] (q_0) at (0,0) {$q_0$};
            ## \node[state] 		(q_1) [below of=q_0] 	{$q_1$};
            ## \node[state] 		(q_2) [right of=q_1] 		{$q_2$};
            ## \path
            ##	  		(q_0) 	edge [loop above]   	node      	{$1/1,l$} ()
            ##          		    edge []					 	node		{$0/0,l$} (q_1)
            ##      	(q_1) 	edge [loop left]			node      	{$1/1,l$} ()
            ##               		edge []					 	node		{$0/1,s$} (q_2)
            ## ;
            ## \end{tikzpicture}$$
            halt = "h";

            if (numel(states) > 7)
                fprintf("$$\\begin{tikzpicture}[shorten >=1pt,node distance=3cm,on grid] \n");
            else
                fprintf("$$\\begin{tikzpicture}[shorten >=1pt,node distance=4cm,on grid] \n");
            endif

            fprintf("\\node[state, initial, initial text={Start}, initial distance=1cm] (%s) at (0,0) {$%s$}; \n", initialstate, initialstate);

            for idstate = 2:numel(states)
                % Hacemos que el grafo siga una forma de onda cuadrada
                switch (mod(idstate, 4))
                    case 0
                        fprintf("\\node[state] (%s) [above of=%s] {$%s$}; \n", states{idstate}, states{idstate - 1}, states{idstate});
                    case {1, 3}
                        fprintf("\\node[state] (%s) [right of=%s] {$%s$}; \n", states{idstate}, states{idstate - 1}, states{idstate});
                    case 2
                        fprintf("\\node[state] (%s) [below of=%s] {$%s$}; \n", states{idstate}, states{idstate - 1}, states{idstate});
                endswitch

            endfor

            %Añadimos el estado de parada (H)
            fprintf("\\node[state, accepting] (H) [below of=%s] {$H$}; \n\\path \n", states{numel(states)});
            %Expresamos las aristas de la TM
            cont = 1;

            for idstate = 1:numel(states)
                fprintf("(%s) \n", states{idstate})
                loop = 0;

                for idsymbol = 1:numel(alphabet) + 1

                    switch (matrix{cont}{3})
                        case "h"
                            fprintf("edge [] node {$%s$,$%s$} (H)\n", matrix{cont}{2}, matrix{cont}{3});
                        otherwise

                            if (matrix{cont}{1} == matrix{cont}{4})
                                loop++;

                                if (loop == 1)

                                    if (mod(idstate, 4) == 2 || mod(idstate, 4) == 3)
                                        fprintf("edge [loop below] node {$%s$,$%s$} ()\n", matrix{cont}{2}, ...
                                            matrix{cont}{3});
                                    else
                                        fprintf("edge [loop above] node {$%s$,$%s$} ()\n", matrix{cont}{2}, ...
                                            matrix{cont}{3});
                                    endif

                                else

                                    if (mod(idstate, 4) == 1 || mod(idstate, 4) == 3)
                                        fprintf("edge [loop right] node {$%s$,$%s$} ()\n", matrix{cont}{2}, ...
                                            matrix{cont}{3});
                                    else
                                        fprintf("edge [loop left] node {$%s$,$%s$} ()\n", matrix{cont}{2}, ...
                                            matrix{cont}{3});
                                    endif

                                endif

                            else
                                fprintf("edge [] node {$%s$,$%s$} (%s)\n", matrix{cont}{2}, ...
                                    matrix{cont}{3}, ...
                                    matrix{cont}{4});
                            endif

                    endswitch

                    cont++;
                endfor

            endfor

            fprintf("; \n\\end{tikzpicture}$$ \n");

        case 'none'

        otherwise
            error("Wrong output format...");
    end

end
