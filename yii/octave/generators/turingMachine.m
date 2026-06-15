function jsonQ = turingMachine(numberstates, alphabet)

    if nargin < 1 || isempty(numberstates)
        numberstates = 2;
    end

    if nargin < 2 || isempty(alphabet)
        alphabet = "|";
    end

    if !isscalar(numberstates) ||!isnumeric(numberstates) || numberstates < 1 || floor(numberstates) != numberstates
        error('turingMachine: el numero de estados debe ser mayor a 1');
    end

    if isstring(alphabet)
        alphabet = char(alphabet);
    end

    if !ischar(alphabet)
        error('turingMachine: el alfabeto debe ser una cadena de caracteres');
    end

    tM = ["$$", turingmachineMatrixToString(randomturingmachine(numberstates, alphabet)), "$$"];

    % Prepare and send question JSON
    q1.title = "Máquina de Turing";
    q1.image = tM;
    q1.stem = "";
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end
