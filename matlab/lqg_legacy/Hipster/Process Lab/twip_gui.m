% twip_gui
%
% A graphical user interface for communication with the twip robot.

function twip_gui

global plot_gui2_handle
% do not create a new gui if it is already open
if isempty(plot_gui2_handle) || ~ishandle(plot_gui2_handle)
    % Log dir
    log_dir = 'C:/Logs';
    try
        mkdir('C:/Logs');
    catch e
    end
    
    % Hipster LQI
    signals_to_plot = {{'yaw'; 'yaw_hat' ; 'ref_yaw'} ; {'vel'; 'vel_hat'; 'ref_vel'} ; {'V_left' ; 'V_right'}};
    ref_mappings = struct('left', [0 +0.2], 'right', [0 -0.2], 'up', [1 +0.1], 'down', [1 -0.1]);
    startup_readme = sprintf('1. Lay the robot steady on the ground\n2. Click OK, to close this window\n3. At 1st beep: Wait for gyro bias to be estimated\n4. At 2nd beep: Quickly put the robot in an upright position\n5. At 3rd beep: The robot will start to balance');

     h = plot_gui2([], log_dir, ...
        signals_to_plot, ...
        'off', 'last_file', ...
        'on', ref_mappings, ...
        startup_readme);
    
    plot_gui2_handle = h;
% if it already exists, put focus on it
else
    figure(plot_gui2_handle)
end

