function computedvalue = F_emulation(whileprogram, varargin)
% Mathematical function computed by a WHILE program
%
% In case of error in the WHILE code, it raises the wrong Octave code.
%
% examples
%   >> F_emulation("(1, X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od)", 3)
%   ans = 6
%   >> F_emulation("product", 3, 3)
%   ans = 9
%
% ===============================================================
%
%   fjv, 07/11/2022   extended-While
%   fjv, 22/01/2022   loads from While programs database
%   fjv, 13/12/2021   GNU GPL v3.0
%
% ===============================================================

  ## get calling function name
  st = dbstack;
  thisfunction = st.name;
  
  ## check if the program is given explicitly or as a macrosentence
  if !strcmp(whileprogram(1), "(")
    ## case that the program is in the database

    addpath("../util/");
    
    ## database of While programs
    whileprogramsdatabasename = 'Whileprograms';

    ## load While programs definition from JSON file
    whileprogram = loadrepresentation(whileprogramsdatabasename, whileprogram);
  end

  ## extract n
  ## extract all numbers
  [~, ~, ~, M] = regexp(whileprogram, '\d+');
  ## n is the first number
  n = str2num(M{1});

  ## check function arity
  if n != nargin - 1
    error("Function's arity must match the number of arguments...")
  end

  ## extract code
  [~, code] = strtok(whileprogram, ',');
  code = strtrim(code(2:end-1));

  ## translate WHILE code into an Octave script
  code = strrep(code, '≔',  '=');
  code = strrep(code, ':=', '=');
  code = strrep(code, '≠0', '!=0 ');
  code = strrep(code, 'while', 'while ');
  code = strrep(code, 'do', '');
  code = strrep(code, 'od', ';end');
  code = macrosentencerep(code);
  
  ## assign initial values to input variables as new assignments 
  for idargument = numel(varargin) : -1 : 1
    code = sprintf('X%d=%d;%s', idargument, varargin{idargument}, code);
  end

  ## variable initialization to avoid error from nested call to eval
  X2 = 0;
  X3 = 0;
  ## run Octave script (simulate WHILE program with input variables)
  eval(code, 'error(lasterr())');
  computedvalue = X1;

  function newcode = macrosentencerep(code)
  ## add "F_emulation" to macrosentence calls
  ## e.g. replaces
  ##   X1 = addition(13, 8)
  ##   X1 = F_emulation("addition", 13, 8)
  
    argumentsstart = strfind(code, "(");
    argumentsstop  = strfind(code, ")");
    for idarguments = numel(argumentsstart) : -1 : 1
      ## replace from the last call to the first, so the replacement does not interfere
      callpoint = strfind(code(1 : argumentsstart(idarguments) - 1), "=")(end);
      macrosentencename = code(callpoint + 1 : argumentsstart(idarguments) - 1);
      code = cstrcat(code(1 : callpoint), thisfunction, "('", macrosentencename, "', ", code(argumentsstart(idarguments) + 1 : end));
    end
    newcode = code;
  end
  
end
