%单次优化
function stc = lab_mode_optimize(subcfg, mode)

    assert(ismember(subcfg.algorithm, lab_algorithm()));
    
    AlgorithmClass = lab_get_algorithm(subcfg.algorithm);
    optimizer = AlgorithmClass(subcfg);
    
    assert(mode == "optimize");
    stc =  optimizer.search(subcfg.disp_stc, 1);
end
