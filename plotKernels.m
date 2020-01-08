function plotKernels(toeplitzMatrix, predictors, windows)   

%% GET PREDICTOR MATRIX

[predictors, windows] = getPredictors(expInfo, eventTimes, {'stimulus' 'movement' 'outcome'}, 5, 'all');

%%
k = 19;
max_k = size(planeSpikes,1);

nsubs = 0;
events = {'stimulus' 'movement' 'outcome'};
for e = 1:length(events)
    if sum(contains(featureList,events{e})) > 0
        nsubs = nsubs + 1;
    end
end

fig = figure(100);
while k <= max_k
for s = 1:nsubs
    subplot(1,nsubs,s)
    cla;
end

testCell = planeSpikes(k,:)';
[thetas] = findThetas(toeplitzMatrix, testCell, 1, .5);

maxY = max([max(thetas(2:end))+thetas(1)]); %max(thetas(2:end))+thetas(1);
minY = min([min(thetas(2:end))+thetas(1)]); %min(thetas(2:end))+thetas(1);
% nsubs = length(featureList);



thlen = [];
for p = 1:length(featureList)
    if mod(p,2) > 0
        c = 1;
    else
        c = 2;
    end
    
    thlen(p) = size(tplz{1,p},2);
    
    if contains(featureList{p},'stimulus') > 0
        subplot(1,nsubs,find(strcmp(events,'stimulus')))
        title('stimulus')
        colors = [0 .4 1; 1 0 0];
    elseif contains(featureList{p},'movement') > 0
        subplot(1,nsubs,find(strcmp(events,'movement')))
        title('movement')
        colors = [0 .4 1; 1 0 0];
    elseif contains(featureList{p},'outcome') > 0
        subplot(1,nsubs,find(strcmp(events,'outcome')))
        title('outcome')
        colors = [0 .5 0; 1 0 0];
    end
    onsetLine = line([0 0],[minY maxY]);
    set(onsetLine,'LineStyle', '--', 'LineWidth',1,'Marker','none','Color',[.5 .5 .5]);
    kPlot = plot(tplz{2,p}*.2, thetas(1)+ thetas(sum(thlen)-thlen(p)+2:sum(thlen)+1)');
    
        set(kPlot,'LineStyle', '-', 'LineWidth',1,'Marker','none','Color',colors(c,:));
    hold on;
	xlim([min(tplz{2,p}*.2)-.1 max(tplz{2,p}*.2)+.1])
    ylim([minY maxY]);
    ylabel('weights')
    xlabel('from onset (s)')
    box off
end

was_a_key = waitforbuttonpress;
    if was_a_key && strcmp(get(fig, 'CurrentKey'), 'leftarrow')
      k = max(1, k - 1);
    elseif was_a_key && strcmp(get(fig, 'CurrentKey'), 'rightarrow')
      k = min(max_k, k + 1);
    end
end

