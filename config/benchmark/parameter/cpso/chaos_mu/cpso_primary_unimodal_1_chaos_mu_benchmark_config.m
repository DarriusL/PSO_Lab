
function stc = cpso_primary_unimodal_1_chaos_mu_benchmark_config
    testfun_stc = math_util().test_function("primary");

    stc = lab_para_stc;

    %Save Data
    stc.save = true;

    %parallel processing
    stc.para_enable = true;
    stc.para_num = 4;
    
%% Basic configuration

    %Fitness function
    stc.fit_fun = testfun_stc.unimodal().fun1.function;

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

    %Exit conditions
    stc.fit_tolerance = [];
    stc.max_tolerance_times = [];



%% CPSO
    stc.cpso.enable = true;

    %Chaotic Iterative Control Parameters
    stc.cpso.chaos_mu = [0.5, 1.5, 3.2, 3.49, 3.8, 4];

    %Length of chaotic sequence
    stc.cpso.chaos_length = 500;

end