function returnString = rec2WHILEEXT(recfunction, numVar, varargin)
## rec2WHILEEXT(recfunction, numVar, usedFuncs) returns the Extended WHILE program corresponding to the recursive function
##
## example
## >> rec2WHILEEXT('<π^1_1|σ(π^3_3)>', 2)
## ans =
##        Q(2, s)
##        s:
##          X3 := G1(X1);
##          while X2≠0 do
##                X3 := H1(X1,X4,X3);
##                X4 := X4+1;
##                X2 := X1-1
##          od
##        X1 := X3
##
##  where
##
##        G1(1, s)
##        s:
##          (* π^1_1 *)
##          X1 := X1
##
##
##        H1(3, s)
##        s:
##          X4 := H2(X1,X2,X3);
##          X1 := G2(X4)
##
##  where
##
##        H2(3, s)
##        s:
##          (* π^3_3 *)
##          X1 := X3
##
##
##        G2(1, s)
##        s:
##          (* σ(n) *)
##          X1 := X1+1
##
##
## >> rec2WHILEEXT('predecessor', 1)
##
##ans =
##        Q(1, s)
##        s:
##          X2 := G1();
##          while X1≠0 do
##                X2 := H1(X3,X2);
##                X3 := X3+1;
##                X1 := X1-1
##          od
##          X1 := X2
##
##  where
##
##        G1(0, s)
##        s:
##          (* θ *)
##          X1 := 0
##
##        H1(2, s)
##        s:
##          (* π^2_1 *)
##          X1 := X1
##
##  jas 20220220 GNU GPL v3.0

##  TBD: extract general-porpuse functions with other scripts
##  TBD: reduce blank lines in the output
##  TBD: eliminate commented lines in the code


  warning off

  ## access to util functions
  addpath('../util/');

  ## database of known recursive functions
  recursivefunctionsfilename = 'recursivefunctions';

  ## vector of used functions
  usedFuncs = varargin;

  ## name of current program
  if isempty(usedFuncs) == 1
    currentFunc = "Q";
    usedFuncs = currentFunc;
  else
    currentFunc = varargin{end};
  end

  if ischar(usedFuncs)
    usedFuncs = {usedFuncs};
  end

  ## remove spaces and capital letters
  recfunction = strrep(tolower(recfunction), ' ', '');

  ## rewrite Latin names with Greek symbols
  recfunction = strrep(recfunction, 'theta', 'θ');
  recfunction = strrep(recfunction, 'pi^',   'π^');
  recfunction = strrep(recfunction, 'sigma', 'σ');
  recfunction = strrep(recfunction, 'mu[',   'μ[');

  ## print recursive function
