function s = escapeLatex(str)
    s = strrep(str, '{', '\{');
    s = strrep(s, '}', '\}');
endfunction
