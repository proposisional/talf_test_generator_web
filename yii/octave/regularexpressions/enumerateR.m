function expression = enumerateR(alphabet, expressionId, indexType, printExpression)
    # strings = enumerateR(alphabet, expressionId, indexType, printExpression)
    #
    # Return regular expressions over a given alphabet.
    # `alphabet` is a string with the symbols of the alphabet.
    # If `expressionId` is undefined then all expressions are enumerated.
    # If `expressionId` is a valid regular expression then it returns its index.
    # If `indexType` == 'list' or undefined, then it generates the range 0..expressionId.
    # If `indexType` == 'index', then it generates the regular expression with index `expressionId`.
    # If `printExpression` is false, then the expressions are not printed out, default is true.
    #
    # Examples:
    #
    #   list all regular expressions (take your time!)
    #   enumerateR('01');
    #        0   ∅
    #        1   0
    #        2   1
    #        3   (∅∅)
    #        4   (∅+∅)
    #        5   ∅*
    #        6   (0∅)
    #        7   (0+∅)
    #        8   0*
    #        9   (∅0)
    #       10   (∅+0)
    #       11   1*
    #       ...
    #
    #   list the first n regular expressions
    #   enumerateR('01', 5);
    #      0   ∅
    #      1   0
    #      2   1
    #      3   (∅∅)
    #      4   (∅+∅)
    #      5   ∅*
    #
    #   find the index of a regular expression
    #   enumerateR('01', '((∅∅)+(∅+∅))');
    #   100   ((∅∅)+(∅+∅))
    #
    #   enumerateR('01', '(01)*', 'search', false)
    #   ans = 86
    #
    #   regular expression with index 10000
    #   enumerateR('01', 10000, 'index');
    #   10000   ((0*+0)+(∅∅)*)
    #
    #   enumerateR('01', 10000, 'index', false)
    #   ans = ((0*+0)+(∅∅)*)
    #
    #   return the first 5 regular expressions, do not print them
    #   enumerateR('01', 5, 'list', false)
    #   ans =
    #   {
    #     [1,1] = ∅
    #     [1,2] = 0
    #     [1,3] = 1
    #     [1,4] = (∅∅)
    #     [1,5] = (∅+∅)
    #     [1,6] = ∅*
    #   }
    #
    # ===============================================================
    #
    #   fjv, 07/10/2023  GNU GPL v3.0
    #
    # ===============================================================

    ## check arguments
    ## reserved symbols
    if any(ismember(alphabet, '∅()+'))
        error('Wrong alphabet...')
    end

    ## numeric limit
    if exist('expressionId', 'var') && isnumeric(expressionId) && expressionId < 0
        error('Wrong limit, it must be a positive integer...')
    end

    ## correct indexType value
    if exist('indexType', 'var') &&!strcmp(indexType, 'list') &&!strcmp(indexType, 'index') &&!strcmp(indexType, 'search')
        error('Wrong index type, it must be ''list'', ''index'' or ''search''...')
    end

    ## Cantor encoding needed here
    addpath('../Whilelanguage/encoding/');

    spacesymbol = ' ';

    ## check if called from LuaTex and adapt special characters
    files = dbstack;
    caller = files(end).file;

    if strfind(caller, "runexample.m")
        # Em Quad (U+2001)
        spacesymbol = native2unicode([226 128 129]);
    end

    function prettyprint(index, expression, spacesymbol)

        printf('%s%d%s%s\n', repmat(spacesymbol, 1, 6 - numel(num2str(index))), index, repmat(spacesymbol, 1, 3), expression);
    end

    ## add empty set symbol to the alphabet
    symbols = {'∅'};

    for symbolId = 1:numel(alphabet)
        symbols(symbolId + 1) = alphabet(symbolId);
    end

    ## check possible arguments values
    ## expressions are printed by default
    if !exist('expressionId', 'var')
        ## enumerate regular expressions
        indexType = 'list';
        maxNumber = NaN;
    elseif ischar(expressionId)
        ## it is a regular expression
        ## return index
        if isregularexpression(alphabet, expressionId)
            printf(" \ n'%s' is a valid regular expression over the alphabet '%s', let's find its index ... \n \ n", expressionId, alphabet);
        else
            printf(" \ nSorry, '%s' is not a regular expression over the alphabet '%s'.\n\n", expressionId, alphabet);
            return;
        end

        indexType = 'search';
        maxNumber = NaN;
    elseif !exist('indexType', 'var')
        ## it is a numeric index
        ## default value: return a list of regular expressions
        indexType = 'list';
        maxNumber = expressionId;
    else
        ## otherwise, it has an input value
        maxNumber = expressionId;
    end

    if !exist('printExpression', 'var')
        ## default value: print regular expressions
        printExpression = true;
    end

    ## check if only one indexed expression, or a finite or infinite list of them
    if strcmp(indexType, 'index')
        ## an indexed regular expression
        ##   expressionId mod 3 the index is mapped to any possible combination
        ##   0      maps onto ∅
        ##   1      maps onto alphabet(1)
        ##   ...
        ##   |Σ|    maps onto alphabet(|Σ|)
        ##   |Σ|+1  maps onto (00)
        ##   |Σ|+2  maps onto (0+0)
        ##   |Σ|+3  maps onto 0*
        ##   |Σ|+4  maps onto (10)
        ##   |Σ|+5  maps onto (1+0)
        ##   |Σ|+6  maps onto 1*
        ##   |Σ|+7  maps onto (01)
        ##   |Σ|+8  maps onto (0+1)
        ##   |Σ|+9  maps onto 2*
        ##   |Σ|+10 maps onto (20)
        ##   |Σ|+11 maps onto (2+0)
        ##   |Σ|+12 maps onto 3*
        ##   and so on, according to Cantor encoding of ℕ²

        if expressionId < numel(symbols)
            ## base cases are 0..|Σ| for ∅ and the symbols of the alphabet
            expression = symbols{expressionId + 1};
        else
            ## general case include concatenation, union and Kleen star of regular expressions
            ##   mapping:
            ##     |Σ|+1 -> 0 -> (0,0)
            ##     |Σ|+2 -> 1 -> (1,0)
            ##     |Σ|+3 -> 0
            ##     |Σ|+4 -> 2 -> (0,1)
            ##     |Σ|+5 -> 3 -> (2,0)
            ##     |Σ|+6 -> 1

            index = expressionId - numel(symbols);
            normalizedIndex = floor((expressionId - numel(symbols)) / 3);

            switch mod(index, 3)
                case 0
                    # union of expressions
                    indexes = cantordecoding(normalizedIndex, 2);
                    expression = strcat('(', enumerateR(alphabet, indexes(1), 'index', false), enumerateR(alphabet, indexes(2), 'index', false), ')');
                case 1
                    # concatenation of expressions
                    indexes = cantordecoding(normalizedIndex, 2);
                    expression = strcat('(', enumerateR(alphabet, indexes(1), 'index', false), '+', enumerateR(alphabet, indexes(2), 'index', false), ')');
                case 2
                    # Kleene star of an expression
                    expression = strcat(enumerateR(alphabet, normalizedIndex, 'index', false), '*');
            end

        end

        if printExpression
            prettyprint(expressionId, expression, spacesymbol);
        end

    else

        if !isnan(maxNumber)
            ## only if there is a limit
            expression = {};
        end

        ## enumerate expressions (either finite or infinite)
        numberExpressions = 0;
        searching = strcmp(indexType, 'search');

        do
            newExpression = enumerateR(alphabet, numberExpressions, 'index', false);

            if searching

                if strcmp(newExpression, expressionId)
                    ## the regular expression has been found
                    expression = numberExpressions;

                    if printExpression
                        prettyprint(numberExpressions, newExpression, spacesymbol);
                    end

                    break;
                end

            else
                ## not searching
                if !isnan(maxNumber)
                    ## only if there is a limit
                    expression{end + 1} = newExpression;
                end

                if printExpression
                    prettyprint(numberExpressions, newExpression, spacesymbol);
                end

            end

            numberExpressions++;
        until strcmp(indexType, 'list') && numberExpressions > maxNumber

    end

end
