function righthandside = rhs(z)
## Right-hand side of an encoded instruction
##
## example
##   >> sent2N("while X1≠0 do X1≔X1-1; X2≔X2+1 od")
##   ans =  9325236374
##   >> rhs(9325236374)
##   ans =  61073
##   >> N2CODE(61073)
##   ans = X1≔X1-1; X2≔X2+1
##
##   >> sent2N("X3≔X2+1")
##   ans =  37
##   >> rhs(37)
##   ans =  2
##
##  fjv 20221129 GNU GPL v3.0

  ## type of sentence
  sentencetype = senttype(z);

  if sentencetype == 4
    ## while Xi≠0 do b od
    righthandside = cantordecoding((z - sentencetype) / 5, 2, 2);
  else
    ## Xi≔Xj
    ## Xi≔Xj+1
    ## Xi≔Xj-1
    righthandside = cantordecoding((z - sentencetype) / 5, 2, 2) + 1;
  end

end
