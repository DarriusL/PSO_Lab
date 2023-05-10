function value = lab_algorithm
    file_stc = dir(".\algorithm\*.m");
    value = cellfun(@(x)string(x(1:end -2 )), {file_stc.name});
    
end