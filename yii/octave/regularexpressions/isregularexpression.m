function valid = isregularexpression(alphabet, expression)
# valid = isregularexpression(alphabet, expression)
#
# Check if a string is a regular expressions over a given alphabet.
# `alphabet` is a string with the symbols of the alphabet.
# `expression` is a string expression.
#
# Examples:
#
#   isregularexpression('01','((10)01)')
#   ans = 0
# 
#   isregularexpression('01','((10)+(01)**)')
#   ans = 1
# 
# ===============================================================
#
#   fjv, 10/10/2023  GNU GPL v3.0
#
# ===============================================================

  ## default value
  valid = false;

  ## ASCII symbol 0 replaces the Unicode symbol for the empty set
  emptysetalias = char(0);
  emptysetalias = '.';
  if !all(isascii(expression))
    ## the empty set symbol might have been replace in a previous call
    expression = strrep(expression, '∅', emptysetalias);
  end

  extendedalphabet = strcat(emptysetalias, alphabet);

  if numel(expression) == 1
    ## case of a single-symbol expression (Unicode ∅ replaced by another symbol so it counts as one character)
    valid = ismember(expression, extendedalphabet);

  else
    ## case of a concatenation, union or Kleene star of expressions
    if strcmp(expression(end), '*')
      ## case of Kleene star
      valid = isregularexpression(alphabet, expression(1 : end - 1));

    else
      ## case of concatenation or union

      if strcmp(expression(1), '(') && strcmp(expression(end), ')')
        ## remove external parenthesis
        expression = expression(2 : end - 1);

        ## find balanced parenthesis
        [position, label] = labelbalancedsymbols(expression, '(', ')');

        ## focus on the first level of nested parenthesis
        onesposition      = find(label ==  1);
        minusonesposition = find(label == -1);
        if numel(onesposition) != numel(minusonesposition)
          ## case of parentheses not matching
          return;
        end
        if numel(onesposition) == 0
          ## none of the regular expressions are concatenations or unions (e.g. (0+1) or (1***∅) )
          plusposition = find(expression == '+');
          if !isempty(plusposition)
            ## it is a union
            firstExpression  = expression(1 : plusposition - 1);
            secondExpression = expression(plusposition + 1 : end);
            if numel(firstExpression) + numel(secondExpression) == numel(expression) - 1
              ## there are no extra symbols in the expression
              valid = isregularexpression(alphabet, firstExpression) && ...
                      isregularexpression(alphabet, secondExpression);
            end

          else
            ## it is a concatenation
            singlesymbols = find(ismember(expression, extendedalphabet));
            if numel(singlesymbols) == 2
              ## only two symbols are expected
              firstExpression  = expression(singlesymbols(1) : singlesymbols(2) - 1);
              secondExpression = expression(singlesymbols(2) : end);
              if numel(firstExpression) + numel(secondExpression) == numel(expression)
                ## there are no extra symbols in the expression
                valid = isregularexpression(alphabet, firstExpression) && ...
                        isregularexpression(alphabet, secondExpression);
              end
            end
          end

        elseif numel(onesposition) == 1
          ## one of the regular expressions is a concatenation or union (e.g. (0(1+1)) or (((10)+1)∅) )
          ##                                                                   ^                   ^
          if strcmp(expression(1), '(')
            ## the first regular expression is a concatenation or union
            ## check if the first expression has Kleene stars
            startSecond = position(minusonesposition(1)) + 1;
            while strcmp(expression(startSecond), '*')
              startSecond++;
            end
            firstExpression  = expression(position(onesposition(1)) : startSecond - 1);
            secondExpression = expression(startSecond : end);
            if strcmp(secondExpression(1), '+')
              ## remove '+' symbol if union
              secondExpression = secondExpression(2 : end);
            end
            if numel(firstExpression) + numel(secondExpression) == numel(expression)
              ## there are no extra symbols in the expression
              valid = isregularexpression(alphabet, firstExpression) && ...
                      isregularexpression(alphabet, secondExpression);
            end
          else
            ## the first regular expression is a not concatenation or union
            firstExpression = expression(1 : position(onesposition(1)) - 1);
            if strcmp(firstExpression(end), '+')
              ## remove '+' symbol if union
              firstExpression = firstExpression(1 : end - 1);
            end
            secondExpression = expression(position(onesposition(1)) : position(minusonesposition(1)));
            if numel(firstExpression) + numel(secondExpression) == numel(expression)
              ## there are no extra symbols in the expression
              valid = isregularexpression(alphabet, firstExpression) && ...
                      isregularexpression(alphabet, secondExpression);
            end
          end

        else
          ## both regular expressions are concatenations or unions
          firstExpression  = expression(position(onesposition(1)) : position(minusonesposition(1)));
          secondExpression = expression(position(onesposition(2)) : position(minusonesposition(2)));
          if numel(firstExpression) + numel(secondExpression) == numel(expression)
            ## there are no extra symbols in the expression
            valid = isregularexpression(alphabet, firstExpression) && ...
                    isregularexpression(alphabet, secondExpression);
          end
        end
      end
    end

  end

end
