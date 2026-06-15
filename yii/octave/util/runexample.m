#!/usr/bin/octave -qf

# Runs the commands for a given example in ´lecturenotes/examples.json´
#
# example:
#   $ runexample.m 'power_relation'


talfdirectory          = "opt/talfuma/";
softwaredirectory      = "software/";
lecturesnotesdirectory = "lecturenotes/";
examplesfilename       = "examples";

warning("off");

softwarefulldirectory      = strcat(get_home_directory, "/", talfdirectory, softwaredirectory);
lecturesnotesfulldirectory = strcat(get_home_directory, "/", talfdirectory, lecturesnotesdirectory);

# include all the directories with Octave scripts
addpath(genpath(softwarefulldirectory), "-end");


# get the command to be executed
arguments = argv;
commandlabel = arguments{1};

# read command from list
commandslist = loadjson(strcat(lecturesnotesfulldirectory, examplesfilename, ".json"));

commandfound = false;
for idcommand = 1 : numel(commandslist)
  currentcommand = commandslist(idcommand);
  commandfound = strcmp(currentcommand.name, commandlabel);
  if commandfound
    commands = currentcommand.commands;
    if isfield(currentcommand, "results")
      results = currentcommand.results;
    end
    break
  end
end

if !commandfound
  printf('\nWarning: "%s" is not in the examples database.\n', commandlabel);
  return;
end

removemark = '<RM>';
for idcommand = 1 : numel(commands)
  command = commands{idcommand};

  % remove arguments preceeded by a mark so they do not display
  arguments       = regexp(command, '((,|\()\s*|\);)');
  argumentshidden = regexp(command, ['(,|\()\s*' removemark]);

  prettycommand   = command(1 : arguments(1) - 1);
  for idargument = 1 : numel(arguments) - 1
    if !ismember(arguments(idargument), argumentshidden)
      ## include this argument
      prettycommand = strcat(prettycommand, command(arguments(idargument) : arguments(idargument + 1) - 1));
    end
  end
  prettycommand = strcat(prettycommand, command(arguments(end) : end));

  % remove marks from original command
  command = strrep(command, removemark, '');

  # simulate COMMAND EXECUTION in Octave environment
  printf("octave> %s\n", prettycommand);
  eval(command);
  
  # character U+2001 (Em Quad) allows an empty line between examples
  if idcommand != numel(commands)
    printf("%s\n", native2unicode([226  128  129]));
  end

end

