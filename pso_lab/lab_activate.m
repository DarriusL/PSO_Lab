function stc = lab_activate(argin)
    %Delete redundant files
    temfile = dir("*.zip");
    temfile= [temfile, dir("*.tar")];
    if ~isempty(temfile)
        for i = 1:length(temfile)  
            delete(temfile(i).name);
        end
    end

    %add dependencies dir
    paths = lab_path;
    addpath(genpath(".\lib"));
    path_util().add_paths(paths);

    %Get the directory of the configuration file if there's a profile
    [~, lab_cmd] = lab_command(true);
    stc.end_with_config = false;
    if ~ismember(argin{1}, lab_cmd)
        %There is a configuration file. Get its path and activate the corresponding configured lab
        [paths(end + 1), cfg_gen, ext] = fileparts(string(argin{1}));
        addpath(genpath(paths(end)));
        assert(ext == ".m", "invalid configuration file suffix")
        stc.config = eval(cfg_gen + "()");
        stc.cfg_gen = cfg_gen;
        
        %check configuration file
        check_cfg(stc.config, argin{2});

        %Check whether parallel computing is enabled and correct unreasonable settings
        stc.config = check_parallelism(stc.config, argin{2});

        %Run with profile
        stc.end_with_config = true;
    end
    stc.paths = paths;

    %activate log
    stc.log = activate_log(argin);
end

%activate log
function stc = activate_log(argin)
    [~, lab_cmd] = lab_command(true);
    if ~ismember(string(argin{1}),lab_cmd )
        argin = argin{2};
    else
        argin = argin{1};
    end

    day = char(datetime);
    time = day(12:end);
    time(time == ':') = '-';
    time = string(time);

    logfile_path = ".\cache\.LogFiles\" + string(datetime("today"));
    path_util().make_dir(".\.temp");

    logfile_name = "[" + time + "]" + string(argin);
    diary(".\.temp\" + logfile_name);

    stc.logfile_path = logfile_path;
    stc.logfile_name = logfile_name;
end

%check config
function check_cfg(cfg, mode)
    mode = string(mode);
    assert(ismember(mode, lab_mode()));

    assert(~isempty(cfg.fit_fun));
    assert(~isempty(cfg.algorithm));
end

%Check whether parallel computing is enabled and correct unreasonable settings
function cfg = check_parallelism(cfg, mode)
    if mode == "par-optimize" && cfg.para_enable == false
        warning("mode:par-optimize must enable parallel processing");
        cfg.para_enable = true;
        warning("mode:par-optimize's parallel processing turned on automatically");
    end

    if cfg.para_enable
        if mode ~= "search" && mode ~= "par-optimize"
            cfg.para_enable = false;
            warning(['Parallel computing is not possible in this mode,' ...
                ' which has been adjusted']);
            return
        end

        try
            if isempty(gcp("nocreate"))
                parpool(cfg.para_num);
            end
        catch
            error(['The local computer does not support parallel computing, or the number of parallel ' ...
                'computing exceeds the local maximum allowable parallel number']);
        end
    end
end