function R = powerrelation(R1, n)
## Power n of a relation R1, or its transitive closure (if n undefined)
##
## examples
##   {(a, b), (c, c), (b, a)}³
##   powerrelation({["a", "b"], ["c", "c"], ["b", "a"]}, 3)
##
##   ans = 
##   {
##     [1,1] = ab
##     [1,2] = ba
##     [1,3] = cc
##   }
##
##   {(a, b), (c, c), (b, a)}∞
##   powerrelation({["a", "b"], ["c", "c"], ["b", "a"]})
##   ans = 
##   {
##     [1,1] = aa
##     [1,2] = ab
##     [1,3] = ba
##     [1,4] = bb
##     [1,5] = cc
##   }
##
##   Ordered pairs can also be formatted like this:
##   powerrelation({"ab", "cc", "ba"})
##
## 2023/01/31 version 0.1 - fjvico@uma.es  GNU GPL v3.0
## 2018/09/29 version 0.0 - fjvico@uma.es  GNU GPL v3.0

  exponentsymbol = "^";
  infinitesymbol = "∞";
  
  ## check if called from LuaTex and adapt special characters
  files = dbstack;
  caller = files(end).file;

  if strfind(caller, "runexample.m")
    exponentsymbol = "\\textsuperscript";
    infinitesymbol = "\\infty";
  end

  Roriginal = R1;

  if exist("n", "var")
  	## case of finite exponent (R^n)

    ## store the input R1 as a cell array, and further powers likewise
    R1 = {R1};
    for exponent = 2 : n
      Rprevious = R1{exponent - 1};
      Rcurrent  = {};
    
      for previouspair = 1 : numel(Rprevious)
        ## browser all pairs in the previous power relation
	      previouselement1 = Rprevious{previouspair}(1);
	      previouselement2 = Rprevious{previouspair}(2);
	      ## search for pairs in the original relation
	      for originalpair = 1 : numel(Roriginal)
          originalelement1 = Roriginal{originalpair}(1);
          originalelement2 = Roriginal{originalpair}(2);
          if isequal(previouselement2, originalelement1)
            ## add a new element
            Rcurrent = [Rcurrent {[previouselement1, originalelement2]}];
          end
        end
      end
    
      R1{exponent} = Rcurrent;
    end

    ## return last power    
    relation = R1{end};
    ## remove repetitions, in any
    R = unique(relation);

    prettyprintrelation(Roriginal);
    printf("%s%d = ", exponentsymbol, n)
    prettyprintrelation(R, true);
  else
  	## case of transitive closure (R1^∞)
  	exponent = 1;
  	do
      ## increase exponent
  	  exponent++;
  	  Rprevious = R1;
      ## compute power n and add
  	  R1 = unionrelation(R1, powerrelation(Roriginal, exponent));
      # character U+2001 (Em Quad) allows an empty line between printed powers
      printf("\n \n")
  	until isempty(setxor(Rprevious, R1))

    ## return the result of the union
  	relation = R1;
  	R = unique(relation);
    prettyprintrelation(Roriginal);
    printf("%s%s = ", exponentsymbol, infinitesymbol)
    prettyprintrelation(R, true);
  end

end
