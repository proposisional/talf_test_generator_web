function R = unionrelation(R1, R2)
## Union of two relations
##
## examples
##   {(a, b), (c, c)} ∪ {(b, a)}
##   unionrelation({["a", "b"], ["c", "c"]}, {["b", "a"]})
##
## 2023/01/31 version 0.1 - fjvico@uma.es  GNU GPL v3.0
## 2018/09/29 version 0.0 - fjvico@uma.es  GNU GPL v3.0

  unionsymbol = " ∪ ";

  R = R1;
  for idpair2 = 1 : numel(R2)
    for idpair1 = 1 : numel(R1)
      newelement = true;
      if isequal(R2{idpair2}(1), R1{idpair1}(1)) && ...
         isequal(R2{idpair2}(2), R1{idpair1}(2))
         ## this element of R2 is already in R1
         newelement = false;
         break;
      end
      if newelement
        ## add element in R2 if not in R1
        R = [R R2{idpair2}];
        break
      end
    end
  end
  
  ## remove repetitions, in any
  R = unique(R);

  prettyprintrelation(R1);
  printf("%s", unionsymbol)
  prettyprintrelation(R2);
  printf(" = ")
  prettyprintrelation(R, true);

end
