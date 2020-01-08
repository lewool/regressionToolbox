function [yPred] = yPredict(thetas, X)
% Returns predicted values from a  linear model of the form yPred = X * thetas.
% Written by LEW but borrowed heavily from script written by Sam Failor.

% X: n x m matrix where n is the number of observations and m is the number 
% of predictors (e.g., task variables, pupil size, etc.). 
% thetas: m-dim vector of weights (from findThetas.m or similar) 
% yPred = n-dim vector of predicted responses/outputs (e.g., binned calcium
% or spike rate)

%%%%%% CHECK DIMENSIONS %%%%%%

if size(thetas,1) > size(X,2)
    % if X is one column short and doesn't already contain an intercept...
    if size(thetas,1) - size(X,2) == 1 && round(mean(X(:,1))) ~= 1
            % ...add one
            X = addInt(X);
            disp('X seems to be missing an intercept; adding it now');
    else
        % otherwise throw an error
        error('X and thetas are different sizes; cannot continue')
    end
end

%%%%%% PREDICT Y VALUES %%%%%%
yPred = X*thetas;

% pause if yPred is NaNs (this means something is wrong)
if isnan(yPred)
    keyboard
    disp('yPred contains NaNs')
end
