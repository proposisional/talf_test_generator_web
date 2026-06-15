function qterminal()
    global q;
    q = struct();

    printf("=== TALF Question Builder Terminal ===\n");
    printf("Comandos: qtitle, qstem, qchoice, qimage, qshow, qsave, quit\n\n");

    while true
        cmd = input("qterm> ", "s");

        if strncmp(cmd, "qtitle", 6)
            qtitle(stripCommand(cmd, "qtitle"));

        elseif strncmp(cmd, "qstem", 5)
            qstem(stripCommand(cmd, "qstem"));

        elseif strncmp(cmd, "qchoice", 7)
            [text, correct] = parseChoice(cmd);
            qchoice(text, correct);

        elseif strncmp(cmd, "qimage", 6)
            qimage(stripCommand(cmd, "qimage"));

        elseif strncmp(cmd, "qshow", 5)
            disp(q);

        elseif strncmp(cmd, "qsave", 5)
            filename = stripCommand(cmd, "qsave");

            if isempty(filename)
                filename = "question.json";
            end

            qsave(filename);

        elseif strncmp(cmd, "quit", 4)
            printf("Saliendo...\n");
            break;

        else
            printf("Comando no reconocido: %s\n", cmd);
        end

    endwhile

end

% Helpers -----------------------------------------

function out = stripCommand(cmd, prefix)
    out = strtrim(strrep(cmd, prefix, ""));

    if startsWith(out, '"') && endsWith(out, '"')
        out = out(2:end - 1);
    end

end

function [text, correct] = parseChoice(cmd)
    % formato esperado: qchoice "texto" true/false
    parts = strsplit(cmd, " ");
    text = strjoin(parts(2:end - 1), " ");
    text = strrep(text, '"', ""); % quitar comillas

    if numel(parts) > 1
        correct = strcmpi(parts{end}, "true");
    else
        correct = false;
    end

end

global q;

function qtitle(str)
    global q;
    q.title = str;
end

function qstem(str)
    global q;
    q.stem = str;
end

function qchoice(str, isCorrect = false)
    global q;

    if ~isfield(q, "choices")
        q.choices = {};
        q.correct_choices = [];
    end

    q.choices{end + 1} = str;

    if isCorrect
        q.correct_choices(end + 1) = numel(q.choices);
    end

end

function qimage(path)
    global q;
    q.image = path;
end

function qsave(filename)
    global q;
    fid = fopen(filename, "w");
    fwrite(fid, jsonencode(q));
    fclose(fid);
    printf("Pregunta guardada en %s\n", filename);
end
