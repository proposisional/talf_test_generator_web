function computedvalue = evalrecfunction(recfunction, varargin)
## evalrecfunction(recfunction, varargin) returns the computed value
##
## example
##   >> evalrecfunction('addition', 3, 2)
##   ans =
##
##      5
##
##   >> evalrecfunction('division', 4, 2)
##   ans =
##
##      2
##
##   >> evalrecfunction('<theta|pi^2_2>', 2)
##   ans =
##
##      0
##   
##  fjv 20181216 GNU GPL v3.0
##  fjv 20181217 projection functions with super- and subscripts


  warning("off");

  ## access to util functions
  addpath('../util/');

  ## database of known recursive functions
  recursivefunctionsfilename = 'recursivefunctions';

  ## remove spaces and capital letters
  recfunction = strrep(tolower(recfunction), ' ', '');

  ## rewrite Latin names with Greek symbols
  recfunction = strrep(recfunction, 'theta', 'θ');
  recfunction = strrep(recfunction, 'pi^',   'π^');
  recfunction = strrep(recfunction, 'sigma', 'σ');
  recfunction = strrep(recfunction, 'mu[',   'μ[');

  ## print recursive function
%  fprintf(stderr, "%s%s(", blanks(numel(dbstack)-1), recfunction);
  fprintf(stderr, "%s(", formatfunction(recfunction));
  if numel(varargin) > 0
    fprintf(stderr, "%d", varargin{1});
    for idargument = 2 : numel(varargin)
      fprintf(stderr, ",%d", varargin{idargument});
    end
  end
  fprintf(stderr, ")");


  ## vector or arguments
  arguments = [varargin{:}];

  ## check if it is an initial function
  isinitialfunction = isempty(strfind(recfunction, '(')) &&...
                      isempty(strfind(recfunction, '<')) &&...
                      isempty(strfind(recfunction, '['));

  if isinitialfunction
    ## initial functions
    if strfind(recfunction, 'θ') == 1
      ## zero (theta) function =========================================
      if numel(varargin) != 0
        error(" θ() cannot be invoked with %d argument(s).\n", numel(varargin));
      end
      computedvalue = 0;
      fprintf(stderr, " = %d\n", computedvalue);
    elseif strfind(recfunction, 'σ') == 1
      ## successor (sigma) function ====================================
      if numel(varargin) != 1
        error(" σ() cannot be invoked with %d argument(s).\n", numel(varargin));
      end
      computedvalue = varargin{1}+1;
      fprintf(stderr, " = %d\n", computedvalue);
    elseif strfind(recfunction, 'π') == 1
      ## projection (pi) function ======================================
      [~, ~, ~, parameter, ~, ~, ~] = regexp(recfunction, '\d*');
      if numel(parameter) != 2
        error(" wrong number of argumentos for function π (%d).\n", numel(varargin));
      elseif numel(varargin) != str2num(parameter{1})
        error(formatfunction(sprintf(" π^%s_%s() cannot be invoked with %d argument(s).\n", parameter{1}, parameter{2}, numel(varargin))));
      end
      computedvalue = varargin{str2num(parameter{2})};
      fprintf(stderr, " = %d\n", computedvalue);
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
        computedvalue    = evalrecfunction(expandedfunction, varargin{:});
      end
    end

  elseif strcmp(recfunction(end), ']')
    ## function defined by minimization ================================
    
    ## extract the function to be minimized
    ## (μ takes the first two characters and the [ ] are also to be discarded)
    minimizedfunction = recfunction(4:end-1);
    
    fprintf(stderr, "\n");
    t = 0;
    while evalrecfunction(minimizedfunction, varargin{:}, t) != 0
      t++;
    end
    ## value returned by the function
    computedvalue = t;
    
  elseif strcmp(recfunction(end), '>')
    ## function defined by primitive recursion =========================

    ## find functions separator (avoiding possible nested primitive recursions)
    separatorposition = strfind(avoidnested(recfunction, '<', '>'), '|');

    ## check that number of arguments > 0
    if numel(arguments) == 0
      error(" wrong number of argumentos for primitive recursion (%d).\n", numel(varargin));
    end

    ## value returned by the function
    if arguments(end) == 0
      basefunction  = recfunction(2:separatorposition-1);
      fprintf(stderr, "\n");
      computedvalue = evalrecfunction(basefunction, varargin{1:end-1});
    else
      iteratedfunction = recfunction(separatorposition+1:end-1);
      fprintf(stderr, "\n");
      computedvalue    = evalrecfunction(iteratedfunction, varargin{1:end-1}, varargin{end}-1, evalrecfunction(recfunction, varargin{1:end-1}, varargin{end}-1));
    end

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
    
    ## evaluate second and further h functions
    for idseparator = 2 : numel(separatorposition)
      innerfunction = recfunction(separatorposition(idseparator-1)+1 : separatorposition(idseparator)-1);
      fprintf(stderr, "\n");
      internalarguments{idseparator-1} = evalrecfunction(innerfunction, varargin{1:end});
    end

    ## value returned by the function
    outerfunction = recfunction(1 : separatorfirstposition-1);
    fprintf(stderr, "\n");
    computedvalue = evalrecfunction(outerfunction, internalarguments{:});
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
  
