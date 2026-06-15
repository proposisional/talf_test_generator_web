function dfa = dfa2dfawoinaccessiblestates(automatadatabasename, automatonname)
% dfa2dfawoinaccessiblestates(automatadatabasename, automatonname)
%
% Transforms an DFA in the database into another DFA without inaccessible states.
%
%  [
%   {
%     "name" : "a*bb*aa*",
%     "representation" : {
%       "K" : ["q0", "q1", "q2", "q3"],
%       "A" : ["a", "b"],
%       "s" : "q0",
%       "F" : ["q2"],
%       "t" : [["q0", "a", "q0"],
%              ["q0", "b", "q1"],
%              ["q1", "a", "q2"],
%              ["q1", "b", "q1"],
%              ["q2", "a", "q2"],
%              ["q2", "b", "q3"],
%              ["q3", "a", "q3"],
%              ["q3", "b", "q3"]]
%       }
%   },
%   {
%     "name" : "aa*bb*",
%     "representation" : {
%       "K" : ["q0", "q1", "q2"],
%       "A" : ["a", "b"],
%       "s" : "q0",
%       "F" : ["q2"],
%       "t" : [["q0", "a", "q1"],
%              ["q1", "a", "q1"],
%              ["q1", "b", "q2"],
%              ["q2", "b", "q2"]]
%       }
%   }
% ]
%
% Furthermore, json file can contain one automaton or more. That is the reason 
% why the input parameters are two: 
%   IN:
%       automatadatabasename : file's name without file's extension 
%                              (FOr example: if it's called "dfa.json", then 
%                               we'll introduce automatadatabasename as dfa)
%       automatonname : automaton's name. 
%
%   OUT:
%



% Dado un archivo json que sirve como base de datos de varios autómatas y el
% nombre de un autómata en json, devuelve un dfa nuevo sin estados inaccesibles. 
% Este parámetro de salida será pasado como un nuevo archivo .json, 
% almacenado fuera de la propia base de datos. No obstante, para comprobar que 
% funciona correctamente se intentará imprimir en pantalla. 
  
  addpath("../util/");
  
  automaton = loadrepresentation(automatadatabasename, automatonname);
  
  ## Take initial state as old and take initial state's successors and initial 
  ## initial state as new
  old = automaton.s;
  
  new = []
  for i = 1 :numel(automaton.t)
    if automaton.t{i}{1} == automaton.s
      new = [new;automaton.t{i}{3}];
    end 
  end 
  new = cellstr(new);
  old = cellstr(old); ## CONTINUAR CAMBIANDO LOS ARRAYS POR CELDAS Y PROBAR DE NUEVO
  new = myunion(old, new);
  
  
  ## Repeat the last proccess until new = old, looking at the those states' 
  ## successors that we haven't looked up yet. In that way, we would improve the 
  ## performance.
    while numel(old) != numel(new)
      auxEst = mysetdiff(new,old)
      old = new
      for i = 1:numel(auxEst)
        for j = 1:numel(automaton.t)
          if automaton.t{j}{1} == auxEst{i} 
            new = [new;automaton.t{i}{3}]
          end
        end 
      end 
      new = myunion(new,old)
    endwhile
  
  ## Obtain the new values of K, F and t 
  newK = new;
  newF = myintersect(automaton.F, new);
  newt = [];
  for i = 1:numel(automaton.t)
    tf = ismember(automaton.t{i},newK);
    if tf{1} == 1 & tf{3}==1
      newt = [newt;automaton.t{i}];
      
    end
  end 
  
  ## Copy new automaton using the previosly defined form in sol
  filename = cstrcat(automatonname, "withoutInaccStates")
  sol = { 
          "name" : filename  ,
          "representation" : {
            "K" : newK,
            "A" : automaton.A,
            "s" : automaton.s,
            "F" : newF,
            "t" : newt
            }
        };
  
  
  ## Save in a new json file
  savejson("",sol,filename);
  
  ## print new automaton, using the function defined in "finiteautomaton.m" 
  ## which has been copied in this script.
  
  automatonSol = loadrepresentation(filename, filename);
  
  printautomaton(automatonSol, string, false);
  
  
  
 
  
  function printautomaton(automaton, string, formatoptionLaTeX)
  ## print formatted automaton, e.g.
  ## M = ( {q0, q1, q2}, {a, b}, {(q0, a, q1), (q1, a, q1), (q1, b, q2), (q2, b, q2)}, q0, {q0, q1, q2} )

    ## format states
    K = "";
    for element = 1 : numel(automaton.K)
      if element > 1
        K = cstrcat(K, ", ");
      end
      K = cstrcat(K, formatstate(automaton.K{element}, formatoptionLaTeX));
    end

    ## format alphabet
    A = "";
    for element = 1 : numel(automaton.A)
      if element > 1
        A = cstrcat(A, ", ");
      end
      A = cstrcat(A, automaton.A{element});
    end
    
    s = automaton.s;

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
      consumed = transition{2};
      if isempty(consumed)
        consumed = emptystring;
      end
      t = cstrcat(t, "(", formatstate(transition{1}, formatoptionLaTeX), ", ", consumed, ", ", formatstate(transition{3}, formatoptionLaTeX), ")");
    end

    if formatoptionLaTeX
      printf("\n$M = (\\{%s\\}, \\{%s\\}, \\{%s\\}, %s, \\{%s\\})$\n", K, A, t, formatstate(s, formatoptionLaTeX), F);
      printf("\n$w = %s$\n\n", string);
    else
      printf("\nM = ({%s}, {%s}, {%s}, %s, {%s})\n", K, A, t, s, F);
      printf("\nw = %s\n\n", string);
    end
  
  end

  function aux = myunion(old, new)
    aux=old;
    for i = 1 : numel(new)
      if !ismember(new{i}, aux)
        aux = [aux;new{i}];
      end
    end
    
  end 
  
  function aux = myintersect(old, new)
    aux = [];
    for i = 1 : numel(new)
      if ismember(new{i}, old)
        aux = [aux;new{i}];
      end
    end
  end
  
  function aux = mysetminus(new, old)
    aux = [];
    for i = 1 : numel(new)
      if !ismember(new{i}, old)
        aux = [aux;new{i}];
      end
    end
  end
    
        
    
  
end
  