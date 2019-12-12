function [alignedTraces, eventWindow] = getAlignedTraces(expInfo, allFcell, eventTimes, event, upsamplingRate, cellIdx, day)
%Extract the trial-by-trial activity for ROIs in each imaging plane
%and align to a particular trial event (stim on, movement on, etc.)
%
%'event' is a string that is taken from the 'events' field of the eventTimes 
%structure generated in getEventTimes.m
%
%'alignedTraces' is a 1 x n struct of calcium, neuropil, and spike activity 
%for each ROI, where n is the number of planes. Each cell in the struct has
%dimension trial x time x ROI no. (ROI calcium/spikes) or trial x time (neuropil)
%
%A small amount of upsampling is done so all ROIs across planes have the
%same timepoints (prestimTimes, periEventTimes)
%
% OPTIONAL: 'cellIdx' and 'day'
%'cellIdx' is an indexing struct (generated via registers2p.m and 
%daisyChainDays.m) that can be used to pull out only cells imaged across
%all days of a multiday, registered experiment. 'day' is specified with a 
%scalar that refers to a column of cellIdx{plane}. CAUTION: Use indexing 
%that assumes only 'iscell' ROIs from Suite2P as we already excluded 
%non-iscell ROI traces in 'loadExpTraces.m'
%
% 9 July 2018 Added cell indexing
% 7 Dec 2018 Edited interpolation computation



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

stimWindow = [0 1 2 3 4];
moveWindow = [-2 -1 0 1 2];

%% RETRIEVE SPIKE TRACE PER CELL

numCompleteTrials = numel(block.events.endTrialTimes);

prestimTimes = prestimTimes(1:numCompleteTrials,:);

for iPlane = 1:numPlanes
    
    planeSpikes = zscore(double(allFcell(iPlane).spikes{1,find(expSeries == expNum)})')';

    % retrieve the frame times for this plane's cells
    planeFrameTimes = planeInfo(iPlane).frameTimes;
    if size(planeFrameTimes,2) ~= size(planeSpikes,2)
        planeFrameTimes = planeFrameTimes(1:size(planeSpikes,2));
    end
    
    stimTimes = interp1(planeFrameTimes, planeFrameTimes, stimTimes_DAQ, 'next');
    moveTimes = interp1(planeFrameTimes, planeFrameTimes, moveTimes_DAQ, 'next');

    % SPLIT INTO TYPES OF STIM/MOVES
    [~, stimIdx, ~] = intersect(planeFrameTimes,stimTimes);
    [~, moveIdx, ~] = intersect(planeFrameTimes,moveTimes);
end
 
toeplitz_stim = zeros(size(planeSpikes,2),length(stimWindow));
toeplitz_move = zeros(size(planeSpikes,2),length(moveWindow));

for t = 1:length(stimWindow)
    toeplitz_stim(stimIdx+stimWindow(t),t) = 1;
    toeplitz_move(stimIdx+moveWindow(t),t) = 1;
end
     
    
    
    
    
    
    
    