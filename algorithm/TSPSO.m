classdef TSPSO < BasePSO & handle
%(extremum disturbed and simple particle swarm optimization)
    properties
        idvlStagnantSteps       %Individual stagnation steps: 1*number of particles
        soclStagnantSteps       %Global stagnation steps: 1*1

        idvlStagnantTh          %Individual stagnant steps threshold: 1*1
        soclStagnantTh          %Global stagnation step threshold: 1*1
    end

    %base function
    methods
        function obj = TSPSO(config)
            obj = obj@BasePSO(config);
            new_hyper_para_keys = ["idvlStagnantTh", "soclStagnantTh"];
            for i = 1:length(new_hyper_para_keys)
                obj.(new_hyper_para_keys(i)) = config.tspso.(new_hyper_para_keys(i));
            end


            obj.idvlStagnantSteps = zeros(1, obj.num_particles);
            obj.soclStagnantSteps = 0;
            obj.hyper_para_keys(end + 1 : end + 2) = new_hyper_para_keys;
        end
    end

    methods(Access = protected)
        %Update fitness related parameters
        function update_fit(obj)
            logidx = obj.idvlFitBest > obj.fitness;
            %Update individual stagnant step counts
            obj.idvlStagnantSteps(logidx) = zeros(1, sum(logidx));
            obj.idvlStagnantSteps(~logidx) = obj.idvlStagnantSteps(~logidx) + 1;

            obj.idvlFitBest(logidx) = obj.fitness(logidx);
            obj.idvlPstBest(:, logidx) = obj.pst(:, logidx);

            if obj.soclFitBest > min(obj.idvlFitBest)
                obj.soclStagnantSteps = obj.soclStagnantSteps + 1;
                idx = find(obj.idvlFitBest == min(obj.idvlFitBest));
                if length(idx) ~= 1
                    idx = idx(randperm(length(idx), 1));
                end
                obj.soclFitBest = obj.idvlFitBest(idx);
                obj.soclPstBest = obj.idvlPstBest(:, idx);
            else
                obj.soclStagnantSteps = 0;
            end
            obj.idvlFitBestAvgArray(end + 1) = mean(obj.idvlFitBest);
            obj.soclFitBestArray(end + 1) = obj.soclFitBest;
        end

        %Update particle parameters
        function update_particle(obj)
            w_ = repmat(obj.w, obj.num_dim, 1);
            soclpstbest = repmat(obj.soclPstBest, 1, obj.num_particles);

            %Use different random perturbation terms for all dimensions of each particle
            f_r = @()rand(obj.num_dim, obj.num_particles);
            r1 = f_r();
            r2 = f_r();
            r3 = f_r();
            r4 = f_r();

            logidx = obj.idvlStagnantSteps < obj.idvlStagnantTh;
            r3(logidx) = ones(1, sum(logidx));

            logidx = obj.soclStagnantSteps < obj.soclStagnantTh;
            r4(logidx) = ones(1, sum(logidx));

            obj.pst = obj.cttFactor * ( w_ .* obj.pst + obj.idvlLrnFactor * r1 .* ( r3 .* obj.idvlPstBest - obj.pst) ...
                + obj.soclLrnFactor * r2 .* ( r4 .* soclpstbest - obj.pst));

            p_lb = repmat(obj.var_range(:, 1), 1, obj.num_particles);
            p_ub = repmat(obj.var_range(:, 2), 1, obj.num_particles);
            logidx = obj.pst < p_lb;
            obj.pst(logidx) = p_lb(logidx);
            logidx = obj.pst > p_ub;
            obj.pst(logidx) = p_ub(logidx);
        end

        %Restrictions
        function checkRestrictions(~)
        end
    end
end