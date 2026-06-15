function lefthandside = lhs(z)
## Left-hand side of an encoded instruction
##
## example
##   >> z = sent2N("while X1≠0 do X1≔X1-1; X2≔X2+1 od")
##   ans =  9325236374
##   >> lhs(9325236374)
##   ans =  1
##
##   >> sent2N("X3≔X2+1")
##   ans =  37
##   >> lhs(37)
##   ans =  3
##
##  fjv 20221129 GNU GPL v3.0


  ## type of sentence
  sentencetype = senttype(z);

  if sentencetype == 0
    ## Xi≔0
    lefthandside = z / 5 + 1;
  else
    ## Xi≔Xj
    ## Xi≔Xj+1
    ## Xi≔Xj-1
    ## while 
    lefthandside = cantordecoding((z - sentencetype) / 5, 2, 1) + 1;
  end
    
end
