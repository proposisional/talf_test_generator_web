function rule = makerule(typerule, N, T, showrule)
## rule = makerule(typerule, N, T, showrule)
##
## Make a rule of a given type (0..3), which is not of a lower type.
## The resulting rule is made of a two-elements list.
## Optionally, non-terminal and terminal alphabets can be provided as arguments.
##
## Examples:
##   rule = makerule(2);
##   rule = makerule(0, 'ABC', '01');
##
## =========================================================================
##
##   fjv, 07/11/2022   GNU GPL v3.0
##
## =========================================================================

  addpath("../util");

  ## separator character in a rule
  separator = '->';
  epsilon   = 'ε';

  if !exist('N', 'var')
    # non-terminal alphabet
    N = 'A':'G';
  end
  if !exist('T', 'var')
    # terminal alphabet
    T = 'a':'g';
  end
  if !exist('showrule', 'var')
    # print the rule
    showrule = true;
  end

  
  function prettyprintrule(rule, separator)
  
    fprintf(stderr, "type %d - %s: %s %s %s\n", rule.type.number, rule.type.name, rule.side{1}, separator, rule.side{2});
  end


  do
    leftside  = randomstring('V+', N, T);
    rightside = randomstring('V*', N, T);
    rule.side = {leftside, rightside};
    rule.type = ruletype(rule.side, N, T);
  until rule.type.number == typerule
  
  if showrule
    prettyprintrule(rule, separator);
  end

end
