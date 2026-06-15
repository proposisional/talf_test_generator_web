function code = CODE2N(whilecode)
## Encoding of a while code (CODE -> ℕ)
##
## example
##   >> CODE2N("X1:=0;while X1!=0 do X1:=0 od")
##   ans =  134
##
##  fjv 20180120 GNU GPL v3.0


  ## loop delimiters
  loophead = 'while';
  looptail = 'od';
  
  ## segment sentences
  ## find loops at the first nesting level (nx2 - beginning/ends by columns)
  loop = firstlevelloop(whilecode);
  if isempty(loop)
    listsentence = ostrsplit(whilecode, ';', true);
  else
    ## find assignments where there are no loops
    listsentence = {};
    firstchar = 1;
    ## add assignments before the loop, and the loop itself
    for idloop = 1:size(loop, 1)
      listsentence = [listsentence,...
                      ostrsplit(whilecode(firstchar:loop(idloop,1)-1), ';', true),...
                      {whilecode(loop(idloop,1):loop(idloop,2))}];
      firstchar = loop(idloop,2)+1;
    end
    ## add assignments after the last loop
    listsentence = [listsentence, ostrsplit(whilecode(loop(end,2)+1:end), ';', true)];
  end

  ## make a vector with the encoding of each sentence
  sentencecode = [];
  for sentence = listsentence
    sentencecode = [sentencecode, sent2N(sentence{:})];
  end

  ## Gödel number of the code
  code = godelencoding(num2cell(sentencecode){:}) - 1;

  function loop = firstlevelloop(whilecode)
  ## find delimiters and assign a +/- sign to heads/tails, resp.
  ##   (first character of head and last character of tail)

    delimiter  = [strfind(whilecode, loophead), -(strfind(whilecode, looptail) + length(looptail) - 1)];
    if isempty(delimiter)
      ## no loops found in the code
      loop = [];
    else
      ## sort absolute values in ascending order
      [val, pos] = sort(abs(delimiter));
      delimiter  = delimiter(pos);
      ## first level tails by adding signs cumulatively
      tailind    = find(cumsum(sign(delimiter))==0);
      ## first level tails positions in the while code (reverse negative sign for tails)
      tailpos    = -delimiter(tailind);
      ## first level heads positions in the while code
      headpos    = [delimiter(1), delimiter(tailind(1:end-1) + 1)];
      ## first level loops
      loop       = [headpos', tailpos'];
    end
  end

end
