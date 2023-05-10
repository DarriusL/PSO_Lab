function  [subcfg_cell, rcd] = lab_distribute(config, mode)
    if mode == "optimize"
        assert(length(config.algorithm) == 1);
        %Cannot have range search (as the algorithm increases, it needs to be changed, currently it is 3)
        sum(cellfun(@search_check, struct2cell(config)));
        assert(sum(cellfun(@search_check, struct2cell(config))) == 3);
        switch config.algorithm
            case "PCPSO"
                assert(config.pcpso.enable);
                assert(length(config.pcpso.tolerance) == 1);
            case "TSPSO"
                assert(config.tspso.enable);
                assert(length(config.tspso.idvlStagnantTh) == 1 && ...
                    length(config.tspso.soclStagnantTh) == 1);
            case "ERPSO"
                assert(config.erpso.enable);
                assert(length(config.erpso.expLrnFactor) == 1 && ...
                    length(config.erpso.exp_tolerance) == 1 && length(config.erpso.memory_size) == 1);
            case "CPSO"
                assert(config.cpso.enable);
                assert(length(config.cpso.chaos_mu) == 1 && ...
                    length(config.cpso.chaos_length) == 1); 
        end
        stccell = get_disp_stc_cell(config.algorithm);
        subcfg_cell = cell(1, 1);
        subcfg_cell{1} = config;
        subcfg_cell{1}.disp_stc = stccell{1};
        rcd = config.algorithm;

    elseif mode == "search"
        %There can only be one range search (which needs to be changed as the algorithm increases, currently it is 4)
        sum(cellfun(@search_check, struct2cell(config)));
        assert(sum(cellfun(@search_check, struct2cell(config))) == 4);
        for i = 1:length(config.algorithm)
            assert(config.(lower(config.algorithm(i))).("enable"));
        end
        
        %reassign
        if length(config.algorithm) > 1
            mnum = length(config.algorithm);
            cfg_field = "algorithm";
        elseif length(config.idvlLrnFactor) > 1
            mnum = length(config.idvlLrnFactor);
            cfg_field = "idvlLrnFactor";
        elseif length(config.soclLrnFactor) > 1
            mnum = length(config.soclLrnFactor);
            cfg_field = "soclLrnFactor";
        elseif length(config.pcpso.tolerance) > 1
            mnum = length(config.pcpso.tolerance);
            cfg_field = ["pcpso", "tolerance"];
        elseif length(config.tspso.idvlStagnantTh) > 1
            mnum = length(config.tspso.idvlStagnantTh);
            cfg_field = ["tspso", "idvlStagnantTh"];
        elseif length(config.tspso.soclStagnantTh) > 1
            mnum = length(config.tspso.soclStagnantTh);
            cfg_field = ["tspso", "soclStagnantTh"];
        elseif length(config.cpso.chaos_mu) > 1
            mnum = length(config.cpso.chaos_mu);
            cfg_field = ["cpso", "chaos_mu"];
        elseif length(config.cpso.chaos_length) > 1
            mnum = length(config.cpso.chaos_length);
            cfg_field = ["cpso", "chaos_length"];
        end

        if length(config.algorithm) > 1
            stccell = get_disp_stc_cell(config.algorithm);
        else
            stccell = get_disp_stc_cell(repmat(config.algorithm, 1, mnum));
        end
        
        subcfg_cell = cell(mnum, 1);
        rcd = repmat(" ", mnum, 1);
        for i = 1:mnum
            subcfg_cell{i} = config;
            if length(cfg_field) == 1
                subcfg_cell{i}.(cfg_field) = config.(cfg_field)(i);
                rcd(i) = cfg_field(end) + " = " + string(num2str(config.(cfg_field)(i)));
                subcfg_cell{i}.disp_stc = stccell{i};
            elseif length(cfg_field) == 2
                subcfg_cell{i}.(cfg_field(1)).(cfg_field(2)) = config.(cfg_field(1)).(cfg_field(2))(i);
                rcd(i) = cfg_field(end) + " = " + string(num2str(config.(cfg_field(1)).(cfg_field(2))(i)));
                subcfg_cell{i}.disp_stc = stccell{i};
            end
        end
    elseif mode == "par-optimize"
        %Cannot have range search (as the algorithm increases, it needs to be changed, currently it is 4)
        sum(cellfun(@search_check, struct2cell(config)));
        assert(sum(cellfun(@search_check, struct2cell(config))) == 4);
        subcfg_cell = {config};
        disp_stc = get_disp_stc_cell(config.algorithm);
        subcfg_cell{1}.disp_stc = disp_stc{1};
        rcd = repmat(" ", lab_config().task_num, 1);
        for i = 1:lab_config().task_num
            rcd(i) = config.algorithm + " task." + string(i);
        end
    end
    disp_subcfg_cell(subcfg_cell);
    
