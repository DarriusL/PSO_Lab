function stc = lab_select
    disp("[Select]Please select the corresponding configuration file (*. m) " + ...
        "and mode in the pop-up window");
    %Get Configuration Directory
    try 
        [file,path] = uigetfile(".\config\*.m");
        assert(~isequal(file, 0), "");
    catch
        error("User deselect profile");
    end
    stc.cfg_path = string([path, file]);

    %Select Mode
    mode = lab_mode;
    try
        [indx,tf] = listdlg("PromptString", {'Select a mode.',...
        'Only one mode can be selected.',''},...
        "SelectionMode", "single", ...
        "ListString", mode, ...
        "ListSize", [160, 200] , ...
        "InitialValue", 3);
        assert(indx * tf ~= 0);
    catch
        error("User deselect mode");
    end
    stc.mode = mode(indx);
end