%  fprintf(stderr, "%s%s(", blanks(numel(dbstack)-1), recfunction);


  ## check if it is an initial function
  isinitialfunction = isempty(strfind(recfunction, '(')) &&...
                      isempty(strfind(recfunction, '<')) &&...
                      isempty(strfind(recfunction, '['));

  if isinitialfunction
    ## initial functions
    if strfind(recfunction, 'θ') == 1
      ## zero (theta) function =========================================
      if numVar != 0
        error(" θ() cannot be invoked with %d argument(s).\n", numVar);
      end
      returnString = "\t  (* θ *)\n\t  X1 := 0";
      ## Header of the program
      returnString = strcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);
    elseif strfind(recfunction, 'σ') == 1
      ## successor (sigma) function ====================================
      if numVar != 1
        error(" σ() cannot be invoked with %d argument(s).\n", numVar);
      end
      returnString = strcat("\t  (* σ(n) *)\n\t  X1 := X1+1");
      ## Header of the program
      returnString = strcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);
    elseif strfind(recfunction, 'π') == 1
      ## projection (pi) function ======================================
      [~, ~, ~, parameter, ~, ~, ~] = regexp(recfunction, '\d*');
      if numel(parameter) != 2
        error(" wrong number of arguments for function π (%d).\n", numVar);
      elseif numVar != str2num(parameter{1})
        error(formatfunction(sprintf(" π^%s_%s() cannot be invoked with %d argument(s).\n", parameter{1}, parameter{2}, numVar)));
      end
      returnString = strcat("\t  (* π^", num2str(numVar),"_",parameter{2}," *)\n\t  X1 := X",parameter{2});
      ## Header of the program
      returnString = strcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);
    else
      ## user-defined function  ========================================
      ## load database of recursive expressions
      [functionname, functionexpression] = textread(recursivefunctionsfilename, '%s %s');
      ## find function name
      idfunction = find(strcmp(functionname, recfunction));
      if isempty(idfunction)
        ## function not found
        printerror;
      else
        ## replace function name by recursive expression
        expandedfunction = functionexpression{idfunction};
        fprintf(stderr, "\n");

        returnString = rec2WHILEEXT(expandedfunction, numVar, usedFuncs{:});
      end
    end

  elseif strcmp(recfunction(end), ']')
    ## function defined by minimization ================================
    ## extract the function to be minimized
    ## (μ takes the first two characters and the [ ] are also to be discarded)
    minimizedfunction = recfunction(4:end-1);

    ## determine name for minimized function
    minFuncNum = 1;
    while  find(strcmp(any(usedFuncs), strcat("G", num2str(minFuncNum)))) != 0
      minFuncNum = minFuncNum + 1;
    end

    minFuncName = strcat("G", num2str(minFuncNum));

    ## construct the code of the while loop's header
    whileString = cstrcat("while ", minFuncName,"(");
    for idvar = 1 :  numVar+1
      whileString = strcat(whileString, "X", num2str(idvar), ",");
    end

    ## delete last ","
    whileString = whileString(1:end-1);

    ## from whileString, construct the code of the G function

    gFunctionString = strcat("\t", rec2WHILEEXT(minimizedfunction, numVar+1, usedFuncs{:},  minFuncName), "\n");

    ## complete the while loop and copy T to X1
    whileString = strcat(whileString, ") ≠ 0 do \n\t\tX", num2str(numVar+1), " := X", num2str(numVar+1), "+1 \n\t  od\n\t  X1 := X", num2str(numVar+1));

    ## concatenate the while loop with the G function
    returnString = cstrcat("\t  ", whileString, "\n \n  where:\n", gFunctionString, "\n \n");

    ## Header of the program
    returnString = cstrcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);

  elseif strcmp(recfunction(end), '>')
    ## function defined by primitive recursion =========================

    ## find functions separator (avoiding possible nested primitive recursions)
    separatorposition = strfind(avoidnested(recfunction, '<', '>'), '|');

    ## check that number of arguments > 0
    if numVar == 0
      error(" wrong number of argumentos for primitive recursion (%d).\n", numVar);
    end

    ## determine name for base function

    baseFuncNum = 1;
    while  find(strcmp(usedFuncs, cstrcat("G", num2str(baseFuncNum)))) != 0
      baseFuncNum = baseFuncNum + 1;
    end

    baseFuncName = cstrcat("G", num2str(baseFuncNum));

     ## determine name for iterated function

    iterFuncNum = 1;
    while  find(strcmp(usedFuncs, cstrcat("H", num2str(iterFuncNum)))) != 0
      iterFuncNum = iterFuncNum + 1;
    end

    iterFuncName = cstrcat("H", num2str(iterFuncNum));

    ## program returned by the base function

    basefunction  = recfunction(2:separatorposition-1);
    fprintf(stderr, "\n");
    basefunctionWhile = rec2WHILEEXT(basefunction, numVar-1, usedFuncs{:}, iterFuncName, baseFuncName);

    ## program returned by the iterated function
    iteratedfunction = recfunction(separatorposition+1:end-1);
    fprintf(stderr, "\n");
    iteratedfunctionWhile = rec2WHILEEXT(iteratedfunction, numVar+1, usedFuncs{:}, baseFuncName, iterFuncName);

    k = numVar - 1;

    ## create string of the variables used in base case function
    vars = "";
    for idvar = 1 :  k
      vars = cstrcat(vars, "X", num2str(idvar), ",");
    end

    ## create string of the variables used in recursive case
    varsRec =  cstrcat(vars, "X", num2str(k+3), ",X", num2str(k+2));
    vars = vars(1:end-1);

    ## assign to variable XK+2 the result of base case function
    primString = cstrcat("\t  ", "X", num2str(k+2), " := ", baseFuncName,"(", vars, "); \n");

    ## construct the code of the while loop
    primString = cstrcat(primString,"\t  ",  "while X", num2str(k+1), "≠0 do \n");
    primString = cstrcat(primString,"\t\t", "X", num2str(k+2), " := ",  iterFuncName,"(", varsRec, "); \n");
    primString = cstrcat(primString,"\t\t", "X", num2str(k+3), " := X", num2str(k+3), "+1; \n");
    primString = cstrcat(primString,"\t\t", "X", num2str(k+1)," := X1-1 \n");
    primString = cstrcat(primString,"\t  ", "od \n");

    ## assign to variable X1 the variable Xk+2
    primString = cstrcat(primString,"\t  ",  "X1 := X", num2str(k+2), "\n \n");
    primString = cstrcat(primString,"\t",  "\n  where\n");
    primString = cstrcat(primString,"\t", basefunctionWhile, "\n \n");

    returnString = cstrcat(primString,"\t", iteratedfunctionWhile, "\n \n");

    ## Header of the program
    returnString = cstrcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);

  elseif strcmp(recfunction(end), ')')
    ## function defined by composition =================================

    ## find delimiters
    ## position of opening parenthesis as the last one at nesting level 1
    ## (any other parenthesis will be in a deeper level)
    [symbolposition, nestinglevel] = labelbalancedsymbols(recfunction, '(', ')');
    separatorfirstposition = symbolposition(find(nestinglevel == 1)(end));
    ## position of last parenthesis
    separatorlastposition  = strfind(recfunction, ')')(end);
    ## position of all function delimiters:  ( , , ... ,  )
    separatorposition      = [separatorfirstposition,...
                              ## find comma separators avoiding possible nested compositions
                              strfind(avoidnested(recfunction, '(', ')'), ','),...
                              separatorlastposition];

    ## determine next HX available

    innerFuncNum = 1;
    while find(strcmp(usedFuncs, cstrcat("H", num2str(innerFuncNum)))) != 0
        innerFuncNum = innerFuncNum + 1;
    end

    # determine name of outer function

    outerFuncNum = 1;
    while find(strcmp(usedFuncs, cstrcat("G", num2str(outerFuncNum)))) != 0
      outerFuncNum = outerFuncNum + 1;
    end

    outerFuncName = cstrcat("G", num2str(outerFuncNum));

    ## find cardinality of inner functions
    k = numVar;
    m = numel(separatorposition) - 1;

    ## create string of the variables used in inner functions
    vars = "";
    for idvar = 1 :  k
      vars = cstrcat(vars, "X", num2str(idvar), ",");
    end
    vars = vars(1:end-1);

    ## string of all the inner functions being assigned to the k+1 and onwards variables
    compString = "";
    innerFuncs = {};

    for h = innerFuncNum : innerFuncNum + m - 1
     compString = cstrcat(compString,"\t  ",  "X", num2str(k + 1), " := H", num2str(h), "(", vars, ");" ,"\n");
     innerFuncs(end + 1) = cstrcat("H", num2str(h));
     k = k + 1;
    end


    ## evaluate second and further h functions (create the WHILE programs from them)
    i = 1;
    modInnerFuncs = flip(innerFuncs);
    for idseparator = 2 : numel(separatorposition)
      innerfunction = recfunction(separatorposition(idseparator-1)+1 : separatorposition(idseparator)-1);
      fprintf(stderr, "\n");
      internalarguments{idseparator-1} = rec2WHILEEXT(innerfunction, numVar, usedFuncs{:}, outerFuncName, modInnerFuncs{:});
      modInnerFuncs = circshift(modInnerFuncs,1,2);
    end



    ## create string of the variables used in outer function
    varsG = "";
    for idvar =  k : k + m - 1
      varsG = cstrcat(varsG, "X", num2str(idvar), ",");
    end
    varsG = varsG(1:end-1);

    ## assign the result of the outer function to x1
    compString = cstrcat(compString,"\t  ",  "X1 := ",outerFuncName,"(", varsG , ") \n \n");

    compString = cstrcat(compString,  "  where:\n");

    ## concatenate the strings generated by analyzing the inner functions
    for h = 1 :  numel(internalarguments)
      compString = cstrcat(compString,"\t", internalarguments{h}, "\n \n");
    end

    x=  rec2WHILEEXT(recfunction(1 : separatorfirstposition-1), m, usedFuncs{:}, innerFuncs{:}, outerFuncName);
    ## concatenate the string generated by analyzing the outer function

    returnString = cstrcat(compString,"\t", rec2WHILEEXT(recfunction(1 : separatorfirstposition-1), m, usedFuncs{:}, innerFuncs{:}, outerFuncName));


    ## Header of the program
    returnString = cstrcat("\n\t", currentFunc,"(",num2str(numVar), ", s)\n\t", "s: \n", returnString);
  else
    printerror;
  end


  ## local functions ===================================================

  function filteredfunction = avoidnested(recfunction, opensymbol, closesymbol)
  ## erase nested occurrences of the symbols to ease finding internal delimiters
  ## (commas in composition, | in recursion)
  ## "<pi^1_1|<pi^2_2|pi^4_2>>"              ->   "<pi^1_1|               >"
  ## "pi^3_2(pi^1_1(pi^3_1),pi^3_2,pi^3_3)"  ->   "pi^3_2(pi^1_1        ,pi^3_2,pi^3_3)"

    ## filtered name equals original name, and nested substrings will be erased
    filteredfunction = recfunction;

    ## find levels of nesting
    [symbolposition, nestinglevel] = labelbalancedsymbols(recfunction, opensymbol, closesymbol);

    ## find opening and closing delimiters for nesting level 2
    openlevel2  = find(nestinglevel == 2);
    closelevel2 = find(nestinglevel == -2);
    for idlevel2 = 1 : numel(openlevel2)
      ## erase functions with a level of nesting of two or higher
      filteredfunction(symbolposition(openlevel2(idlevel2)) : symbolposition(closelevel2(idlevel2))) = ' ';
    end
  end


  function printerror
    error("Error in function definition...\n");
  end


  function formattedrecfunction = formatfunction(recfunction)

    ## super- and subscripts for projection functions
    superscript = {'⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹'};
    subscript   = {'₀','₁','₂','₃','₄','₅','₆','₇','₈','₉'};

    formattedrecfunction = recfunction;

    ## convert normal digits to superscript digits
    [firstchar, lastchar, ~, value] = regexp(recfunction, '\^\d*');
    for idnumber = 1 : numel(value)
      number = value{idnumber};
      superscriptnumber = '';
      for iddigit = 2 : numel(number)
        superscriptnumber = strcat(superscriptnumber, superscript{str2num(number(iddigit))+1});
      end
      formattedrecfunction = strrep(formattedrecfunction, number, superscriptnumber);
    end

    ## convert normal digits to subscript digits
    [firstchar, lastchar, ~, value] = regexp(recfunction, '\_\d*');
    for idnumber = 1 : numel(value)
      number = value{idnumber};
      subscriptnumber = '';
      for iddigit = 2 : numel(number)
        subscriptnumber = strcat(subscriptnumber, subscript{str2num(number(iddigit))+1});
      end
      formattedrecfunction = strrep(formattedrecfunction, number, subscriptnumber);
    end
  end

end
