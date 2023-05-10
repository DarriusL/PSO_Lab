function data = lab_mode_par_optimize(subcfg, mode)
    AlgorithmClass = lab_get_algorithm(subcfg.algorithm);
    optimizer = AlgorithmClass(subcfg);
    data = cell(lab_config().task_num, 1);
    assert(mode == "par-optimize");
    parfor i = 1:lab_config().task_num
        data{i} = optloop(optimizer, subcfg, i);
        disp([newline, 'Misson', num2str(i) ,' complete.']);
    end
end

function stc = optloop(optimizer, subcfg, i)
    stc = optimizer.search(subcfg.disp_stc, i);
end