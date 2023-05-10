function lab_clear
    option = ["Log file", "Document Cache", "Simulation data in cache"];

    try
        [indx,tf] = listdlg("PromptString", {'Select the file category to clean.', ...
        'Multiple choices (press ctrl)', ' '}, ...
        "ListString", option, ...
        "ListSize", [160, 200], ...
        "InitialValue", 3);
        assert(all(tf * indx))
    catch
        error("User deselect");
    end

    t_stc = dir(".\cache");
    log_stc = dir(".\cache\.LogFiles");
    t_stc(1:2) = [];
    log_stc(1:2) = [];

    %Log file dir  are not in scope for cleaning
    t_stc(logical(cellfun(@(x)string(x) == ".LogFiles", {t_stc.name}))) = [];

    if (isempty(t_stc) && any(ismember(indx, 2:3))) ||  (isempty(log_stc) && any(ismember(indx, 1)))
        disp("No files to clean");
        return;
    end
    %Classification
    dir_stc = t_stc(cellfun(@logical, {t_stc.isdir}));
    file_stc = t_stc(~(cellfun(@logical, {t_stc.isdir})));
    
    %Combination option deletion
    msize = 0;
    for i = 1:length(indx)
        switch indx(i)
            case 1
                if ~isempty(log_stc)
                    msize = msize + cleanup_log(log_stc);
                end
            case 2
                if ~isempty(file_stc)
                    msize = msize + cleanup_file(file_stc);
                end
            case 3
                if ~isempty(dir_stc)
                %% popup prompt
                
                    %create uifigure
                    uif_obj = uifigure("Name", "reminder", "Position", [450,120,400,200]);
                
                    remind_msg = ['The simulation data in cache may contain unsaved data.', newline ,...
                        ' Do you want to delete this possibly unsaved data?(default: no)', newline, ...
                        'Remaining time(s):'];
                    time = 12; 
                    
                    %create uilabel
                    uilabel_obj = uilabel("Parent", uif_obj, ...
                        "Text", [remind_msg, num2str(time)], ...
                        "Position", [20,60,350,150]);
                    
                    %yes button
                    uibutton(uif_obj, "Text", "yes", "Position", [100,50,48,20], "ButtonPushedFcn", @callback_ybt);
                
                    %no button
                    nbt_obj = uibutton(uif_obj, "Text", "no", "Position", [250,50,48,20], "ButtonPushedFcn", @callback_nbt);
                    
                    pause(1)
                
                    for j = 1:time - 1
                        time = time - 1;
                        if ~isvalid(uilabel_obj)
                            break;
                        else
                            uilabel_obj.Text = [remind_msg, num2str(time)];
                        end
                        pause(1)
                    end
                    if isvalid(uilabel_obj)
                        %defalut
                        callback_nbt(nbt_obj);
                    end
                end
        end
    end
    disp('-----------------------------------------------------')
    disp("Cleaning completed.");
    disp("Cleaning consuming : " + string(toc) + " s");
    disp("Size of memory released : " + string(msize / 1024) + " kb");
    
    %yes button callback
    function callback_ybt(obj, ~)
        delete(obj.Parent);
        msize =  msize + cleanup_data(dir_stc);
    end
    
    %no button callback
    function callback_nbt(obj, ~)
        delete(obj.Parent);
    end

end

%Delete normal files
function msize = cleanup_file(file_stc)
    for i = 1:length(file_stc)
        disp(['cleaning up ', file_stc(i).folder, '\', file_stc(i).name, ' ... ']);
        delete([file_stc(i).folder, '\', file_stc(i).name]);
        fprintf("%c%c", 8, 8);
        disp("complete.")
        pause(1/1000);
    end
    msize = sum(sum(cellfun(@sum, {file_stc.bytes})));
end

%Delete Data i.e. Directory
function msize = cleanup_data(dir_stc)
    file_stc = [dir(string(dir_stc(1).folder) + "\*\*\*.mat");...
        dir(string(dir_stc(1).folder) + "\*\*\*.fig")];
    msize = sum(cellfun(@sum, {file_stc.bytes}));

    cleanup_dir(file_stc, dir_stc);
end

function msize = cleanup_log(log_stc)
    file_stc = dir(".\cache\.Logfiles\*\*");
    file_stc = file_stc(~cellfun(@logical, {file_stc.isdir}));
    msize = sum(cellfun(@(x)x, {file_stc.bytes}));

    cleanup_dir(file_stc, log_stc);
end

function cleanup_dir(file_stc, dir_stc)
    %clean file
    for i = 1:length(file_stc)
        disp(['cleaning up ', file_stc(i).folder, '\', file_stc(i).name, ' ... ']);
        delete([file_stc(i).folder, '\',file_stc(i).name]);
        fprintf("%c%c", 8, 8);
        disp("complete.")
        pause(1/1000);
    end
    
    %remove dir
    for i = 1:length(dir_stc)
        subdir_stc = dir([dir_stc(i).folder, '\', dir_stc(i).name, '\*']);
        subdir_stc(1:2) = [];
        for j = 1:length(subdir_stc)
            disp(['Removing dir : ', subdir_stc(j).folder, '\', subdir_stc(j).name, ' ... '])
            rmdir([subdir_stc(j).folder, '\', subdir_stc(j).name]);
            fprintf("%c%c", 8, 8);
            disp("complete.")
            pause(1/1000);
        end
        disp(['Removing dir : ', dir_stc(i).folder, '\', dir_stc(i).name, ' ... '])
        rmdir([dir_stc(i).folder, '\', dir_stc(i).name]);
        fprintf("%c%c", 8, 8);
        disp("complete.")
        pause(1/1000);
    end
end