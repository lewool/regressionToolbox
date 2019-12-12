function [XInt] = addInt(X)
% Add a column of ones to a design matrix X
% Written by Sam Failor

XInt = [ones(size(X,1),1) X];

end

