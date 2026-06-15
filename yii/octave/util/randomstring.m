function outstring = randomstring(targetset, N, T)
# make a string according to a pattern ('N', 'T', 'V+', 'V*')

  epsilon   = 'ε';
  lowercase = 'a':'z';
  uppercase = 'A':'Z';
  middlesymbol = 13;
  maxstringlength = 5;

  # set of all terminal and non-terminal symbols
  V = strcat(N, T);


  function targetset = symbol2set(symbol)

    if ismember(symbol, lowercase(1 : middlesymbol))
      # a, b, c, d
      targetset = 'T';
    elseif ismember(symbol, lowercase(middlesymbol + 1 : end))
      # w, x, y, z
      targetset = 'V*';
    elseif ismember(symbol, uppercase(1 : middlesymbol))
      # A, B, C, D
      targetset = 'N';
    elseif double(symbol) == 177
      # α
      targetset = 'V+';
    else
      # β, γ
      targetset = 'V*';
    end
  end


  if !ismember(targetset(1), 'NTV')
    # set is given by a letter, instead
    targetset = symbol2set(targetset);
  end

  switch targetset(1)
    case 'T'
      alphabet = T;
    case 'N'
      alphabet = N;
    case 'V'
      alphabet = V;
  end

  # determine output length
  if length(targetset) == 1
    stringlength = 1;
  elseif strcmp(targetset(2), '+')
    # empty string is not allowed
    stringlength = ceil(maxstringlength * rand);
  else
    # empty string is allowed
    stringlength = ceil((maxstringlength + 1) * rand) - 1;
  end

 
  if stringlength == 0
    # empty string
    outstring = epsilon;
  else
    # non-empty string
    outstring = alphabet(ceil(length(alphabet) * rand(1, stringlength)));
  end
  
end
