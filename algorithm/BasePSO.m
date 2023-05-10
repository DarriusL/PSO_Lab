classdef BasePSO < handle
%basic particle swarm
    %Hyperparameter
    properties
        %-----iteration parameters-----
        num_particles               %Number of particles
        num_dim                     %Number of Dimensions/Number of Variables
        idvlLrnFactor               %individual learning factor
        soclLrnFactor               %social learning factor
        w_range                     %Inertia weight range (lower bound, upper bound): 2*1
        v_range                     %Speed range (lower bound, upper bound): dimension*2
        var_range                   %Variable range (lower bound, upper bound): dimension*2
        num_Iter                    %The maximum number of iterations
        evalu_enable                %enable evaluation
        evalu_times                 %Iterations per evaluation

        %-----Exit conditions-----
        exit_enable                 %Allow conditional exit
        fit_tolerance
        max_tolerance_times

        fit_fun                     %fitness function

        hyper_para_keys              %name of Hyperparameter
    end

    %Internal parameters
    properties
        %-----particle properties------
        pst                         %particle position: dimension * number of particles
        v                           %Particle velocity: dimension * number of particles
        w                           %Inertia weight of each particle: 1*Number of particles
        fitness                     %Fitness: 1*Number of particles

        %-----Iterative process record-----
        idvlPstBest                 %Best particle history: dimension * number of particles
        idvlFitBest                 %The best fitness of particle history: 1*number of particles
        soclPstBest                 %Best Collective History: Dimension*1
        soclFitBest                 %Collective historical: best fitness 1*1

        idvlFitBestAvgArray         %Record the average best fitness of particles
        soclFitBestArray            %Record the global optimal fitness

         %-----iteration parameters-----
        cttFactor                   %contraction factor
    end

    %base function
    methods
        function obj = BasePSO(config)
            assert(obj.test_fitfun(config.fit_fun));
            obj.hyper_para_keys = ["num_particles", "num_dim", "idvlLrnFactor", "soclLrnFactor", "w_range", "v_range", ...
                "var_range", "num_Iter", "evalu_times", "fit_tolerance", "max_tolerance_times", "fit_fun"];
            obj.init(config);
        end

        function init(obj,  config)
            for i = 1:length(obj.hyper_para_keys)
                obj.(obj.hyper_para_keys(i)) = config.(obj.hyper_para_keys(i));
            end

            if ~isempty(obj.evalu_times)
                obj.evalu_enable = true;
            else
                obj.evalu_enable = false;
            end

            if ~isempty(obj.fit_tolerance) && ~isempty(obj.max_tolerance_times)
                obj.exit_enable = true;
            else
                obj.exit_enable = false;
            end

            C = obj.idvlLrnFactor + obj.soclLrnFactor;
            obj.cttFactor = 2/abs(2 - C - sqrt(C^2 - 4 * C));

            obj.pst = zeros(obj.num_dim, obj.num_particles);
            obj.v = zeros(obj.num_dim, obj.num_particles);
            obj.fitness = zeros(1, obj.num_particles);
            obj.w = zeros(1, obj.num_particles);

            obj.idvlPstBest = zeros(obj.num_dim, obj.num_particles);
            obj.idvlFitBest = inf * ones(1, obj.num_particles);
            obj.soclPstBest = zeros(obj.num_dim, 1);
            obj.soclFitBest = inf;

            obj.idvlFitBestAvgArray = double.empty;
            obj.soclFitBestArray = double.empty;
        end

        %Test the fitness function
        function result = test_fitfun(~, fitfun)
            data = num2cell(reshape(randperm(3595, 110), 11, 10), 1);
            result = true;
            try
                cellfun(fitfun, data);
            catch
                warning("The input custom fitness function does not meet the requirements " + ...
                    "and needs to have the ability to process vectors");
                result = false;
            end
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
    
    %Iterative correlation function
    methods(Access = protected)
        %Calculate fitness
        function cal_fitness(obj)
            obj.fitness = cellfun(obj.fit_fun, num2cell(obj.pst, 1));
        end

        %Update fitness related parameters
        function update_fit(obj)
            logidx = obj.idvlFitBest > obj.fitness;
            obj.idvlFitBest(logidx) = obj.fitness(logidx);
            obj.idvlPstBest(:, logidx) = obj.pst(:, logidx);

            if obj.soclFitBest > min(obj.idvlFitBest)
                idx = find(obj.idvlFitBest == min(obj.idvlFitBest));
                if length(idx) ~= 1
                    idx = idx(randperm(length(idx), 1));
                end
                obj.soclFitBest = obj.idvlFitBest(idx);
                obj.soclPstBest = obj.idvlPstBest(:, idx);
            end
            obj.idvlFitBestAvgArray(end + 1) = mean(obj.idvlFitBest);
            obj.soclFitBestArray(end + 1) = obj.soclFitBest;
        end

        %Update particle parameters
        function update_particle(obj)
            w_ = repmat(obj.w, obj.num_dim, 1);
            soclpstbest = repmat(obj.soclPstBest, 1, obj.num_particles);

            %Use different random perturbation terms for all dimensions of each particle
            r1 = rand(obj.num_dim, obj.num_particles);
            r2 = rand(obj.num_dim, obj.num_particles);

            obj.v = obj.cttFactor * ( w_ .* obj.v + obj.idvlLrnFactor * r1 .* ( obj.idvlPstBest - obj.pst) ...
                + obj.soclLrnFactor * r2 .* ( soclpstbest - obj.pst));
            
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
        
        %Update adaptive parameters
        function update_adappara(obj)
            %Update inertia weights
            fitness_avg = mean(obj.fitness);
            fitness_min = min(obj.fitness);
            logidx1 = obj.fitness <= fitness_avg;
            logidx2 = ~logidx1;
            obj.w(logidx1) = obj.w_range(1) + (obj.w_range(2) - obj.w_range(1)) ...
            * (obj.fitness(logidx1) - fitness_min) / (fitness_avg - fitness_min);
            obj.w(logidx2) = obj.w_range(2);
        end

        %reset
        function reset(obj)
            %This needs to be commented out when inheriting
            obj.idvlPstBest = zeros(obj.num_dim, obj.num_particles);
            obj.idvlFitBest = inf * ones(1, obj.num_particles);
            obj.soclPstBest = zeros(obj.num_dim, 1);
            obj.soclFitBest = inf;
            obj.idvlFitBestAvgArray = double.empty;
            obj.soclFitBestArray = double.empty;

            rng(randperm(3595, 1));
            lb = repmat(obj.var_range(:, 1), 1, obj.num_particles);
            ub = repmat(obj.var_range(:, 2), 1, obj.num_particles);
            obj.pst =  lb + (ub - lb) .* rand(obj.num_dim, obj.num_particles);

            lb = repmat(obj.v_range(:, 1), 1, obj.num_particles);
            ub = repmat(obj.v_range(:, 2), 1, obj.num_particles);
            obj.v = lb + (ub - lb) .* rand(obj.num_dim, obj.num_particles);
            obj.cal_fitness();
            obj.update_fit();
        end

        %Restrictions
        function checkRestrictions(~)
        end

        %Check exit conditions
        function result = check_exit(obj)
            result = false;
            if ~obj.exit_enable
                return;
            end
            persistent count
            if isempty(count)
                count = 0;
            end
            if abs(obj.soclFitBestArray(end) - obj.soclFitBestArray(end - 1)) < obj.fit_tolerance
                count = count + 1;
            else 
                count = 0;
            end
            if count >= obj.max_tolerance_times
                result = true;
                count = 0;
            end
        end

        %Packed data
        function stc = data_backup(obj)
            stc.idvlFitBestAvgArray = obj.idvlFitBestAvgArray;
            stc.soclFitBestArray = obj.soclFitBestArray;
            stc.soclPstBest = obj.soclPstBest;
            stc.soclFitBest = obj.soclFitBest;
        end
    end

end