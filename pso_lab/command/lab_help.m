function lab_help
    cf = string(pwd);

    cd(".\pso_lab\doc");

    day = string(datetime("today"));
    t = char(datetime);
    t = t(12:end);
    t(t == ':') = '-';
    filename = "[" + day + "][" + string(t) + "]help_v" + lab_config().version + ".html";
    disp("Generating help documentation ... ");
    file_util().convert("help.mlx", filename);

    copyfile(filename, cf + "\cache\" + filename, "f");

    delete(filename);
    cd(cf + ".\cache");
    fprintf("%c%c", 8, 8);
    disp("complete.");

    winopen(filename);
    cd(cf)
    disp("Help document opened in default browser.");
    t = toc;
    disp(['Duration: ', num2str(t), ' s']);
end