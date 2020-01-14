function [predictors, windows] = getPredictors(expInfo, eventTimes, featureList, Fs, patience)

block = expInfo.block;

% set up default struct
predictors = struct;

structNames = fieldnames(predictors);
contrasts = unique(block.events.contrastValues);

% where to start kernel window
windowLength = 1/Fs;
stimStart = 0 * 1/Fs;
moveStart = -0.4 * 1/Fs;
rewardStart = -0.4 * 1/Fs;


% set up different trial conditions
[~, lsi] = selectCondition(block, contrasts(contrasts < 0), eventTimes, initTrialConditions('movementTime',patience));
[~, rsi] = selectCondition(block, contrasts(contrasts > 0), eventTimes, initTrialConditions('movementTime',patience));
[~,lmi] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'movementDir','cw'));
[~,rmi] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'movementDir','ccw'));
[~,cri] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'responseType','correct'));
[~,iri] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'responseType','incorrect'));
[~,lhr] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'highRewardSide','left'));
[~,rhr] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'highRewardSide','right'));

prestimulusTimes = eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceStartTimes')).daqTime;
% prestimulusTimes(isnan(prestimulusTimes)) = [];
stimulusTimes = eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime;
% stimulusTimes(isnan(stimulusTimes)) = [];
movementTimes = eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime;
% movementTimes(isnan(movementTimes)) = [];
outcomeTimes = eventTimes(strcmp({eventTimes.event},'feedbackTimes')).daqTime;
% outcomeTimes(isnan(outcomeTimes)) = [];

% replace defaults with values
for p = featureList   
   switch char(p)
        case 'stimulus'
            %find left stim trials and times
            predictors.(matlab.lang.makeValidName('stimulusLeft')).times = stimulusTimes(lsi)';
            predictors.(matlab.lang.makeValidName('stimulusLeft')).values = ones(length(lsi),1);
            
            %find right stim trials and times
            predictors.(matlab.lang.makeValidName('stimulusRight')).times = stimulusTimes(rsi)';
            predictors.(matlab.lang.makeValidName('stimulusRight')).values = ones(length(rsi),1);
            
            windows.stimulus = linspace(stimStart, stimStart+windowLength-1, windowLength);
            
        case 'movement'
            
            %find left movements
            predictors.(matlab.lang.makeValidName('movementLeft')).times = movementTimes(lmi)';
            predictors.(matlab.lang.makeValidName('movementLeft')).values = ones(length(lmi),1);
            
            %find right movements
            predictors.(matlab.lang.makeValidName('movementRight')).times = movementTimes(rmi)';
            predictors.(matlab.lang.makeValidName('movementRight')).values = ones(length(rmi),1);        
            
            windows.movement = linspace(moveStart, moveStart+windowLength-1, windowLength);
            
       case 'outcome'
           %find correct choices
            predictors.(matlab.lang.makeValidName('outcomeCorrect')).times = outcomeTimes(cri)';
            predictors.(matlab.lang.makeValidName('outcomeCorrect')).values = ones(length(cri),1);
            
            %find incorrect choices
            predictors.(matlab.lang.makeValidName('outcomeIncorrect')).times = outcomeTimes(iri)';
            predictors.(matlab.lang.makeValidName('outcomeIncorrect')).values = ones(length(iri),1);
            
            windows.outcome = linspace(rewardStart, rewardStart+windowLength-1, windowLength);
            
       case 'rewardSide_prestim'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = prestimulusTimes';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = zeros(length(prestimulusTimes),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1;
            
            windows.rewardSide = linspace(rewardStart, rewardStart+windowLength-1, windowLength);
            
        case 'rewardSide_stim'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = stimulusTimes';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = zeros(length(stimulusTimes),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1;
            
            windows.rewardSide = linspace(rewardStart, rewardStart+windowLength-1, windowLength);
            
        case 'rewardSide_move'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = movementTimes';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = zeros(length(movementTimes),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1;
            
            windows.rewardSide = linspace(rewardStart, rewardStart+windowLength-1, windowLength);
            
       case 'rewardSide_reward'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = outcomeTimes;
            predictors.(matlab.lang.makeValidName('rewardSide')).values = zeros(length(outcomeTimes),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1; 
            
            windows.rewardSide = linspace(rewardStart, rewardStart+windowLength-1, windowLength);
            
       case 'pupilSize'
           % TODO
       case responseTime
           predictors.(matlab.lang.makeValidName('responseTime')).values = movementTimes - stimulusTimes;
       
       otherwise
            error('"%s" is not a recognized feature name',char(p));
   end
end



%%%% workbench

% [~,lmi] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'movementDir','cw'));
%             predictors.(matlab.lang.makeValidName('movementLeft')).times = ...
%                 eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime(lmi)';
%             predictors.(matlab.lang.makeValidName('movementLeft')).times = 
%             [~,rmi] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'movementDir','ccw'));
%             predictors.(matlab.lang.makeValidName('movementRight')).times = ...
%                 eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime(rmi)';

%  %find high left trials
%             predictors.(matlab.lang.makeValidName('highLeftReward')).times = ...
%                 eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime(lhr)';
%             predictors.(matlab.lang.makeValidName('highLeftReward')).values = ones(length(lhr),1);
%             
%             %find high right trials
%             predictors.(matlab.lang.makeValidName('highRightReward')).times = ...
%                 eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime(rhr)';
%             predictors.(matlab.lang.makeValidName('highRightReward')).values = ones(length(rhr),1);