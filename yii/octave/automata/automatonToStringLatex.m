function str = automatonToStringLatex(dfa)
    K_sub = cellfun(@(s) strcat("q_{", s(2:end), "}"), dfa.K, 'UniformOutput', false);
    F_sub = cellfun(@(s) strcat("q_{", s(2:end), "}"), dfa.F, 'UniformOutput', false);
    s_sub = strcat("q_{", dfa.s(2:end), "}");

    states = strcat("\\{", strjoin(K_sub, ","), "\\}");
    finals = strcat("\\{", strjoin(F_sub, ","), "\\}");
    alphabet = strcat("\\{", strjoin(dfa.A, ","), "\\}");

    transStr = "";
    transList = cell(1, numel(dfa.t));

    for i = 1:numel(dfa.t)
        tr = dfa.t{i};
        from_sub = strcat("q_{", tr{1}(2:end), "}");
        to_sub = strcat("q_{", tr{3}(2:end), "}");
        transList{i} = strcat("\\delta(", from_sub, ",", tr{2}, ") = ", to_sub);
    end

    groupSize = 5;

    for i = 1:groupSize:length(transList)
        jEnd = min(i + groupSize - 1, length(transList));
        lineGroup = strjoin(transList(i:jEnd), ",   ");
        transStr = strcat(transStr, lineGroup, " \\\\ \n");
    end

    str = strcat(
    "\\begin{gather*}\n",
    "K = ", states, " \\\\ \n",
    "\\Sigma = ", alphabet, " \\\\ \n",
    "s = ", s_sub, " \\\\ \n",
    "F = ", finals, " \\\\ \n",
    "\\delta: & \\\\ \n",
    transStr,
    "\\end{gather*}\n"
    );
end
