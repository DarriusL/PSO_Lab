function [value, argout] = lab_command(argin)%command, inquire

    argout = function_handle.empty;
    lab_cmd = ["setup", "help", "zip", "tar", "clear"];
    
    if ischar(argin) || isstring(argin)
        if ismember(argin, lab_cmd)
            value = true;
            disp("[" + string(datetime) + "]Execute comand: " + string(argin));
            switch argin
                case "setup"
                    lab_setup;
                case "help"
                    lab_help;
                case "zip"
                    lab_compress("zip");
                case "tar"
                    lab_compress("tar");
                case "clear"
                    lab_clear;
            end
        else
            value = false;
        end
    elseif ~isempty(argin)
        value = false;
        argout = lab_cmd;
    end
end