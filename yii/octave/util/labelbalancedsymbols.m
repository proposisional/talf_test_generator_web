function [symbolposition, label] = labelbalancedsymbols(string, opensymbol, closesymbol)
## label = labelbalancedsymbols(string, opensymbol, closesymbol)
## labels balanced opening (positive nesting level) and closing symbols (negative nesting level)
##
## example
##   >> labelbalancedsymbols('()()()', '(', ')')
##   p =
##   
##      1   2   3   4   5   6
##   
##   l =
##   
##      1  -1   1  -1   1  -1
##   
##   >> labelbalancedsymbols('[[][]]', '[', ']')
##   p =
##   
##      1   2   3   4   5   6
##   
##   l =
##   
##      1   2  -2   2  -2  -1
##
##  fjv 20181217 GNU GPL v3.0

  ## find opening symbols
  symbolposition = strfind(string, opensymbol);
  ## find closing symbols
  closeposition  = strfind(string, closesymbol);
  ## put together opening and closing
  symbolposition = sort([symbolposition, closeposition]);
  ## mark position of closing symbols with negative values
  signedsymbolposition = symbolposition;
  signedsymbolposition(ismember(symbolposition, closeposition)) = -symbolposition(ismember(symbolposition, closeposition));

  ## returned labels  
  label = zeros(1, numel(signedsymbolposition));
  
  nestinglevel = 0;
  for idposition = 1 : numel(signedsymbolposition)
    if signedsymbolposition(idposition) > 0
      ## label opening symbol
      nestinglevel++;
      label(idposition) = nestinglevel;
    else
      ## label closing symbol
      label(idposition) = -nestinglevel;
      nestinglevel--;    
    end
  end

end
