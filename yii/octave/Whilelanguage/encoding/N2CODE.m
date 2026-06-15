function code = N2CODE(z)
## Bijection ℕ -> CODE
##
## example
##   >> N2CODE(4)
##   ans = X1≔X1; X1≔0
##
##  fjv 20180120 GNU GPL v3.0


  ## convert to unsigned integer of 64 bits
  if !strcmp(class(z), 'uint64')
	  z = uint64(z);
  end
  ## add 1 to discard an empty code
  z = z + 1;
  ## extract the codes of the sentences
  sentence = godeldecoding(z);

  ## decode the sentences and add separators
  code = N2sent(sentence(1));
  # TBC: godeldecoding(z, 0) computes the lenght of vector enconded in z
  #      but z has been increased, then this line
  # for idsentence = 2:godeldecoding(z, 0)
  #      is replaced by
  # for idsentence = 2:godeldecoding(z - 1, 0)
  for idsentence = 2 : godeldecoding(z, 0)
    code = cstrcat(code, '; ', N2sent(sentence(idsentence)));
  end
  
end
