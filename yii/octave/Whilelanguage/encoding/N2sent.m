function sentence = N2sent(z)
## Numbering of an individual sentence
##
## example
##   >> N2sent(192509)
##   ans =  while X2=0 do X2≔X2+1 od
##
##  fjv 20180120 GNU GPL v3.0


  ## type of sentence
  sentencetype = senttype(z);

  if sentencetype == 0
    ## Xi≔0
    sentence = strcat("X", num2str(lhs(z)), ":=0");
  elseif sentencetype == 1
    ## Xi≔Xj
    sentence = strcat("X", num2str(lhs(z)), ":=X", num2str(rhs(z)));
  elseif sentencetype == 2
    ## Xi≔Xj+1
    sentence = strcat("X", num2str(lhs(z)), ":=X", num2str(rhs(z)), "+1");
  elseif sentencetype == 3
    ## Xi≔Xj-1
    sentence = strcat("X", num2str(lhs(z)), ":=X", num2str(rhs(z)), "-1");
  elseif sentencetype == 4
    sentence = cstrcat("while X", num2str(lhs(z)), "!=0 do ", N2CODE(rhs(z)), " od");
  end
    
end
