%configuration file（BasePSO, primary，Single peak test function 3）
function stc = basepso_primary_unimodal_3_benchmark_config

    testfun_stc = math_util().test_function("primary");

    stc = lab_para_stc;

    %Save Data
    stc.save = false;

    %parallel processing
    stc.para_enable = false;
    stc.para_num = 4;

    %Fitness function
    stc.fit_fun = testfun_stc.unimodal().fun3.function;

    %Algorithm used
    stc.algorithm = "BasePSO";

    %size[Number of dimensions, number of particles]
    stc.num_dim = testfun_stc.varset.dim;
    stc.num_particles = 1000;

    %Maximum Iterations
    stc.num_Iter = 1000;

    %Individual Learning Factors and Social Learning Factors
    stc.idvlLrnFactor = 1.5;
    stc.soclLrnFactor = 2.05;

    %Inertia weight range [lower bound, upper bound]
    stc.w_range = [0.4; 0.9];

    %Variable range [lower bound, upper bound;...] (dimension * 2)
    stc.var_range = testfun_stc.varset.var_range;

    %Speed range [lower bound, upper bound;...] (dimension * 2)
    d_var = abs(stc.var_range(:, 1) - stc.var_range(:, 2));
    stc.v_range = 0.05 * [-d_var, d_var];

    %Iteration number per evaluation
    stc.evalu_times = 100;

    %Exit conditions
    stc.fit_tolerance = 1e-8;
    stc.max_tolerance_times = 100;
%% BasePSO
    %Set to true when using
    stc.basepso.enable = true;
end