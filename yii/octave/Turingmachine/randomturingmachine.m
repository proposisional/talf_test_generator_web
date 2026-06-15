function matrix = randomturingmachine(numberstates, alphabet, emptysymbol, randomseed)
% randomturingmachine(numberstates, alphabet, emptysymbol, randomseed)
%
% Generates a table for a random Turing Machine
%
% For example:
%
%    >> randomturingmachine(2, "|")
%    ans = 
%    {
%      [1,1] = 
%      {
%        [1,1] = q0
%        [1,2] = *
%        [1,3] = h
%        [1,4] = q1
%      }
%      [1,2] = 
%      {
%        [1,1] = q0
%        [1,2] = |
%        [1,3] = |
%        [1,4] = q1
%      }
%      [1,3] = 
%      {
%        [1,1] = q1
%        [1,2] = *
%        [1,3] = |
%        [1,4] = q1
%      }
%      [1,4] = 
%      {
%        [1,1] = q1
%        [1,2] = |
%        [1,3] = *
%        [1,4] = q0
%      }
%    }
%
%
%   >> turingmachine(randomturingmachine(3, "|"), "*")
%   q0 * r q2
%   q0 | l q1
%   q1 * r q0
%   q1 | | q0
%   q2 * | q1
%   q2 | h q1
%   
%   (q0, *, 1) ⊢ (q2, **, 2) ⊢ (q1, *|*, 2) ⊢ (q0, *|*, 2) ⊢ (q1, *|*, 1) ⊢ (q0, *|*, 2) ...
%
%
%   >> savejson("matrix", randomturingmachine(2, "|"), "test.json")
%   >> turingmachine("test", "*|||*")
%
% ===============================================================
%
%   fjv, 18/12/2021   GNU GPL v3.0
%
% ===============================================================


  if exist('randomseed', 'var')
    rand('seed', randomseed);
  end

  ## define the empty symbol
  if !exist('emptysymbol', 'var')
    emptysymbol = "*";
  end
  
  ## add empty symbol to the alphabet
  alphabet = strcat(emptysymbol, alphabet);

  ## create table
  matrix = {};
  idline = 0;
  for idstate = 0 : numberstates - 1
    state = strcat('q', num2str(idstate));
    for idsymbol = 1 : numel(alphabet)
      matrix{++idline} = {state, alphabet(idsymbol), makeinstruction(alphabet), makestate(numberstates)};
    end
  end


  function instruction = makeinstruction(alphabet)
  ## random instruction
  
    alphabet = strcat("hlr", alphabet);
    instruction = alphabet(ceil(numel(alphabet) * rand));
  end


  function state = makestate(numberstates)
  ## random state
    
    state = strcat('q', num2str(floor(numberstates * rand)));    
  end

end
