function out = turingmachineMatrixToString(matrix, format)

    if !exist('format', 'var') || isempty(format)
        format = 'array';
    end

    if isempty(matrix)
        out = '';
        return;
    end

    if !iscell(matrix)
        error('turingmachineMatrixToString: expected a cell array');
    end

    fmt = lower(format);

    switch fmt
        case {'array'}
            header = sprintf('\\begin{array}{l c c l}\n');
            footer = sprintf('\\end{array}');
        case {'tabular'}
            header = sprintf('\\begin{tabular}{l c c l}\n');
            footer = sprintf('\\end{tabular}');
        case {'bmatrix', 'pmatrix', 'vmatrix', 'bmatrix*', 'pmatrix*'}
            header = sprintf('\\begin{%s}\n', fmt);
            footer = sprintf('\\end{%s}', fmt);
        otherwise
            error('turingmachineMatrixToString: unsupported format "%s"', format);
    end

    lines = cell(1, numel(matrix));

    for idline = 1:numel(matrix)
        row = matrix{idline};

        if !iscell(row) || numel(row) != 4
            error('turingmachineMatrixToString: row %d must be a 1x4 cell', idline);
        end

        fromState = latexState(row{1});
        readSym = latexToken(row{2});
        action = latexToken(row{3});
        toState = latexState(row{4});

        lines{idline} = sprintf('%s & %s & %s & %s \\\\ ', fromState, readSym, action, toState);
    end

    out = cstrcat(header, strjoin(lines, "\n"), "\n", footer);

endfunction

function s = latexState(x)
    s0 = toString(x);
    s0 = latexEscapeBasic(s0);

    if numel(s0) >= 2 && s0(1) == 'q'
        digits = s0(2:end);

        if all(isstrprop(digits, 'digit'))
            s = sprintf('q_{%s}', digits);
            return;
        end

    end

    s = s0;
endfunction

function s = latexToken(x)
    s = latexEscapeBasic(toString(x));

    if strcmp(s, "\\")
        s = "\\backslash";
    end

endfunction

function s = toString(x)

    if ischar(x)
        s = x;
    elseif isstring(x)
        s = char(x);
    elseif isnumeric(x)
        s = num2str(x);
    else

        try
            s = char(x);
        catch
            error('turingmachineMatrixToString: value cannot be converted to string');
        end

    end

endfunction

function s = latexEscapeBasic(s)
    s = strrep(s, "\\", "\\textbackslash{}");
    s = strrep(s, "{", "\\{");
    s = strrep(s, "}", "\\}");
    s = strrep(s, "&", "\\&");
    s = strrep(s, "%", "\\%");
    s = strrep(s, "#", "\\#");
    s = strrep(s, "$", "\\$");
    s = strrep(s, "_", "\\_");
endfunction
