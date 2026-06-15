function element = godeldecoding(z, k)
## Biyection ℕ -> ℕ*
## godeldecoding(z, k) returns the kth element of the tuple encoded by z
## godeldecoding(z, 0) returns the length of the tuple encoded by z
## godeldecoding(z)    returns the tuple encoded by z
##
## example
##   >> godeldecoding(1258489)
##   ans =
##
##      2    2   43
##   
##  fjv 20180120 GNU GPL v3.0


  ## convert to unsigned integer of 64 bits
  if !strcmp(class(z), 'uint64')
	z = uint64(z);
  end
  ## length of the encoded vector
  if z == 0
    vectorlength = 0;
  else
    vectorlength = cantordecoding(z - 1, 2, 1) + 1;
  end

  ## case of returning the length of the encoded vector
  if exist('k', 'var') && k == 0
    element = vectorlength;
  else
    ## case of returning an element, or the whole vector
    if vectorlength == 0
      ## N^0
      element = [];
    else
      ## N^k, k>0
      ## Cantor number of the vector
      z = cantordecoding(z - 1, 2, 2);
      if exist('k', 'var')
        ## kth element
        element = cantordecoding(z, vectorlength, k);
      else
        ## return the vector
        for idelement = 1:vectorlength
          element(idelement) = cantordecoding(z, vectorlength, idelement);
        end
    end
  end
  
end
