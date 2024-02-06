jobs = [12:20,22:27,31:33];

%% create data
final_data = [];
for j_i = 1:length(jobs)
    % get matlab data
    load(fullfile('C:\Flow_Characterisation\Matlab_data',sprintf('Job%.0f.mat',jobs(j_i))),'res'); 

    % load TFI data
    for i = 1:length(res)
        [u,v,w,Ps,Settings] = tfi.ReadTHFile([res(i).TFI_filename,' (Ve).thA'],32000,0);
        % convert velocity vector to tunnel coord
        V = [u,v,w]';
        V = fh.rotx(-res(i).Roll)*V;
        [U,pitch,yaw] = tfi.VelPitchYaw(V(1,:)',V(2,:)',V(3,:)');
        res(i).U = mean(U);
        res(i).u = mean(V(1,:));
        res(i).v = mean(V(2,:));
        res(i).w = mean(V(3,:));
        res(i).pitch = mean(pitch);
        res(i).yaw = mean(yaw);
        res(i).flow_angle = rad2deg(atan2(mean(V(3,:)),mean(V(2,:))));
        res(i).turb_u = std(u)/res(i).U*100;
        res(i).turb_v = std(u)/res(i).U*100;
        res(i).turb_w = std(u)/res(i).U*100;
        res(i).turb = std(U)/res(i).U*100;
        clear u v w V U pitch yaw
    end

    % calculate probe position
    for i = 1:length(res)
        probe_loc = fh.rotx(-res(i).Roll)*[0 0 -res(i).Radius]';
        res(i).y = probe_loc(2);
        res(i).z = probe_loc(3);
    end

    % load OC data
    oc_file = fullfile('C:\Flow_Characterisation\WSC_data',sprintf('Job%.0f.csv',jobs(j_i)));
    data = readmatrix(oc_file,"NumHeaderLines",1);
    for j = 1:length(res)
        res(j).U_inf = data(j,13);
        res(j).Delta_U = res(j).U - res(j).U_inf;
        res(j).P_inf = data(j,12)*100;
        res(j).T_inf = data(j,11);
    end

    final_data = farg.struct.concat(final_data,res);

end

%% create streamwise plot
xs = [-630,-120,280];
figure(1);clf;
tt = tiledlayout(3,1);
for x_i = 1:3
    tmp_res = farg.struct.filter(final_data,{{'U_inf',{'tol',25,2.5}},{'x',xs(x_i)},{'Radius',@(x)x<710}});
    nexttile(x_i)
    quiver([tmp_res.y],[tmp_res.z],[tmp_res.v],[tmp_res.w])
    axis equal
    % plot walls
    hold on
    nodes = octagon_nodes(1.524,2.1336,0.6146,...
           'FilletAngle',32,'origin',[-2.1336/2,-1.524/2]);
    nodes = nodes*1000;
    nodes = [nodes;nodes(1,:)];
    plot(nodes(:,1),nodes(:,2),'k-')
%     title(sprintf('Tunnel Velocity = %.0f m/s',xs(x_i)))
end

tt.Title.String = 'Streamwise Velocity Component';

%% create colour maps
xs = [-630,-120,280];
figure(2);clf;
tt = tiledlayout(3,1);

% create wall nodes / interpolation points
nodes = octagon_nodes(1.524,2.1336,0.6146,...
           'FilletAngle',32,'origin',[-2.1336/2,-1.524/2]);
nodes = nodes*1000;
nodes = [nodes;nodes(1,:)];
[Y,Z] = meshgrid(linspace(-2.1336/2,2.1336/2,101)*1000,linspace(-1.524/2,1.524/2,101)*1000);
Ys = Y(:);
Zs = Z(:);
idx = inpolygon(Ys,Zs,nodes(:,1),nodes(:,2));

for x_i = 1:3
    tmp_res = farg.struct.filter(final_data,{{'U_inf',{'tol',25,2.5}},{'x',xs(x_i)}});
    nexttile(x_i)

    y = [tmp_res.y]';
    z = [tmp_res.z]';
    val = [tmp_res.Delta_U]';
%     val = abs(atand(sqrt([tmp_res.w].^2 + [tmp_res.v].^2)./[tmp_res.u]))';
%     val = [tmp_res.w]';
%     val = (sqrt([tmp_res.w].^2 + [tmp_res.v].^2)./[tmp_res.U_inf])'*100;
%     val = [tmp_res.flow_angle]';
%     val = [tmp_res.turb]';
%     val = ([tmp_res.Delta_U]./[tmp_res.U_inf])'*100;
%     val = [tmp_res.Delta_U]';
    F = scatteredInterpolant(y,z,val,'natural','none');
    val_interp = F(Y,Z);
    contourf(Y,Z,val_interp,linspace(0.4,1,11));
    axis equal
    % plot walls
    hold on
    plot(nodes(:,1),nodes(:,2),'k-')
%     title(sprintf('Tunnel Velocity = %.0f m/s',Vs(v_i)))
%     clim([-2,1])
    clim([0.4,1])
%     clim([-2,1.5]);
%     if x_i == 3
        cb = colorbar;
%     end
    

    % plot points measured
    plot(y,z,'k.')
end


% %% plot the results
% Vs = [15,25,35];
% figure(1);clf;
% tt = tiledlayout(3,4);
% 
% for v_i = 1:3
%     tmp_res = farg.struct.filter(res,{{'U_inf',{'tol',Vs(v_i),2.5}}});
%     nexttile((v_i-1)*4+1)
%     plot([tmp_res.Roll],[tmp_res.Delta_U]);
%     xlabel('Roll [deg]')
%     ylabel('Delta V [m/s]')
% 
%     nexttile((v_i-1)*4+2)
%     plot([tmp_res.Roll],[tmp_res.u]);
%     xlabel('Roll [deg]')
%     ylabel('u [m/s]')
% 
%     nexttile((v_i-1)*4+3)
%     plot([tmp_res.Roll],[tmp_res.v]);
%     xlabel('Roll [deg]')
%     ylabel('v [m/s]')
% 
%     nexttile((v_i-1)*4+4)
%     plot([tmp_res.Roll],[tmp_res.flow_angle]);
%     xlabel('Roll [deg]')
%     ylabel('w [m/s]')
% 
% end
% 
% 
