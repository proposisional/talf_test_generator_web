function nextconfiguration = Next(whileprogram, configuration)
## Next configuration of a given configuration for a While program
##
## example
##   >> Next("(1, X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od)", [1,3,0])
##   ans = [2,3,3]
##
##  fjv 20211214 GNU GPL v3.0

  ## get line and variables
  linenumber = configuration(1);
  X = configuration(2:end);

  ## get the code
  whilecode = whileprogram(strfind(whileprogram, ",") + 1 : end - 1);

  if linenumber == Size(whilecode) + 1
    ## halting condition
    nextconfiguration = configuration;
  else
    whileline = Line(whilecode, linenumber);
    if strcmp(whileline(1), "w")
      ## while head
      ## get index of control variable (avoid the second number, the 0)
      [~, ~, ~, index] = regexp(whileline, '\d+');
      index = str2num(index{1});
      if X(index) != 0
        ## the condition verifies
        nextlinenumber = linenumber + 1;
        nextX = X;
      else
        ## the condition does not verify, go to tail + 1
        nextlinenumber = Go(whilecode, linenumber);
        nextX = X;
      end
    elseif strcmp(whileline, "od")
      ## while tail, go to head
      nextlinenumber = Go(whilecode, linenumber);
      nextX = X;
    else
      ## assignment
      nextlinenumber = linenumber + 1;
      nextX = X;
      ## get index of control variable (avoid the second number, the 0)
      [position, ~, ~, index] = regexp(whileline, '\d+');
      i = str2num(index{1});
      if index{2} == 0
        ## Xi:=0
        nextX(i) = 0;
      else
      j = str2num(index{2});
      if numel(index) == 2
        ## Xi:=Xj
        nextX(i) = nextX(j);
      else
        ## Xi:=Xj+1 or Xi:=Xj-1 / get the sign and put everything in a string
        assignmentsign = whileline(position(3) - 1);
        ## make assignment, considering that 0 - 1 = 0
        nextX(i) = max(eval(strcat(num2str(nextX(j)), assignmentsign, "1")), 0);
      end
    end
  end
  
  nextconfiguration = [nextlinenumber, nextX];
end
