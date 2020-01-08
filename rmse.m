function [RMSE] = rmse( realY, predY)
% Returns root mean squared error of model compared to real data
% Written by Sam Failor

if length(predY) > 1
    RMSE = sqrt(nansum((predY - realY).^2)/size(realY,1)); 
else
    RMSE = sqrt((predY - realY).^2); 
end

