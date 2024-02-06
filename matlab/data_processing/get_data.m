job = 12;
runs = 2:10;

job = 13;
run = 1;

load(fullfile('C:\Flow_Characterisation\Matlab_data',sprintf('Job%.0f.mat',job)),'res');

for i = 1:length(res)
    [u,v,w,Ps,Settings] = tfi.ReadTHFile([res(i).TFI_filename,' (Ve).thA'],32000,0);
    % convert velocity vector to tunnel coord
    V = [u,v,w]';
    V = fh.rotx(-res(i).Roll)*V;
    [U,pitch,yaw] = tfi.VelPitchYaw(V(1,:)',V(2,:)',V(3,:)');
    res(i).U = mean(U);
    res(i).u = mean(u);
    res(i).v = mean(v);
    res(i).w = mean(w);
    res(i).pitch = mean(pitch);
    res(i).yaw = mean(yaw);
    res(i).flow_angle = rad2deg(atan2(mean(V(3,:)),mean(V(2,:))));
    clear u v w V U pitch yaw
end

%% load OC data
oc_file = fullfile('C:\Flow_Characterisation\WSC_data\02-Aug',sprintf('Job%.0f.csv',job));
data = readmatrix(oc_file,"NumHeaderLines",1);

for i = 1:length(res)
    res(i).U_inf = data(i,13);
    res(i).Delta_U = res(i).U - res(i).U_inf;
    res(i).P_inf = data(i,12)*100;
    res(i).T_inf = data(i,11);
end

%% plot the results
Vs = [15,25,35];
figure(1);clf;
tt = tiledlayout(3,4);

for v_i = 1:3
    tmp_res = farg.struct.filter(res,{{'U_inf',{'tol',Vs(v_i),2.5}}});
    nexttile((v_i-1)*4+1)
    plot([tmp_res.Roll],[tmp_res.Delta_U]);
    xlabel('Roll [deg]')
    ylabel('Delta V [m/s]')

    nexttile((v_i-1)*4+2)
    plot([tmp_res.Roll],[tmp_res.u]);
    xlabel('Roll [deg]')
    ylabel('u [m/s]')

    nexttile((v_i-1)*4+3)
    plot([tmp_res.Roll],[tmp_res.v]);
    xlabel('Roll [deg]')
    ylabel('v [m/s]')

    nexttile((v_i-1)*4+4)
    plot([tmp_res.Roll],[tmp_res.flow_angle]);
    xlabel('Roll [deg]')
    ylabel('w [m/s]')

end


