function configuration = Cal(whileprogram, inputvariables, steps)
## Configuration after a number of steps
##
## example
##   >> Cal("(1, X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od)", 3, 1)
##   ans =
##    2   3   3
##
##  fjv 20211214 GNU GPL v3.0

  transitionsymbol = "⊢";
  
  ## check if Cal has been called from F directly
  callingfunctionisF = any( ismember({dbstack.name}, "F")) && ...
                       all(!ismember({dbstack.name}, "T"));

  if steps == 0
    ## initial configuration
    ## find out the number of input variables
    [~, ~, ~, index] = regexp(whileprogram, '\d+');
    n = str2num(index{1});
    ## find out the total number of variables
    p = max(cellfun('str2num', index));
    
    configuration = [1, inputvariables, zeros(1, p - n)];
    if callingfunctionisF
      printconfiguration(configuration);
    end
  else
    configuration = Next(whileprogram, Cal(whileprogram, inputvariables, steps - 1));

    if callingfunctionisF
      fprintf(stderr, " %s ", transitionsymbol);
      printconfiguration(configuration);
    end
  end


  function printconfiguration(configuration)
  
    fprintf(stderr, "(%d", configuration(1));
    for idnum = 2 : numel(configuration)
      fprintf(stderr, ",%d", configuration(idnum));      
    end
    fprintf(stderr, ")");
  end

end
