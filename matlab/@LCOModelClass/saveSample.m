function [RunNumber,d] = saveSample(obj)
%% Folding Wingtip WTT DAQ - Save data
% Created: R.C.M. Cheung
% Contact: r.c.m.cheung@bristol.ac.uk
% Date: 11 NOV 2019

%get the next run number
RunNumber = GetNextRunNumber();
% RunNumber = 1;
obj.Meta.RunNumber = RunNumber;
% RunNumber = 1;
% create filename string
gName = obj.Meta.RunType;
fName = obj.Meta.TestType;

if(~isempty(gName))
    fName = [fName,'_',gName];
end
if(obj.Meta.Locked)
    fName = [fName,'_locked'];
end
if(strcmp(fName(1),'_'))
    fName = fName(2:end);
end
dt = datetime;
dt.Format = 'dd_MMM_uuuu_HH_mm_ss';
fName = sprintf('%s_Run%.0f_%s.mat',fName,RunNumber,dt);

% save data
[status,msg,~] = mkdir(obj.Meta.dataDir);
if(~status)
    disp(msg)
end
fprintf('Saving to file:\n%s\n',fName);


d = obj.ToSampleStruct();
save(fullfile(obj.Meta.dataDir,fName),'d');
end