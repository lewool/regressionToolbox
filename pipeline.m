% Lambda values to test
lambdas = [10^-6 + 1.848.^(0:35) 1.848.^(54)];
% For memory limitations, split cells into blocks for multivariate fitting- only does this when fitting a large number of cells
?
nBlocks = 2;
?
blockInd = randi(nBlocks,size(cellResps,2),1);
?
% Loops through models, crossvalidating each 10-fold and testing various lambdas on each fold. 
?
for b = 1:nBlocks
    
    disp(['Cell block ', num2str(b)])
    
    cellInd = find(blockInd == b);
    
    lambdaInd = nan(size(cellResps(:,cellInd),2), length(predMats));
    
    %loop through various models (i.e., predictor matrices)
    for m = 1:length(predMats)

        allVE = nan(size(cellResps(:,cellInd),2),length(lambdas));
        allRMSE = allVE;

        disp(['Model ', num2str(m), ' - 10-fold CV'])

        rng('default')
        cvInd = cvpartition(num2str(predMats{m}), 'KFold', 10);

        predResp = nan(size(cellResps,1), size(cellResps(:,cellInd),2), length(lambdas));

        for l = 1:length(lambdas)

            for cv = 1:cvInd.NumTestSets

                disp(['Model ', num2str(m), ', block ', num2str(b), ', CV ', num2str(cv), ', lambda ', num2str(l)])
                
                xTrain = predMats{m}(training(cvInd,cv),:);
                yTrain = cellResps(training(cvInd,cv),cellInd);
                
                k = findThetas(xTrain, yTrain, 0, lambdas(l), true);
                predResp(test(cvInd,cv),:,l) = yPredict(k, predMats{m}(test(cvInd,cv),:));

            end

            %                 keyboard
            allVE(:,l) = linearVE(cellResps(:,cellInd),predResp(:,:,l));
            allRMSE(:,l) = rmse(cellResps(:,cellInd),predResp(:,:,l));

        end

        if length(lambdas) > 1

            % Find each cells optimal lambda and fit model on all data

            %         keyboard
            [exptRF.RMSERR(cellInd,m),lambdaInd(:,m)] = min(allRMSE,[],2); % Find lambda with minimum error for each cell
            indVE = sub2ind(size(allVE), (1:size(allVE,1))', lambdaInd(:,m));
            exptRF.VERR(cellInd,m) = allVE(indVE); % Get VE for that lambda and model

            for c = 1:length(cellInd)

                disp(['Final fit for cell ', num2str(cellInd(c)), ', model ', num2str(m), ', block ', num2str(b)])

                exptRF.kFinalRR{m}(:,cellInd(c)) = findThetas(predMats{m}, cellResps, intFlag, lambdas(lambdaInd(c,m)), true);

            end

        else

            allVE = squeeze(mean(allVE,3));
            exptRF.VERR(cellInd,m) = allVE;
            allRMSE = squeeze(mean(allRMSE,3));
            exptRF.RMSERR(cellInd,m) = allRMSE;

            disp(['Final fit model ', num2str(m), ', block ', num2str(b)])

            exptRF.kFinalRR{m}(:,cellInd) = rReg(exptRF.predMat{m}, cellResps(:,cellInd), intFlag, lambdas(1), true);

        end

    end