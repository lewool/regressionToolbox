function predictors = getPredictors(expInfo, eventTimes, featureList, patience)

block = expInfo.block;

% set up default struct
predictors = struct;

structNames = fieldnames(predictors);
contrasts = unique(block.events.contrastValues);


% set up different trial conditions
[~, lsi] = selectCondition(block, contrasts(contrasts < 0), eventTimes, initTrialConditions('movementTime',patience));
[~, rsi] = selectCondition(block, contrasts(contrasts > 0), eventTimes, initTrialConditions('movementTime',patience));
[~,lmi] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'movementDir','cw'));
[~,cri] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'responseType','correct'));
[~,iri] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'responseType','incorrect'));
[~,lhr] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'highRewardSide','left'));
[~,rhr] = selectCondition(block, contrasts, eventTimes, initTrialConditions('movementTime',patience,'highRewardSide','right'));


% replace defaults with values
for p = featureList   
   switch char(p)
        case 'stimulus'
            %find left stim trials and times
            predictors.(matlab.lang.makeValidName('stimulusLeft')).times = ...
                eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime(lsi)';
            predictors.(matlab.lang.makeValidName('stimulusLeft')).values = ones(length(lsi),1);
            
            %find right stim trials and times
            predictors.(matlab.lang.makeValidName('stimulusRight')).times = ...
                eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime(rsi)';
            predictors.(matlab.lang.makeValidName('stimulusRight')).values = ones(length(rsi),1);
            
        case 'movement'
            %find all movements
            predictors.(matlab.lang.makeValidName('movement')).times = ...
                eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime';
            predictors.(matlab.lang.makeValidName('movement')).values = ...
                ones(length(eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime'),1);
            
            %find movement direction
            predictors.(matlab.lang.makeValidName('movementDirection')).times = ...
                predictors.(matlab.lang.makeValidName('movement')).times;
            predictors.(matlab.lang.makeValidName('movementDirection')).values = predictors.(matlab.lang.makeValidName('movement')).values;
            predictors.(matlab.lang.makeValidName('movementDirection')).values(lmi) = -1;
            
       case 'outcome'
           %find correct choices
            predictors.(matlab.lang.makeValidName('outcomeCorrect')).times = ...
                eventTimes(strcmp({eventTimes.event},'rewardOnTimes')).daqTime(cri)';
            predictors.(matlab.lang.makeValidName('outcomeCorrect')).values = ones(length(cri),1);
            
            %find incorrect choices
            predictors.(matlab.lang.makeValidName('outcomeIncorrect')).times = ...
                eventTimes(strcmp({eventTimes.event},'rewardOnTimes')).daqTime(iri)';
            predictors.(matlab.lang.makeValidName('outcomeIncorrect')).values = ones(length(iri),1);
            
       case 'rewardSide_prestim'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = ...
                eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceStartTimes')).daqTime';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = ...
                zeros(length(eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceStartTimes')).daqTime'),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1;
            
        case 'rewardSide_peristim'
            predictors.(matlab.lang.makeValidName('rewardSide')).times = ...
                eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = ...
                zeros(length(eventTimes(strcmp({eventTimes.event},'stimulusOnTimes')).daqTime'),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1;
            
        case 'rewardSide_perimove'
             predictors.(matlab.lang.makeValidName('rewardSide')).times = ...
                eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime';
            predictors.(matlab.lang.makeValidName('rewardSide')).values = ...
                zeros(length(eventTimes(strcmp({eventTimes.event},'prestimulusQuiescenceEndTimes')).daqTime'),1);
            predictors.(matlab.lang.makeValidName('rewardSide')).values(lhr) = -1;
            predictors.(matlab.lang.makeValidName('rewardSide')).values(rhr) = 1; 
            
       case 'pupilSize'
           % TODO
       
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