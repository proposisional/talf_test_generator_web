function jsonQ = whichRF()

    [rf, rfake1, rfake2] = randomRFs();
    evalrecfunction(rf, randi([0, 5]), randi([1, 7]))

    % Prepare choices
    n = randi([1, 3]);
    q1.choices = cell(1, 3);

    q1.choices{n} = ["\\(", "", "\\)"];
    rest = setdiff(1:3, n);
    q1.choices{rest(1)} = ["\\(", "", "\\)"];
    q1.choices{rest(2)} = ["\\(", "", "\\)"];
    q1.correct_choices = {n - 1};

    % Prepare and send question JSON
    q1.title = "";
    q1.image = "";
    q1.stem = [""];
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end

function rf = randomRF()
    rFunctions = {
            "constant^1_0",
            "constant^1_1",
            "constant^2_3",
            "addition",
            "predecessor",
            "subtraction",
            "product",
            "division",
            "power",
            "squareroot",
            "cuberoot"
            };
    rf = rFunctions{randi(numel(rFunctions))};
end

function [rf1, rf2, rf3] = randomRFs()
    rFunctions = {
            "constant^1_0",
            "constant^1_1",
            "constant^2_3",
            "addition",
            "predecessor",
            "subtraction",
            "product",
            "division",
            "power",
            "squareroot",
            "cuberoot"
            };
    [rf1, rf2, rf3] = randperm(numel(options), 3);
end
