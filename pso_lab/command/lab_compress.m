function lab_compress(argin)
    assert(ismember(string(argin), ["zip", "tar"]))
    disp("compressing the environment...")
    switch string(argin)
        case "zip"
            cpshandle = @zip;
        case "tar"
            cpshandle = @tar;
        otherwise
            cpshandle = @tar;
    end

    lab_ver = lab_config().version;
    
    disp("Makeing directory: PSO_Lab_...")
    mkdir PSO_Lab_
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("Makeing directory: PSO_Lab_\data...")
    mkdir PSO_LAB_\data
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("Makeing directory: PSO_Lab_\cache...")
    mkdir PSO_LAB_\cache
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("Makeing directory: PSO_Lab_\cache\.LogFiles...")
    mkdir PSO_LAB_\cache\.LogFiles
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("Makeing directory: PSO_Lab_\test...")
    mkdir PSO_LAB_\test
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: lib->PSO_Lab_\lib...")
    copyfile lib PSO_Lab_\lib
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: algorithm->PSO_Lab_\algorithm...")
    copyfile algorithm PSO_Lab_\algorithm
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: config->PSO_Lab_\config...")
    copyfile config PSO_Lab_\config
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: memory->PSO_Lab_\memory...")
    copyfile memory PSO_Lab_\memory
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: pso_lab->PSO_Lab_\pso_lab...")
    copyfile pso_lab PSO_Lab_\pso_lab
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: tools->PSO_Lab_\tools...")
    copyfile tools PSO_Lab_\tools
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: run_lab.m->PSO_Lab_...")
    copyfile run_lab.m PSO_Lab_
    fprintf("%c%c", 8, 8);
    disp("complete.")

    disp("copying: run_lab.m->PSO_Lab_...")
    copyfile SetCurrentFile.m PSO_Lab_
    fprintf("%c%c", 8, 8);
    disp("complete.")

    cpshandle("PSO_Lab_ver." +  lab_ver, "PSO_Lab_")
    rmdir PSO_Lab_ s
    clc
    disp("The environment is successfully compressed and stored in the current directory.")
    disp("*It will be automatically cleared the next time you run the environment.");
    t = toc;
    disp(['Duration: ', num2str(t), ' s']);
end