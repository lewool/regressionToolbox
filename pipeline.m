% cellResps is an array of size nTimepoints x nCells
% predMats: cell array containing predictor matrices (each size nTimepoints x nFeatures)
intFlag = 1;

% Lambda values to test
lambdas = [10^-6 + 1.848.^(0:35) 1.848.^(54)];

exptRF.VERR = nan(size(cellResps,2), length(predMats));
exptRF.RMSERR = exptRF.VERR;

exptRF.kFinalRR = cell(length(predMats),1);

% For memory limitations, split cells into blocks for multivariate 
% fitting - only does this when fitting a large number of cells
nBlocks = 2;
blockInd = randi(nBlocks,size(cellResps,2),1);

% for each arbitrary block of cell responses, ....
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
                
        if length(lambdas) > 1
            
            % Find each cells optimal lambda and fit model on all data
            [bestRMSE(cellInd,m),lambdaInd(:,m)] = min(allRMSE,[],2); % Find lambda with minimum error for each cell
            indVE = sub2ind(size(allVE), (1:size(allVE,1))', lambdaInd(:,m));
            varianceExplained(cellInd,m) = allVE(indVE); % Get VE for that lambda and model
            
            for c = 1:length(cellInd)
                
                disp(['Final fit for cell ', num2str(cellInd(c)), ', model ', num2str(m), ', block ', num2str(b)])
                
                exptRF.kFinalRR{m}(:,cellInd(c)) = rReg(predMats{m}, cellResps(:,cellInd(c)), intFlag, lambdas(lambdaInd(c,m)), true);
                
            end
            
        else
            
            allVE = squeeze(mean(allVE,3));
            exptRF.VERR(cellInd,m) = allVE;
            allRMSE = squeeze(mean(allRMSE,3));
            exptRF.RMSERR(cellInd,m) = allRMSE;
            
            disp(['Final fit model ', num2str(m), ', block ', num2str(b)])

            exptRF.kFinalRR{m}(:,cellInd) = rReg(predMats{m}, cellResps(:,cellInd), intFlag, lambdas(1), true);
            
        end
        
    end
    
end