function element = cantordecoding(z, n, k)
## cantordecoding(z, n, k) returns the kth element of the n-tuple encoded by z
## cantordecoding(z, n)    returns the n-tuple encoded by z
##
## example
##   >> cantordecoding(313613413, 4)
##   ans =
##   
##      1       0      10   24967
##   
##  fjv 20180120 GNU GPL v3.0
##  fjv 20200116 decoding changed from left to right to fit with lectures notes


  ## check number of arguments
  if nargin < 2 || nargin > 3
    ## show help for wrong number of arguments
    help cantordecoding
    return
  end

  ## convert to unsigned integer of 64 bits
  if !strcmp(class(z), 'uint64')
	z = uint64(z);
  end

  if n == 1
    ## N -> N
    vector = [z];
  elseif n == 2
    ## N^2 -> N
    ## diagonal where the pair is sitting
    diagonal = uint64(floor((sqrt(8 * z + 1) - 1) / 2));
    ## the second element is the distance to the beginning of the diagonal
    ##   cantorencoding(diagonal, 0)) = diagonal * (diagonal + 1) / 2
    element2 = z - diagonal * (diagonal + 1) / 2;
    ## first element
    element1 = diagonal - element2;
    ## diagonal = first element + second element
    vector = [element1, element2];
  else
    ## N^k -> N, k > 2
    vector = zeros(1, n);
    for idelement = n : -1 : 2
      ## at each level, z encodes a pair of numbers
      pair = cantordecoding(z, 2);
      ## the first element of a pair decodes the elements of the vector
      vector(idelement) = pair(2);
      ## the second element of the pair encodes the rest of the vector
      z = pair(1);
    end
    ## the second element of the pair decodes the last element of the vector
    vector(1) = z;
  end

  if ~exist('k', 'var')
    ## vector as output
    element = vector;
  else
    ## element as output
    element = vector(k);
  end
  
end
