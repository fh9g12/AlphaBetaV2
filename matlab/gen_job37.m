load("C:\Users\qe19391\OneDrive - University of Bristol\WindTunnelData\Flow_Characterisation\Matlab_data\Job38.mat")
gust_family = res(2:33);
for i = 1:length(gust_family)
    gust_family(i).RunNumber = i;
end


res37 = res(1);
res37.RunNumber = 3;
rolls = [-90,90,90,-90,-90,90,90,-90];
Vs    = [15,15,20,20,25,25,30,30];
for i = 1:length(rolls)
    tmp_res = gust_family;
    for j = 1:length(tmp_res)
        tmp_res(j).RunNumber = res37(end).RunNumber + j;
        tmp_res(j).Roll = rolls(i);
        tmp_res(j).Radius = 420;
    end
    res37 = farg.struct.concat(res37,tmp_res);
end
res37(1).RunNumber = 1;
res = res37;


%% sort out file association 

files = dir("C:\Users\qe19391\OneDrive - University of Bristol\WindTunnelData\Flow_Characterisation\TFI-Data\Job_37\*.asA");
number = regexpi({files.name},'Run_(\d+)_','tokens');
for i = 1:length(files)
    files(i).RunNumber = str2double(number{i}{1}{1});
end

for i = 1:length(res)
    idx = find([files.RunNumber]==res(i).RunNumber,1);
    if ~isempty(idx)
        [~,res(i).TFI_filename,~] = fileparts(files(idx).name);
    else
        warning('No TFI found for run %.0f',res(i).RunNumber)
    end
end
save('Job37.mat','res')