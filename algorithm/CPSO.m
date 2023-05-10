classdef CPSO < BasePSO & handle

    properties
        chaos_mu            %Chaos Iterative Control Parameters
        chaos_length        %Chaos sequence length
    end

    %base function
    methods
        function obj = CPSO(config)
            obj = obj@BasePSO(config);
            new_hyper_para_keys = ["chaos_mu", "chaos_length"];
            for i = 1:length(new_hyper_para_keys)
                obj.(new_hyper_para_keys(i)) = config.cpso.(new_hyper_para_keys(i));
            end
            obj.hyper_para_keys(end + 1 : end +2) = new_hyper_para_keys;
        end

        %iterative optimization
        function stc = search(obj, disp_stc, tnum)
            disp_stc.start(obj.num_Iter, obj.num_particles, obj.num_dim, [obj.var_range(1, 1), obj.var_range(1, 2)], tnum);
            obj.reset();
            for i = 1:obj.num_Iter
                obj.update_adappara();
                obj.update_particle();
                obj.checkRestrictions();
                obj.cal_fitness();
                obj.update_fit();
                obj.chaos_optimize();
                if mod(i, obj.evalu_times) == 0 && obj.evalu_enable
                    disp_stc.evaluate(i, obj.soclFitBest, tnum);
                end
                if obj.check_exit()
                    break;
                end
            end
            disp_stc.end(i, obj.num_Iter, obj.num_particles, obj.num_dim, [obj.var_range(1, 1), obj.var_range(1, 2)], ...
                obj.soclFitBest, tnum);
            stc = obj.data_backup();
            stc.Iter_num = i;
        end
    end

    %Iterative correlation
    methods(Access = protected)
        function chaos_optimize(obj)
            z = zeros(obj.num_dim, obj.chaos_length);
            z(:, 1) = (obj.soclPstBest - obj.var_range(:, 1)) ./ (obj.var_range(:, 2) - obj.var_range(:, 1));
            for i = 2:obj.chaos_length
                z(:, i) = obj.chaos_mu * z(:, i - 1) .* (1 - z(:, i - 1));
            end
            pst = repmat(obj.var_range(:, 1), 1, obj.chaos_length) + repmat(obj.var_range(:, 2) - obj.var_range(:, 1), 1, obj.chaos_length) .* z;
            fitness = cellfun(obj.fit_fun, num2cell(pst, 1));
            pst_best = pst(:, fitness == min(fitness));
            idx = randperm(obj.num_particles, 1);
            obj.pst(:, idx) = pst_best(:, end);
        end
    end
end