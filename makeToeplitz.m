function toeplitzMatrix = makeToeplitz(respTimes, predictors, windows)
%Extract the trial-by-trial activity for ROIs in each imaging plane
%and align to a particular trial event (stim on, movement on, etc.)

%% make matrix
featureList = fieldnames(predictors);
    
for f = 1:length(featureList)
    if contains(featureList{f},'stimulus')
        wd = windows.stimulus;
    elseif contains(featureList{f},'movement')
        wd = windows.movement;
    elseif contains(featureList{f},'rewardSide')
        wd = windows.rewardSide;
    elseif contains(featureList{f},'outcome')
        wd = windows.outcome;
    end

    %interpolate predictor times to planeFrameTimes
    predTimes = interp1(respTimes, respTimes, predictors.(featureList{f}).times, 'nearest');
    %index which elements of planeFrameTimes correspond to
    %predictor times
    [ptimes , planeIdx] = intersect(respTimes,predTimes);
    % in theory this should be the same as above but sometimes there
    % are NaNs or duplicate values in predTimes which are
    % dropped...this tracks which ones we kept 
    [~, predIdx] = intersect(predTimes,ptimes);
    tplz{1,f} = zeros(size(respTimes,2),length(wd));
    for w = 1:length(wd)
        tplz{1,f}(planeIdx+wd(w),w) = predictors.(featureList{f}).values(predIdx);
        tplz{2,f} = wd;
    end
end
    
toeplitzMatrix = cat(2,tplz{1,1:length(featureList)});
    
