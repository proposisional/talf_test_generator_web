function balancedlinenumber = Go(whilecode, linenumber)
## Line number to interpret if not the next one in sequence
##
## example
##   >> go("X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od", 2)
##   ans = 6
##
##  fjv 20211214 GNU GPL v3.0

  addpath('../util');

  ## remove non-ASCII characters to avoid shifts
  whilecode = strrep(whilecode, "≔", ":=");
  whilecode = strrep(whilecode, "≠", "!=");

  ## get the line
  [line, start1]  = Line(whilecode, linenumber);  
  ## balance heads and tails
  [start2, label] = labelbalancedsymbols(whilecode, 'while', 'od');

  ## find the relative position of that line
  position = find(start2==start1);
  if isempty(position)
    ## case of an assignment
    balancedlinenumber = 0;
  end

  ## find the balanced head or tail
  if label(position) > 0
    ## case of a while head
    headtailmatch = find(label == -label(position));
    charposition = start2(headtailmatch(find(headtailmatch > position)(1)));
    shiftlines = 1;
  else
    ## case of a while tail
    headtailmatch = find(label == -label(position));
    charposition = start2(headtailmatch(find(headtailmatch < position)(end)));
    shiftlines = 0;
  end

  ## search for the line starting in that character
  balancedlinenumber = 0;
  do
    [whileline, lineposition] = Line(whilecode, ++balancedlinenumber);
  until lineposition == charposition;
  
  ## add one more line in case of a head
  balancedlinenumber += shiftlines;

end
