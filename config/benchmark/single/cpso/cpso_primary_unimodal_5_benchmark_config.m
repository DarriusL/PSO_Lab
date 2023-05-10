%Configuration file (CPSO, primary, unimodal test function 5)
function stc = cpso_primary_unimodal_5_benchmark_config

    testfun_stc = math_util().test_function("primary");

    stc = lab_para_stc;

    %Save Data
    stc.save = true;

    %parallel processing
    stc.para_enable = false;
    stc.para_num = 4;

    %Fitness function
    stc.fit_fun = testfun_stc.unimodal().fun5.function;

    %Algorithm used
    stc.algorithm = "CPSO";

    %size
    stc.num_dim = testfun_stc.varset.dim;
    stc.num_particles = 1000;

    %Maximum Iterations
    stc.num_Iter = 1000;

    %Individual Learning Factors and Social Learning Factors
    stc.idvlLrnFactor = 1.5;
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

    %
    stc.fit_tolerance = 1e-8;
    stc.max_tolerance_times = 100;
%% CPSO
    stc.cpso.enable = true;

    %Chaotic Iterative Control Parameters
    stc.cpso.chaos_mu = 4;

    %Length of chaotic sequence
    stc.cpso.chaos_length = 500;
end