function result = turingmachine(turingmachinename, tape, outputformat, randomseed)
    %  turingmachine(turingmachinename, tape, outputformat, randomseed)
    %
    %  Computation for a given Turing machine and tape expression.
    %  The machine behaves deterministically and it is defined
    %  in a JSON file, like this:
    %
    %  {
    %    "matrix" : [["q0", "*", "*", "q1"],
    %                ["q0", "|", "l", "q1"],
    %                ["q1", "*", "r", "q1"],
    %                ["q1", "|", "h", "q1"]]
    %  }
    %
    %  It is assumed that q0 is the initial state, that the cell with index
    %  0 is the first symbol in the input tape and that the head points to
    %  the last symbol in the input tape.
    %
    %  It works in ANSI/VT100 terminals, where colors are allows as scape
    %  sequences.
    %
    %  The outputformat values can be checked in the prettyprint script.
    %
    %  For example:
    %
    %    >> turingmachine("add", "*|||*|||*")
    %
    %    ({q0,q1,q2,q3,q4},q0,{|},
    %     {(q0,*,l),(q0,|,|),(q1,*,|),(q1,|,l),(q2,*,l),(q2,|,r),(q3,*,l),(q3,|,*),(q4,*,h),(q4,|,*)},
    %     {(q0,*,q1),(q0,|,q0),(q1,*,q2),(q1,|,q1),(q2,*,q3),(q2,|,q2),(q3,*,q4),(q3,|,q3),(q4,*,q4),(q4,|,q4)})
    %
    %    (q0, *|||*|||*, 9) ⊢ (q1, *|||*|||*, 8) ⊢ (q1, *|||*|||*, 7) ⊢ (q1, *|||*|||*, 6) ⊢ (q1, *|||*|||*, 5) ⊢
    %    (q2, *|||||||*, 5) ⊢ (q2, *|||||||*, 6) ⊢ (q2, *|||||||*, 7) ⊢ (q2, *|||||||*, 8) ⊢ (q2, *|||||||*, 9) ⊢
    %    (q3, *|||||||*, 8) ⊢ (q3, *||||||**, 8) ⊢ (q4, *||||||**, 7) ⊢ (q4, *|||||***, 7)
    %
    %    >> turingmachine("successorbinary", "*11*")
    %    q0 * l q1
    %    q0 0 0 q0
    %    q0 1 1 q0
    %    q1 * 1 q3
    %    q1 0 1 q2
    %    q1 1 l q1
    %    q2 * h q3
    %    q2 0 0 q2
    %    q2 1 r q2
    %    q3 * l q4
    %    q3 0 0 q0
    %    q3 1 r q4
    %    q4 * h q4
    %    q4 0 r q4
    %    q4 1 0 q4
    %
    %    (q0, *11*, 4) ⊢ (q1, *11*, 3) ⊢ (q1, *11*, 2) ⊢ (q1, *11*, 1) ⊢
    %    (q3, 111*, 1) ⊢ (q4, 111*, 2) ⊢ (q4, 101*, 2) ⊢ (q4, 101*, 3) ⊢
    %    (q4, 100*, 3) ⊢ (q4, 100*, 4)
    %
    % ===============================================================
    %
    %   fjv, 30/11/2021   GNU GPL v3.0
    %   fjv, 18/12/2021   loading transferred to prettyprint
    %
    % ===============================================================

    transitionsymbol = "⊢";

    ## check if called from LuaTex and adapt special characters
    files = dbstack;
    caller = files(end).file;

    # TBD: import string `runexample.m` from configuration file
    callingfromscript = strfind(caller, "runexample.m");

    ## steps to check by user
    timetocheck = 100;

    if !exist('outputformat', 'var')
        outputformat = 'table';
    end

    ## get the machine elements and print it out
    [states, alphabet, instructionfunction, nextstatefunction, initialstate, emptysymbol, matrix] = prettyprint(turingmachinename, outputformat);

    ## define initial head position
    headposition = numel(tape);

    ## tape stores the expression and the integer index to the first symbol
    content = tape;
    clear("tape");
    tape.content = content;
    clear("content");
    ## the first cell of the tape is indexed as 1, this can shift to negative integers
    tape.indexfirstcell = 1;

    ## define initial configuration
    initialconfiguration = {initialstate, tape, headposition};

    currentconfiguration = initialconfiguration;

    if !strcmp(outputformat, "none")
        fprintf(" \n");
        printconfiguration(currentconfiguration);
    end

    steps = 0;

    do
        ## check if user cancelling in case of possible infinite loop
        if mod(++steps, timetocheck) == 0
            fprintf("\nTime complexity is rising high, press Ctrl-C to stop, other key to continue...\n");
            pause;
        end

        ## compute while a transition can be done
        [nextconfiguration, unabletotransit] = transit(matrix, currentconfiguration);

        if !unabletotransit

            if !strcmp(outputformat, "none")
                fprintf(" %s ", transitionsymbol);
                printconfiguration(nextconfiguration);
            end

            currentconfiguration = nextconfiguration;
        end

    until unabletotransit;

    if !strcmp(outputformat, "none")
        fprintf("\n");
    end

    ## return tape and cell
    result = {currentconfiguration{2}, currentconfiguration{3}};

    function [nextconfiguration, unabletotransit] = transit(matrix, currentconfiguration)
        ## transit from current to next configuration, if possible

        ## search for the selected line
        [instruction, nextstate] = currentline(matrix, ...
            currentconfiguration{1}, ...
            tapeexpression(currentconfiguration{2}, currentconfiguration{3}));
        nextconfiguration{1} = nextstate;
        nextconfiguration{2} = currentconfiguration{2};
        unabletotransit = false;
        ## execute instruction
        switch (instruction)
                ## 'right' instruction
            case 'r'
                nextconfiguration{3} = currentconfiguration{3} + 1;
                ## check boundary condition for the tape
                lastcell = numel(nextconfiguration{2}.content) + nextconfiguration{2}.indexfirstcell - 1;

                if nextconfiguration{3} > lastcell
                    ## add emptysymbol to the right
                    nextconfiguration{2}.content = strcat(currentconfiguration{2}.content, emptysymbol);
                end

                ## 'left' instruction
            case 'l'
                nextconfiguration{3} = currentconfiguration{3} - 1;
                ## check boundary condition for the tape
                if nextconfiguration{3} < nextconfiguration{2}.indexfirstcell
                    ## add emptysymbol to the left
                    nextconfiguration{2}.content = strcat(emptysymbol, currentconfiguration{2}.content);
                    nextconfiguration{2}.indexfirstcell--;
                end

                ## 'halt' instruction
            case
                'h' unabletotransit = true;

                ## 'write' instruction
            otherwise
                nextconfiguration{2} = writesymbol(currentconfiguration{2}, currentconfiguration{3}, instruction);
                nextconfiguration{3} = currentconfiguration{3};
                ## add empty symbol to the left if the first symbol is not empty
                if !strcmp(nextconfiguration{2}.content(1), emptysymbol)
                    nextconfiguration{2}.content = strcat(emptysymbol, nextconfiguration{2}.content);
                    nextconfiguration{2}.indexfirstcell--;
                end

                ## add empty symbol to the right if the last symbol is not empty
                if !strcmp(nextconfiguration{2}.content(end), emptysymbol)
                    nextconfiguration{2}.content = strcat(nextconfiguration{2}.content, emptysymbol);
                end

        end

    end

    function [instruction, nextstate] = currentline(matrix, currentstate, observedsymbol)

        for idline = 1:numel(matrix)

            if strcmp(matrix{idline}{1}, currentstate) && ...
                    strcmp(matrix{idline}{2}, observedsymbol)
                instruction = matrix{idline}{3};
                nextstate = matrix{idline}{4};
                break;
            end

        end

    end

    function symbol = tapeexpression(tape, headposition)

        ## index is mapped as to match current cell with respect to the first cell
        ## example:
        ##     *|||*  indexfirstcell =  1
        ##     12345  tape(5) = 5 - 1 + 1 = 5
        ##   ***|||*  indexfirstcell = -1
        ##  -1012345  tape(5) = 5 + 1 + 1 = 7
        symbol = tape.content(headposition - tape.indexfirstcell + 1);
    end

    function tape = writesymbol(tape, position, symbol)

        tape.content(position - tape.indexfirstcell + 1) = symbol;
    end

    function printconfiguration(configuration)
        ## print formatted configuration

        tape = configuration{2}.content;
        head = configuration{3} - configuration{2}.indexfirstcell + 1;

        if !strcmp(outputformat, "none")
            fprintf("(%s, ", configuration{1});
            fprintf("%s", tape(1:head - 1));

            if callingfromscript
                fprintf("\\underline{%s}", tape(head));
            else
                system(['echo -n "\e[4m', tape(head), '\e[0m"']);
            end

            fprintf("%s, %d)", tape(head + 1:end), configuration{3});
        end

    end

end
