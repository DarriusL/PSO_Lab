function fig_obj = plot_optimize(data)
    assert(length(data) == 1)

    fig_obj = figure("Name", string(datetime) , ...
        "NumberTitle", "off");
    fig_obj.Position = [200, 100, 800, 600];
    hold on
    allclrs = clr_util().allclrs();
    data{1}.soclFitBestArray(data{1}.soclFitBestArray == inf) = realmax("double");
    plot(data{1}.soclFitBestArray + eps(1e-325), 'LineWidth', 5, 'Color', allclrs(randperm(length(allclrs), 1), :));
    set(gca, 'LineWidth', 1.5);
    set(gca, 'YScale', 'log');
    xlabel("\bf{number of iterations}");
    ylabel("\bf{fitness}");
    title("\bf{ " + data{1}.identifier + " Iteration graph}");
end