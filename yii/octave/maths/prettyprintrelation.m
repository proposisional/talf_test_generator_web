function prettyprintrelation(R, newline)
## Formatted print out of a relation
##   R is a relation, newline is an optional boolean (false by default)
##
## examples
##   R = {["a", "b"], ["c", "c"]}
##   prettyprintrelation(R)
##   prettyprintrelation(R, true)
##
## 2023/01/31 version 0.0 - fjvico@uma.es  GNU GPL v3.0

  openbracket  = "{";
  closebracket = "}";

  ## check if called from LuaTex and adapt special characters
  files = dbstack;
  caller = files(end).file;

  if strfind(caller, "runexample.m")
    openbracket  = strcat("\\", openbracket);
    closebracket = strcat("\\", closebracket);
  end


  ## pretty output
  if numel(R) == 0
    printf("∅");
  else
    printf("%s", openbracket);
    for idpair = 1 : numel(R)
      printf("(%s,%s)", R{idpair}(1), R{idpair}(2));
      if idpair != numel(R)
        printf(", ");
      end
    end
    printf("%s", closebracket);
  end
  
  if exist("newline", "var") && newline
    printf("\n");
  end

end
