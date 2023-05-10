function lab_deactivate(stc)
    pause(1/1000);
    %deactivate log
    deactivate_log(stc.log);

    %rmove dependencies dir
    path_util().rm_paths(stc.paths);

    if stc.end_with_config
        %Check parallel environment and close
        if stc.config.para_enable
            delete(gcp('nocreate'));
        end
    end
end

function deactivate_log(stc)
    diary off
    logfile = ".\.temp\" + string(stc.logfile_name);
    if path_util().chk_pf([], logfile)
        path_util().make_dir(stc.logfile_path);
        copyfile(logfile, stc.logfile_path);
        delete(logfile);
        rmdir(".\.temp", "s");
    else
        warning("Log file close error");
    end
end