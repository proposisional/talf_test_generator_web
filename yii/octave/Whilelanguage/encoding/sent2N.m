function code = sent2N(sentence)
## Numbering of an individual sentence
##
## example
##   >> sent2N("while X1≠0 do X1≔X1-1; X2≔X2+1 od")
##   ans =  9325236374

  ## as to avoid scientific notation
  format long

  ## erase in-between spaces
  sentence = strrep(sentence, ' ', '');
  ## replace assignment symbol
  sentence = strrep(sentence, ':=', '≔');
  ## replace comparison symbol
  sentence = strrep(sentence, '!=', '≠');

  ## loop delimiters
  loophead = 'do';
  looptail = 'od';
    
  ## identify all numbers in the sentence
  [begdigit, enddigit] = regexp(sentence, '\d+');
  ## extract first number
  firstnumber  = str2num(sentence(begdigit(1):enddigit(1)));
  ## sort assignments and loops out
  if sentence(1) == 'X'
    ## extract second number
    secondnumber = str2num(sentence(begdigit(2):enddigit(2)));
    ## extract a pattern for the sentence (to identify it by pattern matching)
    sentencepattern = strcat(sentence([1:begdigit(1)-1,...
                           enddigit(1)+1:begdigit(2)-1,...
                           enddigit(2)+1:end]));
    ## encode the assignment
    if strcmp(sentencepattern, "X≔")
      ## type 0 assignment
      code = 5 * (firstnumber - 1);
    elseif strcmp(sentencepattern, "X≔X")
      ## type 1 assignment
      code = 5 * cantorencoding(firstnumber - 1, secondnumber - 1) + 1;
    elseif strcmp(sentencepattern, "X≔X+1")
      ## type 2 assignment
      code = 5 * cantorencoding(firstnumber - 1, secondnumber - 1) + 2;
    elseif strcmp(sentencepattern, "X≔X-1")
      ## type 3 assignment
      code = 5 * cantorencoding(firstnumber - 1, secondnumber - 1) + 3;
    end
  else
    ## extract loop body
    loopbody = sentence(strfind(sentence, loophead)(1) + length(loophead):...
                        strfind(sentence, looptail)(end) - 1);
    ## encode loop
    code = 5 * cantorencoding(firstnumber - 1, CODE2N(loopbody)) + 4;
  end

end
