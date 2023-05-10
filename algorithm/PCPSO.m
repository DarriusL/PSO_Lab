classdef PCPSO < PPSO & handle
%Perturbation-based Cauchy-variation PSO

    properties
       variation_tolerance      %Enable fitness tolerance for Cauchy mutation
    end

    %base function
    methods
        function obj = PCPSO(config) 
            obj = obj@PPSO(config);
            new_hyper_para_keys = "variation_tolerance";
            obj.(new_hyper_para_keys) = config.pcpso.(new_hyper_para_keys);
            obj.hyper_para_keys(end + 1) = new_hyper_para_keys;
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
                if abs(obj.soclFitBestArray(end) - obj.soclFitBestArray(end - 1)) < obj.variation_tolerance
                    obj.variation(i);
                end
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
        function variation(obj, num_iter)
            rho = 20;
            avg_idvlpstbest = mean(obj.idvlPstBest, 2);
            r = obj.soclPstBest - avg_idvlpstbest;
            xm = exp(- rho * num_iter/obj.num_Iter) * (1 - r  ./ (obj.var_range(:, 2) - obj.var_range(:, 1)));
            z = mean(obj.v, 2);
            obj.soclPstBest = obj.soclPstBest + z .* (0.5 + 1/pi * atan(xm));

            %Adjust the range after mutation
            p_lb = obj.var_range(:, 1);
            p_ub = obj.var_range(:, 2);
            logidx = obj.soclPstBest < p_lb;
            obj.soclPstBest(logidx) = p_lb(logidx);
            logidx = obj.soclPstBest > p_ub;
            obj.soclPstBest(logidx) = p_ub(logidx);

            obj.checkRestrictions();
        end

        %Restrictions
        function checkRestrictions(~)
        end
    end
end