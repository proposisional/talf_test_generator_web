function program = N2WHILE(z)
## Biyection ℕ -> WHILE
##
## example
##   >> N2WHILE(150)
##   ans = (2, while X1≠0 do X1≔0 od)
##
##  fjv 20180120 GNU GPL v3.0
##  fjv 20181223 >> transformed from (n,p,s) to (n,s) 


  code = N2CODE(cantordecoding(z, 2, 2));
  
  ## identify the number of each variable
  ## extract the variable in its context (X, followed by digits, followed by : or ; ... or end of string
  [firstchar, lastchar] = regexp(code, 'X\d+(;|:=|!=|$)');
  for idvble = 1:numel(firstchar)
    ## extract the number (as a number)
    [~, ~, ~, number]  = regexp(code(firstchar(idvble):lastchar(idvble)), '\d+');
    identifier(idvble) = str2num(number{:});
  end
  
  ## extract n
  n = cantordecoding(z, 2, 1);
  ## make while program
  program = cstrcat('(', num2str(n), ', ', code, ')');

end