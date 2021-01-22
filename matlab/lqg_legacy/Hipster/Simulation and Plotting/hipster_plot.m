function hipster_plot(sim_data)
 n = length(sim_data);

% if strcmp(sim_data(2).RegName,'LQI') || strcmp(sim_data(2).RegName,'LQG')
    map = {{'x'},{'x_hat'}; 
    {'yaw'},{'yaw_hat'};
    {'pitch'},{'pitch_hat'};
    {'vel'},{'vel_hat'};
    {},{'V_right','V_left'}};

    MAP = repmat(map,1,n/2);
    MAP{2,2} = {'yaw_hat','ref_yaw'};
    MAP{4,2} = {'vel_hat','ref_vel'};
    tit = {'x','yaw','pitch','vel','input'};
% elseif strcmp(sim_data(2).RegName, 'LQ')
%     map = {{'x'},{'x_hat'}; 
%     {'yaw'},{'yaw_hat'};
%     {'pitch'},{'pitch_hat'};
%     {'vel'},{'vel_hat'};
%     {},{'V_right','V_left'}};
% 
%     MAP = repmat(map,1,n/2);
%     MAP{2,2} = {'ref_yaw','yaw_hat'};
%     MAP{4,2} = {'ref_vel','vel_hat'};
%     tit = {'x','yaw','pitch','vel','input'};
% else
%     error(['Unknown controller name: ' sim_data(2).RegName]);
% end

plotld(sim_data,MAP,[],'name',2,[],tit);

end