function expression = recursiveexpression(recfunction, outputformat)
## expression = recursiveexpression(recfunction, outputformat) is the recursive expression (only initial functions, composition, recursion and minimization) of a recursive function
##
## example
##   >> recursiveexpression('power')
##   ans = <σ(<θ|π^2_2>)|<<θ|π^2_2>|<π^1_1|σ(π^3_3)>(π^3_1,π^3_3)>(π^3_1,π^3_3)>
##
##   >> recursiveexpression('<π_1^1|π_3^1>', 'LaTeX')
##   ans = $<π_1^1|π_3^1>$
##
##  fjv 20181216 GNU GPL v3.0

  warning("off");

  asciicircum = "\textasciicircum";

  ## check if called from LuaTex and adapt special characters
  files = dbstack;
  caller = files(end).file;
  if strfind(caller, "runexample.m")
    textasciicircum = asciicircum;
  else
    textasciicircum = '^';
  end

  ## database of known recursive functions
  recursivefunctionsfilename = 'recursivefunctions';

  ## remove spaces and capital letters
  recfunction = strrep(tolower(recfunction), ' ', '');

  ## rewrite Latin names with Greek symbols
  recfunction = strrep(recfunction, 'theta', 'θ');
  recfunction = strrep(recfunction, 'pi^', 'π^');
  recfunction = strrep(recfunction, 'sigma', 'σ');
  recfunction = strrep(recfunction, 'mu[', 'μ[');

  ## replace function names by recursive expressions
  ## load database of recursive expressions
  [functionname, functionexpression] = textread(recursivefunctionsfilename, '%s %s');
  do
    ## find function names
    [firstchar, lastchar, ~, name, ~, ~, ~] = regexp(recfunction, '[a-z]+[0-9^_]*');
    if !isempty(name)
      idname = name{1};
      ## find function name in database
      functionposition = find(strcmp(functionname, idname));
      if isempty(functionposition)
        ## function not found
        error("Funtion '%s' not found in database...\n", idname);
      else
        ## replace name by expression
        recfunction = strcat(recfunction(1:firstchar(1)-1),...
                             functionexpression{functionposition},...
                             recfunction(lastchar(1)+1:end));
      end
    end
  until isempty(name);
  
  if exist('outputformat', 'var')
    if strcmp(outputformat, "LaTeX")
      ## rewrite Greek symbols with LaTeX commands
      ## TBD: add {} to sub and superscripts: \pi^{3}_{2}
      recfunction = strrep(recfunction, 'θ', '\theta');
      recfunction = strrep(recfunction, 'π^', '\pi^');
      recfunction = strrep(recfunction, 'σ', '\sigma');
      recfunction = strrep(recfunction, 'μ[', '\mu[');
      recfunction = strrep(recfunction, '[', '\left[');
      recfunction = strrep(recfunction, ']', '\right]');
      recfunction = strrep(recfunction, '(', '\left(');
      recfunction = strrep(recfunction, ')', '\right)');
      recfunction = strcat('$', recfunction, '$');
    elseif strcmp(outputformat, "text")
      ## rewrite Greek symbols with LaTeX commands
      ## TBD: add {} to sub and superscripts: \pi^{3}_{2}
      recfunction = strrep(recfunction, 'θ', '\theta');
      recfunction = strrep(recfunction, 'π^', strcat('\pi', textasciicircum));
      recfunction = strrep(recfunction, 'σ', '\sigma');
      recfunction = strrep(recfunction, 'μ', '\mnz');
      recfunction = strrep(recfunction, '<', '\rec{');
      recfunction = strrep(recfunction, '>', '}');
      recfunction = strrep(recfunction, '|', '}{');
      recfunction = strrep(recfunction, '[', '{');
      recfunction = strrep(recfunction, ']', '}');
      recfunction = strrep(recfunction, '(', '(');
      recfunction = strrep(recfunction, ')', ')');
      recfunction = strcat('$', recfunction, '$');
    end
  end

  expression = recfunction;

end
