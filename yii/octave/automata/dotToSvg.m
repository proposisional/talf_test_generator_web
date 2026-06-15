function svgContent = dotToSvg(automata, outputName)

    scriptPath = fileparts(mfilename("fullpath"));
    imagesFolder = fullfile(scriptPath, "images");

    if ~exist(imagesFolder, "dir")
        mkdir(imagesFolder);
    end

    dotFile = fullfile(imagesFolder, [outputName ".dot"]);
    svgFile = fullfile(imagesFolder, [outputName ".svg"]);

    formatautomaton(automata, dotFile);

    dotExe = 'dot';

    if ispc()
        winPaths = {
                fullfile(scriptPath, '..', 'graphviz', 'bin', 'dot.exe')
                };

        for k = 1:numel(winPaths)
            [chkStatus, ~] = system([winPaths{k} ' -V']);

            if chkStatus == 0
                dotExe = winPaths{k};
                break;
            end

        end

    end

    cmd = [dotExe ' -Tsvg "' dotFile '" -o "' svgFile '"'];
    [status, result] = system(cmd);

    if status ~= 0
        error("Error generando SVG: %s", result);
    end

    fid = fopen(svgFile, 'r');
    svgContent = fread(fid, '*char')';
    fclose(fid);
end
