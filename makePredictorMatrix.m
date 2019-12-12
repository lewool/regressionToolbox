function predictorMatrix = makePredictorMatrix(expInfo, eventTimes)

numCompleteTrials = length(eventTimes(1).daqTime);
contrasts = unique(expInfo.block.events.contrastValues);

stimMatrix = expInfo.block.events.contrastValues(1:numCompleteTrials)' == contrasts;
moveMatrix = expInfo.block.events.responseValues(1:numCompleteTrials)' == 1;
feedbackMatrix = expInfo.block.events.feedbackValues(1:numCompleteTrials)';
rewardSideMatrix = expInfo.block.events.highRewardSideValues(1:numCompleteTrials)' == 1;
rtMatrix = eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime' - eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime'';

predictorMatrix = [stimMatrix moveMatrix feedbackMatrix rewardSideMatrix rtMatrix];