function sentencetype = senttype(z)
## Type of a sentence
##
## example
##   >> z = sent2N("while X1=0 do X1≔X1-1; X2≔X2+1 od")
##   z =  9325236374
##   >> senttype(z)
##   ans =  4
##
##  fjv 20221129 GNU GPL v3.0


  ## type of sentence from module 5
  sentencetype = mod(z, 5);

end
