function fig_obj = plot_search(data)
    num = length(data);
    
    fig_obj = figure("Name", string(datetime) , ...
        "NumberTitle", "off");
    hold on
    fig_obj.Position = [200, 100, 800, 600];
    allclrs = clr_util().allclrs();
    for i = 1:num
        data{i}.soclFitBestArray(data{i}.soclFitBestArray == inf) = realmax("double");
        plot(data{i}.soclFitBestArray + eps(1e-325), "LineWidth", 3, "Color", allclrs(i + 12, :), "DisplayName", data{i}.identifier);
    end
    

    set(gca, 'LineWidth', 1.5);
    set(gca, 'YScale', 'log');
    xlabel(['\bf{number of iterations}', newline, ...
        '\rm{*Error prevention: added minimum floating point precision}']);
    ylabel("\bf{fitness}");
    legend("Location", "southoutside", "NumColumns", 3); 
end