function [VE] = linearVE(realY,predY)
% Returns variance explained/R2 of a linear model
% Written by Sam Failor, commented by LEW

% realY: vector of real outputs
% predY: vector of predicted outputs (from yPredict.m or similar)

SStot = sum((realY - mean(realY)).^2);
SSres = sum((predY - realY).^2);

VE = 1 - SSres./SStot;

end

