function X1 = pop(X1)
# list = pop(list)
#
# list is a Gödel number that stores a vector of instructions encoded as numbers
#
# example:
#
#   > pop(20)
#   ans = 3
#   
#   since godelencoding(1,1) = 20 and godelencoding(1) = 3

  addpath("../encoding/");
  
  # auxiliary variables set to zero
  X2 = 0;
  X3 = 0;
  X4 = 0;

  # code
  X4 = X1;
  if X4 == 1
    X2 = 0;
  else
    X2 = godelencoding(godeldecoding(X1, 2));
    X4 = X4 - 1;
    X4 = X4 - 1;
    while X4 != 0
      X2 = godelencoding(X2, godeldecoding(X1, X3));
      X3 = X3 + 1;
      X4 = X4 - 1;
    end
  end
  X1 = X2;
  
end



##\whileprogram{pop}{2}{s}{
  ##\Comment{\X{1} = sentences, \X{4} = number of sentences}
  ##\exprsentence{\X{4}}{length(\X{1})}
  ##\Comment{return 0 if the program is just one sentence long}
  ##\uIf{\X{4} = 1}{
    ##\exprsentence*{\X{2}}{0}
  ##}\Else{
    ##\Comment{godel of sentences except the first one}
    ##\exprsentence{\X{2}}{godelk(degodel(\X{1},2))}
    ##\decrsentence{\X{4}}{\X{4}}
    ##\decrsentence{\X{4}}{\X{4}}
    ##\whilesentence{\X{4}}{
    	##\exprsentence{\X{2}}{godelk(\X{2},degodel(\X{1},\X{3}))}
        ##\incrsentence{\X{3}}{\X{3}}
    	##\decrsentence*{\X{4}}{\X{4}}
    ##}
    ##\exprsentence*{\X{1}}{\X{2}}
##}
