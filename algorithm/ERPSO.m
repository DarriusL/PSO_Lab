classdef ERPSO < PPSO & handle
% Experience Replay PSO (Experience Replay PSO)
% The amount of added experience is proportional to the tolerance, 
%   the higher the tolerance, the higher the amount of experience added each time
% The number of samples is inversely proportional to the tolerance, 
%   the higher the tolerance, the less experience each sampling, at least 1


    properties
        memory                      %empirical memory sum tree
        expReplay                   %experience replay memory
        expIdx                      %memory index

        memory_size                 %Experience size
        expLrnFactor                %experiential learning factor

        exp_tolerance               %Enable tolerance for experience playback
    end

    %base function
    methods
        function obj = ERPSO(config)
            obj = obj@PPSO(config);
            new_hyper_para_keys = ["memory_size", "expLrnFactor", "exp_tolerance"];
            for i = 1:length(new_hyper_para_keys)
                obj.(new_hyper_para_keys(i)) = config.erpso.(new_hyper_para_keys(i));
            end
            obj.memory_size = min([obj.memory_size, 0.001 * obj.num_particles * obj.num_dim * obj.num_Iter]);
            [obj.memory, obj.memory_size] = SumTree(obj.memory_size);
            obj.expReplay = nan(obj.num_dim, obj.memory_size);
            obj.expIdx = 1;
            obj.hyper_para_keys(end + 1 : end + 3) = new_hyper_para_keys;
        end

        %iterative optimization
        function stc = search(obj, disp_stc, tnum)
            disp_stc.start(obj.num_Iter, obj.num_particles, obj.num_dim, [obj.var_range(1, 1), obj.var_range(1, 2)], tnum);
            obj.reset();
            for i = 1:obj.num_Iter
                obj.update_adappara();
                obj.update_particle(i);
                obj.checkRestrictions();
                obj.cal_fitness();
                obj.update_fit();
                obj.add_experience();
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
        %Update particle parameters
        function update_particle(obj, iter)
            w_ = repmat(obj.w, obj.num_dim, 1);
            soclpstbest = repmat(obj.soclPstBest, 1, obj.num_particles);

            
            if  iter > 2 
                %Sampling (the lower the tolerance, the larger the number of samples)
                tolerance = abs(obj.soclFitBestArray(end) - obj.soclFitBestArray(end - 1));
                if tolerance < obj.exp_tolerance
                    obj.memory.update_tree();
                    num = max([ceil(0.1 * obj.memory_size * (1 - 1/(1 + exp(-tolerance).^(0.001)))), 1]);
                    mmy = repmat( mean(obj.expReplay (:, obj.memory.sample(num).DataMemory), 2), 1, obj.num_particles);
                else
                    mmy = obj.pst;
                end
            else
                mmy = obj.pst;
            end


            %Use different random perturbation terms for all dimensions of each particle
            rand_ = @(x)rand(obj.num_dim, obj.num_particles);
            r1 = rand_(0);
            r2 = rand_(0);
            r3 = 0.2 * rand_(0);
            r4 = 0.2 * rand_(0);
            r5 = 0.5 * rand_(0);

            obj.v = obj.cttFactor * ( w_ .* obj.v + obj.idvlLrnFactor * r1 .* ( 0.5 * r3 .* obj.idvlPstBest - obj.pst) ...
                + obj.soclLrnFactor * r2 .* ( 0.5 * r4 .* soclpstbest - obj.pst)) + obj.expLrnFactor * r5 .* (mmy - obj.pst);
            
            %Speed adjustment is necessary, and it is particularly important to search in a small range of large bases
            v_lb = repmat(obj.v_range(:, 1), 1, obj.num_particles);
            v_ub = repmat(obj.v_range(:, 2), 1, obj.num_particles);
            logidx = obj.v < v_lb;
            obj.v(logidx) = v_lb(logidx);
            logidx = obj.v > v_ub;
            obj.v(logidx) = v_ub(logidx);

            obj.pst = obj.pst + obj.v;
            p_lb = repmat(obj.var_range(:, 1), 1, obj.num_particles);
            p_ub = repmat(obj.var_range(:, 2), 1, obj.num_particles);
            logidx = obj.pst < p_lb;
            obj.pst(logidx) = p_lb(logidx);
            logidx = obj.pst > p_ub;
            obj.pst(logidx) = p_ub(logidx);
        end

        function add_experience(obj)
            %Add the current global optimum
            obj.memory.add_mtpnode(obj.soclFitBest, obj.expIdx);
            obj.expReplay(:, obj.expIdx) = obj.soclPstBest;
            obj.expIdx = obj.expIdx + 1;
            if obj.expIdx > obj.memory_size
                obj.expIdx = obj.expIdx - obj.memory_size;
            end

            %add experience
            tolerance = abs(obj.soclFitBestArray(end) - obj.soclFitBestArray(end - 1));
            num = ceil(0.01 * obj.memory_size * (1/(1 + exp(-tolerance).^(0.001))));
            
            parray =randperm(obj.num_particles, num);
            idxarray = obj.expIdx :obj.expIdx + num - 1;
            obj.memory.add_mtpnode(obj.idvlFitBest(parray), idxarray, false);
            obj.expReplay(:, idxarray) = obj.idvlPstBest(:, parray);

            obj.expIdx = obj.expIdx + num;
            if obj.expIdx > obj.memory_size
                obj.expIdx = obj.expIdx - obj.memory_size;
            end

            %Add random experience
            num = ceil(0.25 * num);
            idxarray = obj.expIdx :obj.expIdx + num - 1;
            lb = repmat(obj.var_range(:, 1), 1, num);
            ub = repmat(obj.var_range(:, 2), 1, num);
            %generate random particles
            p =  lb + (ub - lb) .* rand(obj.num_dim, num);
            %Calculate its fitness
            p_fitness = cellfun(obj.fit_fun, num2cell(p, 1));
            obj.memory.add_mtpnode(p_fitness, idxarray, false);
            obj.expReplay(:, idxarray) = p;

            obj.expIdx = obj.expIdx + num;
            if obj.expIdx > obj.memory_size
                obj.expIdx = obj.expIdx - obj.memory_size;
            end
        end

        %Calculate its fitness
        function checkRestrictions(~)
        end
    end
end