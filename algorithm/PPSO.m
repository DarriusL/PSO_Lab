
classdef PPSO < BasePSO & handle
%Perturbation PSO
    %base function
    methods
        function obj = PPSO(config)
            obj = obj@BasePSO(config);
        end

    end

    %Iterative correlation
    methods(Access = protected)
        %Update particle parameters
        function update_particle(obj)
            w_ = repmat(obj.w, obj.num_dim, 1);
            soclpstbest = repmat(obj.soclPstBest, 1, obj.num_particles);

            %Use different random perturbation terms for all dimensions of each particle
            r1 = rand(obj.num_dim, obj.num_particles);
            r2 = rand(obj.num_dim, obj.num_particles);
            r3 = 0.2 * rand(obj.num_dim, obj.num_particles);
            r4 = 0.2 * rand(obj.num_dim, obj.num_particles);

            obj.v = obj.cttFactor * ( w_ .* obj.v + obj.idvlLrnFactor * r1 .* ( 0.5 * r3 .* obj.idvlPstBest - obj.pst) ...
                + obj.soclLrnFactor * r2 .* ( 0.5 * r4 .* soclpstbest - obj.pst));
            
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

        %Restrictions
        function checkRestrictions(~)
        end
    end
end