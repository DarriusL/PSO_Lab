function lab_save(data, fig_obj, cfg_gen, option)
    day = char(datetime);
    time = day(12:end);
    time(time == ':') = '-';
    time = string(time);
    filename = cfg_gen;

    if option
        folder1 = ".\data\" + string(datetime("today"));
    else
        folder1 = ".\cache\simdata\" + string(datetime("today"));
    end
    folder2 = folder1 + "\[" + time + "]" + filename;

    mk_dir = path_util().make_dir;

    mk_dir(folder1);
    mk_dir(folder2);

    save(folder2 + "\" + filename + ".mat", "data");
    savefig(fig_obj, folder2 + "\Iteration graph.fig");

    if option
        disp(['Data has been stored in the directory:', newline, char(folder2)]);
        msgbox(['Data has been stored in the directory:', newline, char(folder2)], "reminder");
    end
end