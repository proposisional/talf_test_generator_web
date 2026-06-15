function strings = re(strings, pattern, substrings)
# strings = re(strings, pattern[, substrings])
#
# Finds the strings that match a given pattern (without overlap).
# The strings can be represented in three different ways:
#   {'10001', '0000', '111111101101'}  // as a cell array of strings
#   '10001 0000 111111101101'          // as space-separated strings
#   filename                           // the string is loaded from filename
# The optional substrings is used to search for substrings that match the pattern.
#   Its default value is false.
#
# Examples:
#
#    re({'10001', '0000', '111111101101'}, '10*1')
#    ans = 
#    {
#      [1,1] = 
#      {
#        [1,1] = 10001
#      }
#    }
#
#    re({'10001', '0000', '111111101101'}, '10*1', true)
#    ans = 
#    {
#      [1,1] = 
#      {
#        [1,1] = 10001
#      }
#      [1,2] = 
#      {
#        [1,1] = 11
#        [1,2] = 11
#        [1,3] = 11
#        [1,4] = 101
#        [1,5] = 101
#      }
#    }
#
#    re('001011 00100100 11100111101', '(0+1)*10*1(0+1)*')
#    ans = 
#    {
#      [1,1] = 
#      {
#        [1,1] = 001011
#      }
#      [1,2] = 
#      {
#        [1,1] = 00100100
#      }
#      [1,3] = 
#      {
#        [1,1] = 11100111101
#      }
#    }
#
#    To generate a random string over an alphabet, this line will suffice:
#
#    >> '01'(ceil(end * rand(1,5)))
#    ans = 10110
#    >> 'ATCG'(ceil(end * rand(1,10)))
#    ans = TTTATGGGCA
#
#    >> re('ATCG'(ceil(end * rand(1,1000))), 'GG(A+T)*CC', true)
#    ans = 
#    {
#      [1,1] = GGTCC
#      [1,2] = GGTATCC
#      [1,3] = GGCC
#      [1,4] = GGACC
#      [1,5] = GGTACC
#    }
#
#    >> re('01'(ceil(end * rand(1,100))), '110*11', true)
#    ans = 
#    {
#      [1,1] = 11011
#      [1,2] = 1111
#      [1,3] = 1111
#      [1,4] = 110011
#      [1,5] = 11011
#    }
#
#   It can also be invoked with a textfile name (newline characters are ignored).
#   This example searchs for sequences between the start codon and any 
#   stop codon in a human NDA sequence of chromosome 21*:
#
#    >> re('dnasequence.txt', 'ATG(A+T+C+G)*(TAG+TGA+TAA)', true)
#    ans = 
#    {
#      [1,1] = ATGACAGAGTGAGGGCCATCACTGTTAATGA
#      [1,2] = ATGGAATAG
#      [1,3] = ATGACAGTTACTTCCCTAGGTAGTCTGCATGTTGGGCCTCCCAGGACTGGTTCTCTAA
#      ...
#    }
#
#    But codons are sequences of length 3. This is captured by this regular expression:
#
#    >> re('dnasequence.txt', 'ATG((A+T+C+G){3})*(TAG+TGA+TAA)', true)
#    ans = 
#    {
#      [1,1] = ATGACAGAGTGA
#      [1,2] = ATGGAATAG
#      [1,3] = ATGTTGGGCCTCCCAGGACTGGTTCTCTAA
#      ...
#    } 
#
#    * data extracted from ftp://ftp.ncbi.nih.gov/genomes/Homo_sapiens/CHR_21/hs_ref_GRCh38.p12_chr21.fa.gz
#      more datafiles in   ftp://ftp.ncbi.nih.gov/genomes/
#
# ===============================================================
#
#   fjv, 21/10/2018  GNU GPL v3.0
#   fjv, 22/10/2018  returns multiple occurrencies of a pattern
#   fjv, 13/10/2019  substrings argument added
#
# ===============================================================

  ## if in a single string, individual strings are delimited by one or more spaces
  separator = ' ';

  ## check substrings argument
  if nargin < 3
    substrings = false;
  end

  ## replace '+' (or) symbol of theoretical model by '|' of Octave regexp model
  pattern = strrep(pattern, '+', '|');

  if ischar(strings)
    ## the string might be a textfile name
    if exist(strings, 'file')
      ## read textfile discarding newline characters
      strings = textread(strings, '%s', 'endofline', ''){1};
      strings(1:50)
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
  
  onesinglestring = (numel(strings) == 1);
  
  ## find strings matching the expression
  [~, ~, ~, match] = regexp(strings, pattern);

  if substrings
    ## return matched strings
    strings = match(find(!@cellfun("isempty", match)));
  else
    # alternative for extracting only the strings that match, not the substrings
    strings = match(find(!@cellfun("isempty", match) & @cellfun("numel", match) == 1));
  end

  if onesinglestring && numel(strings) > 0
    ## extract only the matches if only one string at the input
    strings = strings{1};
  end

  for idstring = 1 : size(strings, 2)
    printf("\n")
    strings{idstring} = unique(strings{idstring});
    for idsubstring = 1 : size(strings{idstring}, 2)
      printf("  %s ∈ %s\n", strings{idstring}{idsubstring}, pattern)
    end
  end
end
