calib_folder = "C:\git\AlphaBetaV2\data\19-Oct-2022";

files = dir(calib_folder);
data = [];
for i =1:length(files)
    if ~files(i).isdir
        [~,~,ext] = fileparts(files(3).name);
        if strcmp(ext,'.mat')
            load(fullfile(files(i).folder,files(i).name),'d');
            data = farg.struct.concat(data,d);
        end
    end
end

%% filter out calibration right
calib_data = farg.struct.filter(data,{{'Meta',@(x)strcmp(x.TestType,'RightStrainGauge')}});

calib_res = struct();
for i = 1:length(calib_data)
calib_res(i).CalibMass = calib_data(i).Meta.CalibMass;
calib_res(i).CalibLength = calib_data(i).Meta.CalibLength;
calib_res(i).CalibMoment = -calib_res(i).CalibLength*calib_res(i).CalibMass*9.81;
calib_res(i).right_wingroot_strain = calib_data(i).right_wingroot_strain.mean;
calib_res(i).left_wingroot_strain = calib_data(i).left_wingroot_strain.mean;
end

%% make plot
figure(1);
clf;
hold on
L = unique([calib_res.CalibLength]);
for i = 1:length(L)
    tmp = farg.struct.filter(calib_res,{{'CalibLength',L(i)}});
    plot([tmp.right_wingroot_strain],[tmp.CalibMoment],'o')
end


pr = polyfit([calib_res.right_wingroot_strain],[calib_res.CalibMoment],1);
xs = unique([calib_res.right_wingroot_strain]);
ys = polyval(pr,xs);
plot(xs,ys,'--');

error = polyval(pr,[calib_res.right_wingroot_strain]) - [calib_res.CalibMoment];
fprintf('Gain: %.3f, Offset: %.3f, Error %.3f \n',pr(1),pr(2),std(error)/max(abs([calib_res.CalibMoment]))*100)

%% left wing

calib_data = farg.struct.filter(data,{{'Meta',@(x)strcmp(x.TestType,'LeftStrainGauge')}});

calib_res = struct();
for i = 1:length(calib_data)
calib_res(i).CalibMass = calib_data(i).Meta.CalibMass;
calib_res(i).CalibLength = calib_data(i).Meta.CalibLength;
calib_res(i).CalibMoment = -calib_res(i).CalibLength*calib_res(i).CalibMass*9.81;
calib_res(i).right_wingroot_strain = calib_data(i).right_wingroot_strain.mean;
calib_res(i).left_wingroot_strain = calib_data(i).left_wingroot_strain.mean;
end

%% make plot
figure(2);
clf;
hold on
L = unique([calib_res.CalibLength]);
for i = 1:length(L)
    tmp = farg.struct.filter(calib_res,{{'CalibLength',L(i)}});
    plot([tmp.left_wingroot_strain],[tmp.CalibMoment],'o')
end


pl = polyfit([calib_res.left_wingroot_strain],[calib_res.CalibMoment],1);
xs = unique([calib_res.left_wingroot_strain]);
ys = polyval(pl,xs);
plot(xs,ys,'--');

error = polyval(pl,[calib_res.left_wingroot_strain]) - [calib_res.CalibMoment];
fprintf('Gain: %.3f, Offset: %.3f, Error %.3f\n',pl(1),pl(2),std(error)/max(abs([calib_res.CalibMoment]))*100)




