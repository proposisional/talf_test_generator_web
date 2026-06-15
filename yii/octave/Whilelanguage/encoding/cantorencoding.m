function code = cantorencoding(varargin)
## Cantor encoding for a vector of numbers of a given length:
##    cantorenconding(x_1, ..., x_n)
##
## example
##   >> cantorencoding(3, 1, 2, 1)
##   ans =  5566
##   
##  fjv 20180120 GNU GPL v3.0
##  fjv 20200116 encoding changed from left to right to fit with lectures notes


  if nargin == 1
    ## case of N
    code = varargin{1};
  elseif nargin == 2
    ## case of N^2
    x = varargin{1};
    y = varargin{2};
    code = uint64((x + y) * (x + y + 1) / 2 + y);
  else
    ## recursive case of N^p, p > 2
    ## vectors are encoded from left to right
    ## convert to unsigned integer of 64 bits
    code = uint64(cantorencoding(cantorencoding(varargin{1:end-1}), varargin{end}));
  end
  
end
