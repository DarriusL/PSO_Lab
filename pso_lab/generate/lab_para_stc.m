%Generate parameter structure
function stc = lab_para_stc
    %save data
    stc.save = true;

    % Parallel processing (currently only valid in search, par-optimize mode)
    %par-optimize mode must enable parallel processing
    stc.para_enable = true;
    stc.para_num = 4;
    
%% Basic configuration

    %fitness function
    stc.fit_fun = function_handle.empty;

    %^algorithm used
    stc.algorithm = [];

    %size [dimension, number of particles]
    stc.num_dim = nan(1);
    stc.num_particle = nan(1);

    %Maximum number of iterations (default 1000)
    stc.num_Iter = 1000;

    %^Individual learning factor and social learning factor (default 1.5 and 2.05)
    stc.idvlLrnFactor = 1.5;
    stc.soclLrnFactor = 2.05;

    %Inertia weight range [lower bound, upper bound] (default 0.4~0.9)
    stc.w_range = [0.4; 0.9];

    %variable range [lower bound, upper bound; ...] (dimension * 2)
    stc.var_range = double.empty;
    
    %speed range [lower bound, upper bound;...] (dimension*2)
    stc.v_range = double.empty;

    %The number of iterations per evaluation (default 100, empty if not used)
    stc.evalu_times = 100;

    %Exit condition (minimum fitness change tolerance, the number of times the minimum fitness tolerance is reached, and empty if not used)
    stc.fit_tolerance = 1e-8;
    stc.max_tolerance_times = 100;
%% BasePSO（Basic particle swarm: configuration is required when using this algorithm）
    %set to true when used
    stc.basepso.enable = false;

%% PPSO（Disturbing particle swarm: configuration is required when using this algorithm）
    %set to true when used
    stc.ppso.enable = false;

%% PCPSO（Disturbed Cauchy mutation configuration: configuration is required when using this algorithm）
    %set to true when used
    stc.pcpso.enable = false;
    
    %^Enable fitness tolerance for Cauchy mutation
    stc.pcpso.variation_tolerance = inf;

%% TSPSO(Extreme value disturbance simplifies particle swarm configuration: configuration is required when using this algorithm) 
    %set to true when used
    stc.tspso.enable = false;

    %^Individual stagnant steps threshold and global stagnant steps threshold (default 3 and 5)
    stc.tspso.idvlStagnantTh = 3;
    stc.tspso.soclStagnantTh = 5;

%% ERPSO（Experience playback particle swarm configuration: configuration is required when using this algorithm）
    %set to true when used
    stc.erpso.enable = false;

    %Experience size
    stc.erpso.memory_size = double.empty;

    %empirical learning factor (default 0.3)
    stc.erpso.expLrnFactor = 0.3;

    %Experiential learning unlocks tolerance
    stc.erpso.exp_tolerance = 1e+5;

%% CPSO（Chaos particle swarm configuration: configuration is required when using this algorithm）
    %set to true when used
    stc.cpso.enable = false;

    %^Chaos iteration control parameter (chaos when approaching 4)
    stc.cpso.chaos_mu = 4;

    %^Chaos sequence length
    stc.cpso.chaos_length = 500;

end