end

%% 
%create disp_stc
function stccell = get_disp_stc_cell(algorithm)
    num = length(algorithm);
    stccell = cell(num, 1);

    for i = 1:num
        disp_stc.start = @(num_iter, num_particle, num_dim, var_r, tnum)...
            disp([newline, '[', char(datetime), '] m', num2str(i), 't', num2str(tnum), newline, ...
            char(algorithm(i)), newline,  ...
            'Set iterations: ', num2str(num_iter), newline, ...
            'Number of particles: ', num2str(num_particle), newline, ...
            'Dimension: ', num2str(num_dim), newline, ...
            'Variable scope: [', num2str(var_r(1)), ',', num2str(var_r(2)), '] ', newline, ...
            'Iteration starts...', newline]);
        disp_stc.evaluate = @(Iter_num, soclFitBest, tnum)disp([newline, '[', char(datetime), '] m', num2str(i), 't', num2str(tnum), newline, ...
            char(algorithm(i)), newline, ...
            'Iter_num：', num2str(Iter_num), newline, ...
            'best_fitness：', num2str(soclFitBest), newline]);
        disp_stc.end = @(iter_real, Iter_num, num_particle, num_dim, var_r, soclFitBest, tnum)...
            disp([newline, '[', char(datetime), '] Summary m', num2str(i), 't', num2str(tnum), newline, ...
            '----------------------------------------', newline, ...
            'Actual iterations/Set iterations: ', num2str(iter_real), '/', num2str(Iter_num), newline, ...
            'Number of particles: ', num2str(num_particle), newline, ...
            'Dimension: ', num2str(num_dim), newline, ...
            'Variable scope: [', num2str(var_r(1, 1)), ',', num2str(var_r(1, 2)) ']', newline, ...
            '------------------------------------------', newline, ...
            'Optimal fitness: ', num2str(soclFitBest), newline]);

        stccell{i} = disp_stc;
    end
end

%search pattern check
function value = search_check(cell_ele)
    if isa(cell_ele, 'struct')
        value = sum(cellfun(@search_check, struct2cell(cell_ele)));
        assert(length(value) == 1);
        return;
    end
    if length(cell_ele) > 1
        value = 1;
    else
        value = 0;
    end
end

%disp subcfg_cell
function disp_subcfg_cell(subcfg_cell)
    num = length(subcfg_cell);
    for i = 1:num
        subcfg = subcfg_cell{i};
        disp([newline, '{ mission ', num2str(i) ,' } ' , newline, ...
            'save: ', num2str(subcfg.save), newline, ...
            'fit_fun: ', char(subcfg.fit_fun), newline, ...
            'algorithm: ', char(subcfg.algorithm), newline, ...
            'dim: ', num2str(subcfg.num_dim), newline, ...
            'number of particles:', num2str(subcfg.num_particles), newline, ...
            'MaxIterNum: ', num2str(subcfg.num_Iter), newline, ...
            'idvlLrnFactor: ', num2str(subcfg.idvlLrnFactor), newline, ...
            'soclLrnFactor: ', num2str(subcfg.soclLrnFactor), newline, ...
            'w_range: [', num2str(subcfg.w_range(1)), ',', num2str(subcfg.w_range(2)) ,']', newline, ...
            'var_range: [', num2str(subcfg.var_range(1, 1)), ',', num2str(subcfg.var_range(1, 2)) ,']', newline, ...
            'evaluate times: ', num2str(subcfg.evalu_times), newline, ...
            'fit_tolerance: ', num2str(subcfg.fit_tolerance), newline, ...
            'max_tolerance_times:', num2str(subcfg.max_tolerance_times), newline]);
    end
end