function [thetas] = findThetas(X, y, intFlag, lambda, gpuFlag, noReg)
% This function finds a set of thetas such that X * thetas = y. 
% It uses ridge regression to punish overfitting. 
% This is written by LEW but borrowed heavily from script by Sam Failor.

% X: n x m matrix where n is the number of observations and m is the number 
% of predictors (e.g., task variables, pupil size, etc.). 
% y: n-dim vector of observed responses/outputs (e.g., binned calcium or spike rate). 
% intFlag: = 1 if you want to add an intercept column of 1s to your X matrix
% lambda: regularization parameter
% gpuFlag: = 1 if you want to use the GPU for computation
% noReg: specifies predictors you don't want to regularize

%%%%%%% CHECK OPTIONAL FLAGS %%%%%%%

if nargin < 5
    gpuFlag = false;
    noReg = [];
elseif nargin < 6
    noReg = [];
end

%%%%%%% ADD INTERCEPT %%%%%%%

if intFlag == 1
    %add intercept column to predictor matrix
    X = addInt(X);
    %omit the intercept column from regularization (plus any others)
    noReg = [1 noReg];
end

%%%%%%% REGULARIZE %%%%%%%

%generate a Tikhonov regularization matrix
regMat = eye(size(X,2)).*sqrt(lambda);

%omit from regularization (if any)
if ~isempty(noReg)
    regMat(noReg,:) = [];
end
    
%append the Tikhonov matrix to your predictor matrix
X = [X; regMat];

%append zeros to response vector to match the new predictor matrix
y = [y; zeros(size(regMat,1),size(y,2))];

%%%%%%% COMPUTE THETA(S) %%%%%%%

if gpuFlag == 1
    %convert to GPU arrays
    X = gpuArray(double(X));
    y = gpuArray(double(y));
    
    %compute the theta values
    thetas = gather(X\y);
else
    %compute the theta values
    thetas = X\y;
end

