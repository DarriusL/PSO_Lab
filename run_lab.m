function run_lab(varargin)
%There are two ways to input
%   1.command
%   2.Profile+Mode
    tic
    clc
    close all
    SetCurrentFile;

    %Add the necessary files to the directory
    addpath(genpath(".\pso_lab"));
    if isequal(string(varargin{1}), "select")
        argout = lab_select;
        varargin = {argout.cfg_path, argout.mode};
    end

    %activate lab
    lab_info = lab_activate(varargin);

    %Check if it is a command
    if lab_command(string(varargin{1}))
        lab_deactivate(lab_info);
        return;
    end

    %get configuration
    if ~exist("config_path", "var")
        config_path = varargin{1};
        mode = varargin{2};
    end


    disp(['===========================================================', newline, ...
        '                          PSO Lab                                     ', newline, ...
        '===========================================================']);

    %print config path, mode
    disp("[" + string(datetime) + "]  Lab info" );
    disp("Profile Directory : " + string(config_path));
    disp("Mode : " + string(mode));
  
    %Cut config to subcfg
    [subcfg_cell, rcd] = lab_distribute(lab_info.config, mode);
    
    %mode operation
    switch mode
        case "optimize"
            data = cell(length(subcfg_cell), 1);
            for i = 1:length(subcfg_cell)
                t_b = toc;
                data{i} = lab_mode_optimize(subcfg_cell{i}, mode);
                data{i}.identifier = rcd(i);
                t = toc;
                disp([newline, 'Misson', num2str(i) ,' duration: ', num2str(t - t_b), 's', newline]);
            end
            fig_obj = plot_optimize(data);
        case "search"
            data = cell(length(subcfg_cell), 1);
            for i = 1:length(subcfg_cell)
                t_b = toc;
                data{i} = lab_mode_search(subcfg_cell{i}, mode);
                data{i}.identifier = rcd(i);
                t = toc;
                disp([newline, 'Misson', num2str(i) ,' duration: ', num2str(t - t_b), 's', newline]);
            end
            fig_obj = plot_search(data);
        case "par-optimize"
            data = lab_mode_par_optimize(subcfg_cell{1}, mode);
            for i = 1:length(data)
                data{i}.identifier = rcd(i);
            end
            fig_obj = plot_par_optimize(data);
    end
    
    %Move data into a temporary folder or save as required by configuration
    lab_save(data, fig_obj, lab_info.cfg_gen, lab_info.config.save);

    lab_deactivate(lab_info);

    t = toc;
    disp([newline, 'Iteration is complete, total duration: ', num2str(t), 's']);
end