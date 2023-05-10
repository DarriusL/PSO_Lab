%Joint simulation, all algorithms, medium, unimodal test function 6
function stc = joint_all_medium_unimodal_6_benchmark_config
    testfun_stc = math_util().test_function("medium");

    %Save Data
    stc.save = true;

    %parallel processing
    stc.para_enable = true;
    stc.para_num = 4;
    
%% Basic configuration

    %Fitness function
    stc.fit_fun = testfun_stc.unimodal().fun6.function;

    %Algorithm used
    stc.algorithm = [ "BasePSO", "PPSO", "PCPSO", "ERPSO", "TSPSO", "CPSO"];

    %size
    stc.num_dim = testfun_stc.varset.dim;
    stc.num_particles = 1000;

    %Maximum Iterations (1000 by default)
    stc.num_Iter = 1000;

    %Individual factor
    stc.idvlLrnFactor = 1.5;
    %Social factor
    stc.soclLrnFactor = 2.05;

    %Inertia weight range [lower bound, upper bound] (default 0.4~0.9)
    stc.w_range = [0.4; 0.9];

    %Variable range [lower bound, upper bound;...] (dimension * 2)
    stc.var_range = testfun_stc.varset.var_range;
    
    %Speed range [lower bound, upper bound;...] (dimension * 2)
    d_var = abs(stc.var_range(:, 1) - stc.var_range(:, 2));
    stc.v_range = 0.05 * [-d_var, d_var];

    %Each evaluation iteration number (100 by default, no need to empty the evaluation)
    stc.evalu_times = 100;

    %Exit conditions (minimum fitness change tolerance, the number of times to reach the minimum fitness tolerance, not used is empty)
    stc.fit_tolerance = [];
    stc.max_tolerance_times = [];

%% BasePSO
    stc.basepso.enable = true;

%% PPSO
    stc.ppso.enable = true;

%% PCPSO
    stc.pcpso.enable = true;
    
    %Tolerance of fitness for opening Cauchy variation
    stc.pcpso.variation_tolerance = inf;

%% TSPSO
    stc.tspso.enable = true;

    %Individual Stagnation Steps Threshold and Global Stagnation Steps Threshold (3 and 5 by default)
    stc.tspso.idvlStagnantTh = 3;
    stc.tspso.soclStagnantTh = 5;

%% ERPSO
    stc.erpso.enable = true;

    %Experience size
    stc.erpso.memory_size = 16384;

    %Experience learning factor (default 0.3)
    stc.erpso.expLrnFactor = 0.3;

    %Experience learning opens tolerance
    stc.erpso.exp_tolerance = 1e+5;

%% CPSO
    stc.cpso.enable = true;

    %Chaotic Iterative Control Parameters
    stc.cpso.chaos_mu = 4;

    %Length of chaotic sequence
    stc.cpso.chaos_length = 500;
end