function steps = T(whileprogram, inputvariables)
## Temporal complexity of a WHILE program
##
## example
##   >> T("(1, X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od)", [3])
##   ans =  14
##
##  fjv 20211214 GNU GPL v3.0


  ## steps to check by user
  timetocheck = 1000;

  steps = 0;
  haltingline = Size(whileprogram) + 1;
  ## initial configuration
  configuration = Cal(whileprogram, inputvariables, 0);
  do
    ## check if user cancelling in case of possible infinite loop
    if mod(++steps, timetocheck) == 0
      fprintf(stderr, "complexity has reached %d, press Ctrl-C to stop, or any other key to continue...\n", steps);
      pause;
    end
    configuration = Next(whileprogram, configuration);

  until configuration(1) == haltingline;

end
