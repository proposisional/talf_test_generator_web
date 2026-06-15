function lines = Size(whileprogram)
## Number of lines of a while program or code
##
## example
##   >> size("X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od")
##   ans = 6
##
##  fjv 20211214 GNU GPL v3.0


  if strcmp(whileprogram(1), "(")
    ## get the code from the program
    whilecode = whileprogram(strfind(whileprogram, ",") + 1 : end);
  else
    whilecode = whileprogram;
  end
  
  ## line separators determine the number of lines (-1)
  lines = numel([strfind(whilecode,";"), strfind(whilecode,"while"), strfind(whilecode, "od")]) + 1;
  
end
