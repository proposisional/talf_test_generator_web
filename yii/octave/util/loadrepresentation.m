function representation = loadrepresentation(setdatabasename, setname)
## load the representation of a set (either a language or a function) from a JSON file
##
## Example of a finite automata database:
## [
##   {
##     "name" : "a*bb*aa*",
##     "representation" : {
##       "K" : ["q0", "q1", "q2", "q3"],
##       "A" : ["a", "b"],
##       "s" : "q0",
##       "F" : ["q2"],
##       "t" : [["q0", "a", "q0"],
##              ["q0", "b", "q1"],
##              ["q1", "a", "q2"],
##              ["q1", "b", "q1"],
##              ["q2", "a", "q2"],
##              ["q2", "b", "q3"],
##              ["q3", "a", "q3"],
##              ["q3", "b", "q3"]]
##       }
##   },
##   {
##     "name" : "aa*bb*",
##     "representation" : {
##       "K" : ["q0", "q1", "q2"],
##       "A" : ["a", "b"],
##       "s" : "q0",
##       "F" : ["q2"],
##       "t" : [["q0", "a", "q1"],
##              ["q1", "a", "q1"],
##              ["q1", "b", "q2"],
##              ["q2", "b", "q2"]]
##       }
##   }
## ]
##
## automaton = loadrepresentation(automatadatabasename, automatonname)
##

% ===============================================================
%
%   fjv, 02/01/2022   GNU GPL v3.0
%
% ===============================================================

  addpath("../util/jsonlab/");

  sets = loadjson(strcat(setdatabasename, ".json"), "FastArrayParser", 0);

  for idset = 1 : numel(sets)
    currentset = sets(idset);
    setfound = strcmp(currentset.name, setname);
    if setfound
      representation = currentset.representation;
      break
    end
  end
  
  if !setfound
    # return empty string and error message if not found
    fprintf(stderr, '\nWarning: "%s" is not in the "%s" database.\n', setname, setdatabasename);
    
    representation = '';
  end

end
