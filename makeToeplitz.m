function [alignedTraces, eventWindow] = makeToeplitz(expInfo, allFcell, eventTimes)
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
stimTimes_DAQ = eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime;
moveTimes_DAQ = eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime;

%% RETRIEVE TIME TRACE PER PLANE
 planeSpikes = zscore(double(allFcell(iPlane).spikes{1,find(expSeries == expNum)})')';
 
[~, rightStimIdx] = selectCondition(block, contrasts(contrasts > 0), eventTimes, initTrialConditions);
[~, leftStimIdx] = selectCondition(block, contrasts(contrasts < 0), eventTimes, initTrialConditions);
[~, rightMoveIdx] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementDir','ccw'));
[~, leftMoveIdx] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementDir','cw'));

for iPlane = 1:numPlanes

    % retrieve the frame times for this plane's cells
    planeFrameTimes = planeInfo(iPlane).frameTimes;
    if size(planeFrameTimes,2) ~= size(planeSpikes,2)
        planeFrameTimes = planeFrameTimes(1:size(planeSpikes,2));
    end
    
    rightStimTimes = interp1(planeFrameTimes, planeFrameTimes, stimTimes_DAQ(rightStimIdx), 'next');
    leftStimTimes = interp1(planeFrameTimes, planeFrameTimes, stimTimes_DAQ(leftStimIdx), 'next');
    moveTimes = interp1(planeFrameTimes, planeFrameTimes, moveTimes_DAQ, 'next');
    leftMoveTimes = interp1(planeFrameTimes, planeFrameTimes, moveTimes_DAQ(leftMoveIdx), 'next');
    rightMoveTimes = interp1(planeFrameTimes, planeFrameTimes, moveTimes_DAQ(rightMoveIdx), 'next');

    % SPLIT INTO TYPES OF STIM/MOVES
    [~, leftStimTimeIdx, ~] = intersect(planeFrameTimes,leftStimTimes);
    [~, rightStimTimeIdx, ~] = intersect(planeFrameTimes,rightStimTimes);
    [~, moveIdx, ~] = intersect(planeFrameTimes,moveTimes);
    [~, leftMoveTimeIdx, ~] = intersect(planeFrameTimes,leftMoveTimes);
    [~, rightMoveTimeIdx, ~] = intersect(planeFrameTimes,rightMoveTimes);
end

% set the size of the time window (in frames) around stim and move events
stimWindow = [0 1 2 3 4];
moveWindow = [-2 -1 0 1 2];

toeplitz_leftStim = zeros(size(planeSpikes,2),length(stimWindow));
toeplitz_rightStim = zeros(size(planeSpikes,2),length(stimWindow));
toeplitz_move = zeros(size(planeSpikes,2),length(moveWindow));
toeplitz_moveDir = zeros(size(planeSpikes,2),length(moveWindow));

for t = 1:length(stimWindow)
    toeplitz_leftStim(leftStimTimeIdx+stimWindow(t),t) = 1;
    toeplitz_rightStim(rightStimTimeIdx+stimWindow(t),t) = 1;
    toeplitz_move(moveIdx+moveWindow(t),t) = 1;
    toeplitz_moveDir(leftMoveTimeIdx+moveWindow(t),t) = -1;
    toeplitz_moveDir(rightMoveTimeIdx+moveWindow(t),t) = 1;
end
     
[thetas] = findThetas(toeplitz, testCell, 1, .5);
figure;
subplot(1,4,1);
plot(stimWindow*.2, thetas(1)+thetas(2:6))
title('stimulus left');
ylabel('weights')
xlabel('from onset (s)')
box off
subplot(1,4,2);
plot(stimWindow*.2, thetas(1)+thetas(7:11))    
title('stimulus right');
xlabel('from onset (s)')
box off
subplot(1,4,3);
plot(moveWindow*.2, thetas(1)+thetas(12:16))
title('movement');
xlabel('from onset (s)')
box off
subplot(1,4,4);
plot(moveWindow*.2, thetas(1)+thetas(17:21))
title('movement direction');
xlabel('from onset (s)')
box off

    
    
    
    