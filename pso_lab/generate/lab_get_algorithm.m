function value = lab_get_algorithm(algorithm)
    algorithm_array = string(cellfun(@(x)x(1:end-2), {dir("./algorithm/*.m").name}, 'UniformOutput', false));
    value = eval("@" + algorithm_array(ismember(algorithm_array, algorithm)));
end