function code = godelencoding(varargin)
## Godel numbering for vectors of numbers of arbitrary length (ℕ* -> ℕ)
##
## example
##   >> godelencoding(4, 10, 2)
##   ans =  6674029
##   
##  fjv 20180120 GNU GPL v3.0


  if nargin == 0
    ## case of empty vector
    code = 0;
  else
    ## length of the vector plus Cantor encoding of the vector
    code = uint64(cantorencoding(nargin - 1, cantorencoding(varargin{:})) + 1);
  end
end
