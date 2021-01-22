function i = varInfo(group)

switch group
    case 'x'
        i.names  = {'x', 'jaw', 'pitch', 'vel', 'jaw_vel', 'pitch_vel'};
        i.units  = {'[m]', '[deg]', '[deg]', '[m/s]', '[deg/s]', '[deg/s]'};
        i.scale  = [1 rad2deg(1) rad2deg(1) 1 rad2deg(1) rad2deg(1)];
        
    case 'y'
        i.names  = {'theta_r', 'theta_l', 'pitch_vel'};
        i.units  = {'[deg]', '[deg]', '[deg/s]'};
        i.scale  = [rad2deg(1) rad2deg(1) rad2deg(1)];
    case 'u'
        i.names  = {'V_right', 'V_left'};
        i.units  = {'[V]', '[V]'};
        i.scale  = [1 1];
    otherwise
        error(['unknown input ' group]);
end