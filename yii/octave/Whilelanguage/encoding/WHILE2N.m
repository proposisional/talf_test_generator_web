function code = WHILE2N(n, whilecode)
## Numbering of while programs (WHILE -> ℕ)
##
## example
##   >> WHILE2N(1, "while X1≠0 do X1≔0 od")
##   ans = 134
##
##  fjv 20180120 GNU GPL v3.0
##  fjv 20181223 >> transformed from (n,p,s) to (n,s) 


  
  whilecode(find(whilecode == ' ')) = '';
  ## identify the number of each variable
  ## extract the variable in its context (X, followed by digits, followed by ; or ≔ or ≠ or end of string)
  [firstchar, lastchar] = regexp(whilecode, 'X\d+(;|=|!|:|$)');
  for idvble = 1:numel(firstchar)
    ## extract the number (as a number)
    [~, ~, ~, number]  = regexp(whilecode(firstchar(idvble):lastchar(idvble)), '\d+');
    identifier(idvble) = str2num(number{:});
  end

  ## encode the while program
  code = cantorencoding(n, CODE2N(whilecode));

end
