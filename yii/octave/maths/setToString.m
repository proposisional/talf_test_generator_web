function s = setToString(vec)

    if isempty(vec)
        s = '\emptyset';
    else
        elements = arrayfun(@(c) c, vec, 'UniformOutput', false);
        s = ['\{', strjoin(elements, ','), '\}'];
    end

end
