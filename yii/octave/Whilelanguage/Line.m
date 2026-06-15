function [whileline, position] = Line(whilecode, linenumber)
## A line in a While code
##
## example
##   >> line("X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od", 3)
##   ans = X1≔X1+1
##
##  fjv 20211214 GNU GPL v3.0

linenumber;
  ## delete ;
  whilecode = strrep(whilecode, ";", "");
  ## delete spaces
  whilecode = strrep(whilecode, " ", "");
  ## replace ≔ with :=
  whilecode = strrep(whilecode, "≔", ":=");
  ## replace ≠ with !=
  whilecode = strrep(whilecode, "≠", "!=");

  ## find line separators, beginning and end
  separator = sort([regexp(whilecode, 'X\d+:='), strfind(whilecode,"while"), strfind(whilecode, "od"), numel(whilecode) + 1]);

  ## extract line
  whileline = strtrim(whilecode(separator(linenumber): separator(linenumber + 1) - 1));
  
  ## return separator corrected by the spaces to the next instruction (add blank spaces)
  position  = separator(linenumber) + find(isspace(whilecode(separator(linenumber) : end))==0)(1) - 1;
  
end
