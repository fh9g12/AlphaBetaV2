function [runNumber] = GetNextRunNumber()
%GETNEXTRUNNUMBER Summary of this function goes here
%   Detailed explanation goes here
load(fullfile('@ABModelClass','private','__runNumber__.mat'),'runNumber')
runNumber = runNumber+1;
save(fullfile('@ABModelClass','private','__runNumber__.mat'),'runNumber')
% runNumber = 1;
end

