%单次优化
function stc = lab_mode_search(subcfg, mode)
    tasknum = lab_config().task_num;

    assert(ismember(subcfg.algorithm, lab_algorithm()));

    AlgorithmClass = lab_get_algorithm(subcfg.algorithm);
    optimizer = AlgorithmClass(subcfg);

    assert(mode == "search");



    if subcfg.para_enable
        parfor i = 1:tasknum
            [iFBA(i, :), sFBA(i, :), sPB(:, i), sFB(i)] = optloop(optimizer, subcfg, i);
        end
        stc.idvlFitBestAvgArray = mean(iFBA, 1);
        stc.soclFitBestArray = mean(sFBA, 1);
        stc.soclPstBest = mean(sPB, 2);
        stc.soclFitBest = mean(sFB);
        return;
    end

    iFBA = zeros(tasknum, subcfg.MaxIterNum + 1);
    sFBA = zeros(tasknum, subcfg.MaxIterNum + 1);
    sPB = zeros(subcfg.size(1), tasknum);
    sFB = zeros(1, tasknum);
    for i = 1:tasknum
        [iFBA(i, :), sFBA(i, :), sPB(:, i), sFB(i)] = optloop(optimizer, subcfg, i);
    end
    stc.idvlFitBestAvgArray = mean(iFBA, 1);
    stc.soclFitBestArray = mean(sFBA, 1);
    stc.soclPstBest = mean(sPB, 2);
    stc.soclFitBest = mean(sFB);
end


function [idvlFitBestAvgArray, soclFitBestArray, soclPstBest, soclFitBest] = ...
        optloop(optimizer, subcfg, i)
    stc = optimizer.search(subcfg.disp_stc, i);
    idvlFitBestAvgArray = stc.idvlFitBestAvgArray;
    soclFitBestArray = stc.soclFitBestArray;
    soclPstBest = stc.soclPstBest;
    soclFitBest = stc.soclFitBest;
end
