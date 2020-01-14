% cellResps is an array of size nTimepoints x nCells
% predictors = structure of different task events and their times/values
% predMats: cell array containing predictor matrices (each size nTimepoints x nFeatures)
%% load experiment details

% close all;
% clear all;

expInfo = initExpInfo({{'LEW008'}},{{'2019-02-07',1,[1]}});

%% load data
expInfo = data.loadExpData(expInfo);

%% get event timings and wheel trajectories

[eventTimes, wheelTrajectories] = getEventTimes(expInfo, {'stimulusOnTimes' 'interactiveOnTimes' 'stimulusOffTimes'});

 %% load traces
[allFcell, expInfo] = loadCellData(expInfo);

%% collect all cells into 1 array

Fs = 0.1;
[cellResps, respTimes] = interpCellTimes(expInfo, allFcell, Fs);

% z-score
cellResps = zscore(cellResps);

%% get relevant predictors and make predMat

[predictors, windows] = getPredictors(expInfo, eventTimes, {'stimulus' 'movement' 'outcome'}, Fs, 'late');
toeplitzMatrix = makeToeplitz(respTimes, predictors, windows);

%%

predMats{1} = toeplitzMatrix;

intFlag = 1;

% Lambda values to test
lambdas = [10^-6 + 1.848.^(0:35) 1.848.^(54)];

finalVE = nan(size(cellResps,2), length(predMats));
finalRMSE = finalVE;

finalWeights = cell(length(predMats),1);

% For memory limitations, split cells into blocks for multivariate 
% fitting - only does this when fitting a large number of cells
nBlocks = 2;
blockInd = randi(nBlocks,size(cellResps,2),1);
%%

% for each arbitrary block of cell responses, ...
for b = 1:nBlocks
    
    %report status
    disp(['Cell block ', num2str(b)])
    
    %determine cell index
    cellInd = find(blockInd == b);
    
    %initialize array to track each cell's best lambda value
    lambdaInd = nan(size(cellResps(:,cellInd),2), length(predMats));
    
    % for each model in predMats, ...
    for m = 1:length(predMats)
        
        %initialize matrices for variance explained and RMSE
        allVE = nan(size(cellResps(:,cellInd),2),length(lambdas));
        allRMSE = allVE;
        
        % report status
        disp(['Model ', num2str(m), ' - 10-fold CV'])
        
        % set up the partitions for 10-fold cross-validation
        rng('default')
        cvInd = cvpartition(num2str(predMats{m}), 'KFold', 10);
        
        % initialize the matrix to hold the predicted responses from
        % regression
        predResp = nan(size(cellResps,1), size(cellResps(:,cellInd),2), length(lambdas));
        
        % for each lambda in lambdas, ...
        for l = 1:length(lambdas)
            
            % for each partition in cvInd, ...
            for cv = 1:cvInd.NumTestSets
                
                % report status
                disp(['Model ', num2str(m), ', block ', num2str(b), ', CV ', num2str(cv), ', lambda ', num2str(l)])
                
                %specify which rows of predictors/responses will make up
                %the training set
                xTrain = predMats{m}(training(cvInd,cv),:);
                yTrain = cellResps(training(cvInd,cv),cellInd);
                
                %find the thetas that solve the linear equation
                k = findThetas(xTrain, yTrain, intFlag, lambdas(l), true);
                
                %compute the predicted responses using the thetas & test predictors
                predResp(test(cvInd,cv),:,l) = yPredict(k,predMats{m}(test(cvInd,cv),:));
                
            end
            
            %compute the variance explained and RMSE for real vs predicted
            %responses
            allVE(:,l) = linearVE(cellResps(:,cellInd),predResp(:,:,l));
            allRMSE(:,l) = rmse(cellResps(:,cellInd),predResp(:,:,l));
            
        end
        
        %if more than one lambda, find the optimal one for each cell  
        if length(lambdas) > 1
            
            
            % Find the lambda with minimum RMSE for each cell
            [finalRMSE(cellInd,m),lambdaInd(:,m)] = min(allRMSE,[],2);
            
            %Find the VE associated with that lambda/minRMSE
            indVE = sub2ind(size(allVE), (1:size(allVE,1))', lambdaInd(:,m));
            finalVE(cellInd,m) = allVE(indVE);
            
            for c = 1:length(cellInd)
                
                %report status
                disp(['Final fit for cell ', num2str(cellInd(c)), ', model ', num2str(m), ', block ', num2str(b)])
                
                %fit final weights based on the chosen lambda
                finalWeights{m}(:,cellInd(c)) = findThetas(predMats{m}, cellResps(:,cellInd(c)), intFlag, lambdas(lambdaInd(c,m)), true);
                
            end
        
        % if only one lambda, carry on without determining min(RMSE)
        else
            
            %there's already only one value per cell, copy it down
            finalVE(cellInd,m) = allVE;
            finalRMSE(cellInd,m) = allRMSE;
            
            %report status
            disp(['Final fit model ', num2str(m), ', block ', num2str(b)])
            
            %fit final weights based on the chosen lambda
            finalWeights{m}(:,cellInd) = findThetas(predMats{m}, cellResps(:,cellInd), intFlag, lambdas(1), true);
            
        end
        
    end
    
end

%%

featureList = fieldnames(predictors);
ww = intFlag + 1;
for f = 1:length(featureList)
    if contains(featureList{f},'stimulus')
        wd = length(windows.stimulus);
    elseif contains(featureList{f},'movement')
        wd = length(windows.movement);
    elseif contains(featureList{f},'rewardSide')
        wd = length(windows.rewardSide);
    elseif contains(featureList{f},'outcome')
        wd = length(windows.outcome);
    end
    fitKernels{f} = finalWeights{m}(ww:ww+wd-1,:);
    ww = ww + wd;
end