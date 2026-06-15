function typerule = ruletype(rule, N, T)
## typerule = ruletype(rule, N, T)
##
## Check the type of a rule, given in the form of a list of two strings.
## Optionally, non-terminal and terminal alphabets can be provided as arguments.
##
## Examples:
##   rule = ruletype({'A','BC'});
##   rule = ruletype({'BA1','110'}, 'AB', '01');
##
## =========================================================================
##
##   fjv, 07/11/2022   GNU GPL v3.0
##
## =========================================================================

  addpath("../util");

  epsilon   = 'ε';

  if !exist('N', 'var')
    # non-terminal alphabet
    N = 'A':'G';
  end
  if !exist('T', 'var')
    # terminal alphabet
    T = 'a':'g';
  end
  
  # union of terminals and non-terminals
  V = union(N, T);

  # return variable is a struct, default value is type 0
  typerule = struct('number', 0, 'name', 'phrase structure');

  leftsidestring  = rule{1};
  rightsidestring = rule{2};

  if strcmp(rightsidestring, epsilon)
    # case of type 0 epsilon rule
    return
  end
  
  if  numel(leftsidestring ) == 1 && ismember(leftsidestring,  N)
    # leftside is a non-terminal, so type 2 or 3
    if numel(rightsidestring) == 1 && ismember(rightsidestring, T)
      typerule.number = 3;
      typerule.name   = 'terminal-regular';
    elseif numel(rightsidestring) == 2
      # it might be left-regular or right regular
      if (ismember(rightsidestring(1), T)) && ismember(rightsidestring(2), N)
        # terminal and non-terminal
        typerule.number = 3;
        typerule.name   = 'left-regular';
      elseif (ismember(rightsidestring(1), N)) && ismember(rightsidestring(2), T)
        # non-terminal and terminal
        typerule.number = 3;
        typerule.name   = 'right-regular';
      else
        # two non-terminals
        typerule.number = 2;
        typerule.name   = 'context free';
      end
    elseif all(ismember(rightsidestring, V))
      # leftside has one non-terminal symbol and all symbols in righside are either terminals or non-terminals
      typerule.number = 2;
      typerule.name   = 'context free';
    end

  else
    # leftside has one non-terminal symbol and all symbols in righside are either terminals or non-terminals
    istype1 = false;
    for idnonterminal = find(ismember(leftsidestring, N))
      nonterminal = leftsidestring(idnonterminal);
      alpha = leftsidestring(1 : idnonterminal - 1);
      beta  = leftsidestring(idnonterminal + 1 : end);
      
      # check if the context is kept
      if numel(rightsidestring) > numel(alpha) + numel(beta) && ...
           strcmp(rightsidestring(1 : numel(alpha)), alpha)  && ...
           strcmp(rightsidestring(end - numel(beta) + 1 : end), beta)
         # check that nonterminal is not rewritten by the empty string
        if !strcmp(rightsidestring, strcat(alpha, beta))
          gamma = rightsidestring(numel(alpha) + 1 : end - numel(beta));
          istype1 = true;
          break;
        end
      end
    end
    
    if istype1
      # a context that is kept has been found
      typerule.number = 1;
      typerule.name   = 'context sensitive';
    end
  end
  
end

