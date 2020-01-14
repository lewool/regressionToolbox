function plotKernels(fitKernels, predictors, windows)   




%%
Fs = 0.1;
featureList = fieldnames(predictors);

k = 139;
max_k = size(fitKernels{1},2);

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

thetas = [];
for f = 1:length(fitKernels)
    thetas = [thetas; fitKernels{f}(:,k)];
end
maxY = max([max(thetas) .5]); 
minY = min(thetas);




for p = 1:length(featureList)
    if mod(p,2) > 0
        c = 1;
    else
        c = 2;
    end
        
    if contains(featureList{p},'stimulus') > 0
        subplot(1,nsubs,find(strcmp(events,'stimulus')))
        title('stimulus')
        colors = [0 .4 1; 1 0 0];
        xwin = windows.stimulus*Fs;
    elseif contains(featureList{p},'movement') > 0
        subplot(1,nsubs,find(strcmp(events,'movement')))
        title('movement')
        colors = [0 .4 1; 1 0 0];
        xwin = windows.movement*Fs;
    elseif contains(featureList{p},'outcome') > 0
        subplot(1,nsubs,find(strcmp(events,'outcome')))
        title('outcome')
        colors = [0 .5 0; 1 0 0];
        xwin = windows.outcome*Fs;
    end
    onsetLine = line([0 0],[minY maxY]);
    set(onsetLine,'LineStyle', '--', 'LineWidth',1,'Marker','none','Color',[.5 .5 .5]);
    kPlot = plot(xwin, fitKernels{p}(:,k));    
    set(kPlot,'LineStyle', '-', 'LineWidth',1,'Marker','none','Color',colors(c,:));
    hold on;
	xlim([min(xwin)-.1 max(xwin)+.1])
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

