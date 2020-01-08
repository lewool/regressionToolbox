function toeplitzMatrix = makeToeplitz(expInfo, allFcell, eventTimes, predictors, windows)
%Extract the trial-by-trial activity for ROIs in each imaging plane
%and align to a particular trial event (stim on, movement on, etc.)

%% LOAD DATA FROM EXPINFO

mouseName = expInfo.mouseName;
expDate = expInfo.expDate;
expNum = expInfo.expNum;
expSeries = expInfo.expSeries;
block = expInfo.block;
Timeline = expInfo.Timeline;
numPlanes = expInfo.numPlanes;


%% GET FRAME TIMES
 
planeInfo = getPlaneFrameTimes(Timeline, numPlanes);

%% RETRIEVE TIME TRACE PER PLANE
featureList = fieldnames(predictors);
 
for iPlane = 2:numPlanes
    
    planeSpikes = zscore(double(allFcell(iPlane).spikes{1,find(expSeries == expNum)})')';

    % retrieve the frame times for this plane's cells
    planeFrameTimes = planeInfo(iPlane).frameTimes;
    if size(planeFrameTimes,2) ~= size(planeSpikes,2)
        planeFrameTimes = planeFrameTimes(1:size(planeSpikes,2));
    end
    
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
        predTimes = interp1(planeFrameTimes, planeFrameTimes, predictors.(featureList{f}).times, 'nearest');
        %index which elements of planeFrameTimes correspond to
        %predictor times
        [ptimes , planeIdx] = intersect(planeFrameTimes,predTimes);
        % in theory this should be the same as above but sometimes there
        % are NaNs or duplicate values in predTimes which are
        % dropped...this tracks which ones we kept 
        [~, predIdx] = intersect(predTimes,ptimes);
        tplz{1,f} = zeros(size(planeFrameTimes,2),length(wd));
        for w = 1:length(wd)
            tplz{1,f}(planeIdx+wd(w),w) = predictors.(featureList{f}).values(predIdx);
            tplz{2,f} = wd;
        end
    end
    
    toeplitzMatrix{iPlane-1} = cat(2,tplz{1,1:length(featureList)});
    
end
