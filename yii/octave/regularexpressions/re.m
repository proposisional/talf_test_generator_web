function strings = re(strings, pattern)
# strings = re(strings, pattern)
#
# Finds the strings that match a given pattern (without overlap).
# The strings can be represented in three different ways:
#   {'10001', '0000', '111111101101'}  // as a cell array of strings
#   '10001 0000 111111101101'          // as space-separated strings
#   filename                           // the string is loaded from filename
#
# Examples:
#
#    re('10001 0000 100000001 11 11', '10*1');
#    
#    10001 ∈ 10*1
#    
#    100000001 ∈ 10*1
#    
#    11 ∈ 10*1
#    
#
#    re('10001 0000 01010100010001 11101', '(0*+1*)10*1');
#    
#    10001 ∈ (0*+1*)10*1
#    
#    11101 ∈ (0*+1*)10*1
#    
#
#    To generate a random string over an alphabet, this line will suffice:
#
#    >> '01'(ceil(end * rand(1, 5)))
#    ans = 10110
#    >> 'ATCG'(ceil(end * rand(1, 10)))
#    ans = TTTATGGGCA
#
#   It can also be invoked with a textfile name (newline characters are ignored).
#
# ===============================================================
#
#   fjv, 30/09/2023  some bugs fixed, output formatted to align
#   fjv, 25/09/2023  substrings removed
#   fjv, 13/10/2019  substrings argument added
#   fjv, 22/10/2018  returns multiple occurrencies of a pattern
#   fjv, 21/10/2018  GNU GPL v3.0
#
# ===============================================================
#
# TBD: include epsilon and generate strings by replacing * with numbers
#

  ## if in a single string, individual strings are delimited by one or more spaces
  separator = ' ';

  spacesymbol = ' ';

  ## check if called from LuaTex and adapt special characters
  files = dbstack;
  caller = files(end).file;
  if strfind(caller, "runexample.m")
    # Em Quad (U+2001)
    spacesymbol = native2unicode([226  128  129]);
  end

  ## replace '+' (or) symbol of theoretical model by '|' of Octave regexp model
  originalpattern = pattern;
  pattern = strrep(pattern, '+', '|');
  ## include word anchors and parenthesis to match whole words
  pattern = strcat('^(', pattern, ')$');

  if ischar(strings)
    ## the string might be a textfile name
    if exist(strings, 'file')
      ## read textfile discarding newline characters
      strings = textread(strings, '%s', 'endofline', ''){1};
    end
    
    ## convert space-separated strings into an array of strings
    liststrings = {};
    while !isempty(strings)
      ## find strings separated by one or more spaces
      [string, strings] = strtok(strings, separator);
      ## add to list removing leading and trailing spaces
      liststrings = [liststrings, strtrim(string)];
    end
    strings = liststrings;
  end
  
  ## find strings matching the expression
  [~, endchar, ~, match] = regexp(strings, pattern);

  # extract only the strings that match, not the substrings
  filteredstrings = {};
  for idstring = 1 : numel(strings)
    if endchar{idstring} == numel(strings{idstring})
      filteredstrings{end + 1} = strings{idstring};
    end
  end

  % remove duplicates
  strings = unique(filteredstrings, "stable");

  maxlength = max(cellfun('numel', strings(1 : size(strings, 2))));
  for idstring = 1 : size(strings, 2)
    printf("\n")
    filling = repmat(spacesymbol, 1, maxlength - numel(strings{idstring}) + 1);
    printf("  %s%s∈%s%s\n", strings{idstring}, filling, spacesymbol, originalpattern)
  end

end
