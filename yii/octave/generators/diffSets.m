function jsonQ = diffSets()
    % Create question Sets
    set1 = createRandomSet(0);
    set2 = createRandomSet(0);

    % Create right and fake answers
    diffSets = setdiff(set1, set2);
    fakeSet1 = createRandomSet(0);
    fakeSet2 = createRandomSet(0);

    while isequal(diffSets, fakeSet1)
        fakeSet1 = createRandomSet(0);
    end

    while isequal(diffSets, fakeSet1) & isequal(fakeSet2, fakeSet1)
        fakeSet2 = createRandomSet(0);
    end

    % Prepare choices
    n = randi([1, 3]);
    q1.choices = cell(1, 3);

    q1.choices{n} = ["\\(", setToString(diffSets), "\\)"];
    rest = setdiff(1:3, n);
    q1.choices{rest(1)} = ["\\(", setToString(fakeSet1), "\\)"];
    q1.choices{rest(2)} = ["\\(", setToString(fakeSet2), "\\)"];
    q1.correct_choices = {n - 1};

    % Prepare and send question JSON
    q1.title = "Diferencia de conjuntos";
    q1.image = "";
    q1.stem = ["Dados \\(A = " setToString(set1) ", B = " setToString(set2) " \\), entonces \\(A - B\\) es igual a"];
    q1.subject = 1;
    jsonQ = jsonencode(q1);
    disp(jsonQ);
end
