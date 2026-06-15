function [result, computation] = pushdownautomaton(automatonname, inputstring, desiredoutput, formatoption, randomseed)
% [result, computation] = pushdownautomaton(automatonname, inputstring, desiredoutput, formatoption, randomseed)
%
% Computation for a given pushdown automaton and input string.
%
%   automatonname : name of the automaton as the label in the definition file
%   inputstring   : string to be accepted or rejected
%   desiredoutput : result to be expected, since the NPA is non-deterministic
%                   'any'      anyone of the others (default option)
%                   'accept'   accepted string
%                   'reject'   rejected string in non final state, or
%                   'blocked'  rejected string with blocked computation.
%   formatoption  : how the output is generated
%                   'text'     ASCII (default option)
%                   'LaTeX'    LaTeX code for LN
%   randomseed    : seed for the random numbers generator
%
% The automaton is defined in a definition file with JSON format, like this:
%
%  {
%    "name" : "0^n1^n",
%    "representation" : {
%      "K" : ["q0", "q1"],
%      "A" : ["0", "1"],
%      "s" : "q0",
%      "F" : ["q1"],
%      "t" : [[["q0", "0", "ε"],["q0", "0"]],
%             [["q0", "1", "0"],["q1", "ε"]],
%             [["q1", "1", "0"],["q1", "ε"]]]
%      }
%  }
%
% Examples
%
%    >> pushdownautomaton("|w|0=|w|1", "00011");
%    
%    M = ({q0}, {0, 1}, q0, {q0}, {((q0, 0, ε), (q0, 0)), ((q0, 1, ε), (q0, 1)), ((q1, 0, 1), (q0, ε)), ((q0, 1, 0), (q0, ε))})
%    
%    w = 00011
%    
%    (q0, 00011, ε) ⊢ (q0, 0011, 0) ⊢ (q0, 011, 00) ⊢ (q0, 11, 000) ⊢ (q0, 1, 00) ⊢ (q0, ε, 0)
%
%    w ∉ 𝓛(M) (blocked computation)
%
%
%    >> pushdownautomaton("0^n1^n", "0011", "accept");
%
%    M = ({q0, q1}, {0, 1}, q0, {q1}, {((q0, 0, ε), (q0, 0)), ((q0, 1, 0), (q1, ε)), ((q1, 1, 0), (q1, ε))})
%
%    w = 0011
%    
%    (q0, 0011, ε) ⊢ (q0, 011, 0) ⊢ (q0, 11, 00) ⊢ (q1, 1, 0) ⊢ (q1, ε, ε)
%    
%    w ∈ 𝓛(M)
%
%
%    >> pushdownautomaton("singleEstate", "a", "blocked", "LaTeX");
%
%    $M = (\{q_0\}, \{a, b\}, \{a, b\}, q_0, \{q0\}, \{((q0, a, ε), (q0, a)), ((q0, b, a), (q0, ε))\})$
%
%    $w = a$
%
%    $(q0, a, \varepsilon) \vdash (q0, \varepsilon, a)$
%
%    w ∉ 𝓛(M) (blocked computation)
%
% ===============================================================
%
%   fjv, 27/92/2023   desired output added
%   fjv, 19/10/2022   printautomaton fixed
%   fjv, 19/10/2022   printautomaton completed with LaTeX option
%   fjv, 05/01/2022   accepts special characters in the alphabet (regexp)
%   fjv, 02/01/2022   GNU GPL v3.0
%
% ===============================================================

  emptystring       = "ε";
  transitionsymbol  = "⊢";
  languagesymbol    = "𝓛";
  insymbol          = "∈";
  notinsymbol       = "∉";
  openbracket       = "{";
  closebracket      = "}";
  emptystringLaTeX  = "\\varepsilon";
  mathmodedelimiter = "";

  anylabel     = 'any';
  acceptlabel  = 'accept';
  rejectlabel  = 'reject';
  blockedlabel = 'blocked';

  ## check if called from LuaTex and adapt special characters
  files = dbstack;
  caller = files(end).file;
  emptystringoutput = emptystring;
  transitionsymbolLaTeX = "\\vdash";

  # TBD: import string `runexample.m` from configuration file
  if strfind(caller, "runexample.m")
    languagesymbol    = "$\\pazocal{L}$";
    emptystringoutput = cstrcat("$", emptystringLaTeX, "$");
    transitionsymbolLaTeX  = cstrcat("$", transitionsymbol, "$");
    openbracket       = strcat("\\", openbracket);
    closebracket      = strcat("\\", closebracket);
  end

  if !exist('desiredoutput', 'var')
    desiredoutput = 'any';
  end

  if exist('randomseed', 'var')
    rand('seed', randomseed);
  end

  # TBD: import `pushdownautomata` from a configuration file (not existing yet)
  ## database of finite automata
  automatadatabasename = 'pushdownautomata';

  # TBD: import path from a configuration file
  addpath("../util/");
  
  if exist('formatoption', 'var') && strcmp(formatoption, "LaTeX")
    formatoptionLaTeX = true;
  else
    formatoptionLaTeX = false;
  end

  if formatoptionLaTeX
    languagesymbol    = "\\pazocal{L}";
    insymbol          = "\\in";
    notinsymbol       = "\\notin";
    mathmodedelimiter = "$";
  end

  ## characters to be scaped for regular expression matching
  specialcharacters = "()[]+*.\\";
  
  ## load automaton definition from JSON file
  automaton = loadrepresentation(automatadatabasename, automatonname);

  printautomaton(automaton, inputstring, formatoptionLaTeX);

  ## define initial configuration
  initialconfiguration = {automaton.s, inputstring, ""};

  ## perform a complete or blocked computation according to the desired output
  computation = compute(initialconfiguration);

  ## print computation
  printf("%s", mathmodedelimiter);
  # print initial configuration
  printconfiguration(computation{1}, inputstring, formatoptionLaTeX);
  # print the next configurations
  for idconfiguration = 2 : numel(computation)
    ## compute while the automaton can transit to a next configuration
    if formatoptionLaTeX
      printf(" %s ", transitionsymbolLaTeX);
    else
      printf(" %s ", transitionsymbol);
    end
    printconfiguration(computation{idconfiguration}, emptystring, formatoptionLaTeX);
  end
  printf("%s", mathmodedelimiter);
  printf("\n\n");

  ## print acceptance result
  if isempty(computation{end}{2}) && isempty(computation{end}{3})
    if ismember(computation{end}{1}, automaton.F)
      printf("%sw %s %s(M)%s\n", mathmodedelimiter, insymbol, languagesymbol, mathmodedelimiter);
    else
      printf("w not accepted by M.\n");
    end
  else
    printf("Blocked computation, w not accepted by M.\n");
  end


  function computation = compute(initialconfiguration)

    ## perform the computation until the desired output is reached
    do

      computation = {};

      computation{1} = initialconfiguration;
      currentconfiguration = computation{1};
      do
        ## compute while the automaton can transit to a next configuration
        [nextconfiguration, unabletotransit] = transit(automaton.t, currentconfiguration);
        if !unabletotransit
          currentconfiguration = nextconfiguration;
          computation{end + 1} = currentconfiguration;
        end
      until unabletotransit;

      ## check if the automaton has done the right thing
      if isempty(currentconfiguration{2}) && isempty(currentconfiguration{3})
        ## input string and stack are empty
        terminalstate = currentconfiguration{1};
        if ismember(terminalstate, automaton.F)
          ## terminal state is a final state
          result = acceptlabel;
        else
          ## terminal state is not a final state
          result = rejectlabel;
        end
      else
        ## input string or stack are not empty
        result = blockedlabel;
      end
    until strcmp(result, desiredoutput) || strcmp(desiredoutput, anylabel);

  end
  

  function [nextconfiguration, unabletotransit] = transit(relation, currentconfiguration)
  ## transit from current to next configuration, if possible

    state  = currentconfiguration{1};
    string = currentconfiguration{2};
    stack  = currentconfiguration{3};
    
    nextconfiguration = {};
    validtransitions = 0;
    ## check what are valid transitions from current state and string
    for transitionid = 1 : numel(relation)
      ## get transition, e.g. ((q0, abc, a), (q1, b))
      transition     = relation{transitionid};
      currentstate   = transition{1}{1};
      consumedstring = transition{1}{2};
      consumedstack  = transition{1}{3};
      nextstate      = transition{2}{1};
      writestack     = transition{2}{2};
      
      if strcmp(consumedstring, emptystring)
        consumedstring = "";
      end
      if strcmp(consumedstack, emptystring)
        consumedstack = "";
      end
      if strcmp(writestack, emptystring)
        writestack = "";
      end
    
      ## check if this transition starts from the current state
      if strcmp(state, currentstate)
        stringtest = true;
        ## check if consumedstring is a prefix of string
        if !isempty(consumedstring)
          ## scape special characters
          if ismember(consumedstring, specialcharacters)
            pattern = strcat("\\", consumedstring);
          else
            pattern = consumedstring;
          end
          [first, last] = regexp(string, pattern);
          stringtest = !isempty(first) && first(1) == 1;
          if stringtest
            ## it is a prefix
            if last(1) == numel(string)
              ## the automaton consumes all the remaining symbols
              nextstring = "";
            else
              ## the automaton consumes only some symbols
              nextstring = substr(string, last(1) + 1);
            end           
          end
        else
          nextstring = string;
        end
        
        ## check if consumedstack string is a prefix of stack
        ## default: the stack remains the same
        stacktest = true;
        ## check if consumedstack is a prefix of stack
        nextstack = stack;
        if !isempty(consumedstack)
          ## scape special characters
          if ismember(consumedstack, specialcharacters)
            pattern = strcat("\\", consumedstack);
          else
            pattern = consumedstack;
          end
          [first, last] = regexp(stack, pattern);
          ## pop: remove symbols from the top
          stacktest = !isempty(first) && first(1) == 1;
          if stacktest
            ## it is a prefix
            if last(1) == numel(stack)
              ## the automaton consumes all the remaining symbols
              nextstack = "";
            else
              nextstack = substr(stack, last(1) + 1);
            end
          end
        else
          ## consumedstack is an empty string
          nextstack = stack;
        end

        ## the automaton can consume symbols from the string and the stack
        ## (or there is nothing to consume)
        if stringtest && stacktest
          ## push: add symbols at the top
          nextstack = cstrcat(writestack, nextstack);
          nextconfiguration{++validtransitions} = {nextstate, nextstring, nextstack};
        end

      end
    end

    unabletotransit = (numel(nextconfiguration) == 0);
    if !unabletotransit
      ## choose one transition among the valid ones
      nextconfiguration = nextconfiguration{ceil(rand * numel(nextconfiguration))};
    end
  end


  function printconfiguration(configuration)
  ## print formatted configuration, e.g. (q0, 0011, ε)

    string = configuration{2};
    stack  = configuration{3};

    if isempty(string)
      ## represent with empty string symbol
      string = emptystringoutput;
    end
    if strcmp(string, emptystring) && formatoptionLaTeX
      string = emptystringLaTeX;
    end

    if isempty(stack)
      ## represent with empty string symbol
      stack = emptystringoutput;
    end
    if strcmp(stack, emptystring) && formatoptionLaTeX
      stack = emptystringLaTeX;
    end

    printf("(%s, %s, %s)", formatstate(configuration{1}, formatoptionLaTeX), string, stack);
  end


  function state = formatstate(state, formatoptionLaTeX)
  
    if formatoptionLaTeX
      state = sprintf("%s_%s", state(1),state(2:end));
    end  
  end
  
  
  function printautomaton(automaton, inputstring, formatoptionLaTeX)
  ## print formatted automaton, e.g.
  ## M = ({q0, q1}, {0, 1}, {((q0, 0, ε), (q0, 0)), ((q0, 1, 0), (q1, ε)), ((q1, 1, 0), (q1, ε))}, q0, {q0, q1})
  ## w = 0011

    ## format states
    K = "";
    for element = 1 : numel(automaton.K)
      if element > 1
        K = cstrcat(K, ", ");
      end
      K = cstrcat(K, formatstate(automaton.K{element}, formatoptionLaTeX));
    end

    ## format input alphabet
    I = "";
    for element = 1 : numel(automaton.I)
      if element > 1
        I = cstrcat(I, ", ");
      end
      I = cstrcat(I, automaton.I{element});
    end
    
    ## format stack alphabet
    S = "";
    for element = 1 : numel(automaton.S)
      if element > 1
        S = cstrcat(S, ", ");
      end
      S = cstrcat(S, automaton.S{element});
    end
    
    ## initial state
    s = formatstate(automaton.s, formatoptionLaTeX);

    ## format final states
    F = "";
    for element = 1 : numel(automaton.F)
      if element > 1
        F = cstrcat(F, ", ");
      end
      F = cstrcat(F, formatstate(automaton.F{element}, formatoptionLaTeX));
    end

    ## format transition relation  
    t = "";
    for transitionid = 1 : numel(automaton.t)
      if transitionid > 1
        t = cstrcat(t, ", ");
      end
      transition = automaton.t{transitionid};
      consumedstring = transition{1}{2};
      consumedstack  = transition{1}{3};
      writestack     = transition{2}{2};
      if strcmp(consumedstring, emptystring) || isempty(consumedstring)
        consumedstring = emptystringoutput;
      end
      if strcmp(consumedstack, emptystring) || isempty(consumedstack)
        consumedstack = emptystringoutput;
      end
      if strcmp(writestack, emptystring) || isempty(writestack)
        writestack = emptystringoutput;
      end

      if strcmp(consumedstring, emptystring) && formatoptionLaTeX
        consumedstring = emptystringLaTeX;
      end
      if strcmp(consumedstack, emptystring)  && formatoptionLaTeX
        consumedstack = emptystringLaTeX;
      end
      if strcmp(writestack, emptystring)     && formatoptionLaTeX
        writestack = emptystringLaTeX;
      end

      t = cstrcat(t, "((", formatstate(transition{1}{1}, formatoptionLaTeX), ", ", consumedstring, ", ", consumedstack, "), (", formatstate(transition{2}{1}, formatoptionLaTeX), ", ", writestack,"))");
    end
  
    if formatoptionLaTeX
      printf("\n$M = (\\{%s\\}, \\{%s\\}, \\{%s\\}, \\{%s\\}, %s, \\{%s\\})$\n", K, I, S, t, s, F);
      printf("\n$w = %s$\n\n", inputstring);
    else
      printf("\nM = (%s%s%s, %s%s%s, %s%s%s, %s%s%s, %s, %s%s%s)\n", openbracket, K, closebracket, openbracket, I, closebracket, openbracket, S, closebracket, openbracket, t, closebracket, s, openbracket, F, closebracket);
      printf("\nw = %s\n\n", inputstring);
    end

  end
    
end
