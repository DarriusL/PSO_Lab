%configuration file（BasePSO, primary，Multimodal test function 3, search）
function stc = basepso_primary_multimodal_3_idvlLrnFactor_benchmark_config
    testfun_stc = math_util().test_function("primary");

    stc = lab_para_stc;

    %Save Data
    stc.save = true;

    %Parallel processing
    stc.para_enable = true;
    stc.para_num = 4;
    
    %Fitness function
    stc.fit_fun = testfun_stc.multimodal().fun3.function;

    %Algorithm used
    stc.algorithm = "BasePSO";

    %size
    stc.num_dim = testfun_stc.varset.dim;
    stc.num_particles = 1000;

    %Maximum Iterations
    stc.num_Iter = 1000;

    %Individual Learning Factors and Social Learning Factors
    stc.idvlLrnFactor = 0:0.2:2.2;
    stc.soclLrnFactor = 2.05;

    %Inertia weight range [lower bound, upper bound] (default 0.4~0.9)
    stc.w_range = [0.4; 0.9];

    %Variable range [lower bound, upper bound;...] (dimension * 2)
    stc.var_range = testfun_stc.varset.var_range;

    %Speed range [lower bound, upper bound;...] (dimension * 2)
    d_var = abs(stc.var_range(:, 1) - stc.var_range(:, 2));
    stc.v_range = 0.05 * [-d_var, d_var];

    %Iteration number per evaluation
    stc.evalu_times = 100;

    %Exit conditions
    stc.fit_tolerance = [];
    stc.max_tolerance_times = [];
%% BasePSO
    stc.basepso.enable = true;
end