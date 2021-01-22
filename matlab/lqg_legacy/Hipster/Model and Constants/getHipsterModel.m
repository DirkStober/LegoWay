function hm = getHipsterModel()
    fh = get_hipster_fh();
    gh = get_hipster_gh();
    nx = 6;
    nu = 7;
    ny = 3;
    hm = nonlinModel(fh,gh,ny,nu,nx);
    
    hm.InputGroup(1).u = 1:2;
    hm.InputGroup(1).w = 3:4;
    hm.InputGroup(1).v = 5:7;
    
    hm.OutputGroup(1).y = 1:3;
    
    hm.StateName = {'x','yaw','pitch','vel','yaw_vel','pitch_vel'}';
    hm.InputName = {'V_left','V_right','w1','w2','v1','v2','v3'}';
    hm.OutputName = {'theta_l','theta_r','pitch_vel_meas'}';
    
    hm.StateUnit  = {'[m]', '[rad]', '[rad]', '[m/s]', '[rad/s]', '[rad/s]'}';
    hm.OutputUnit = {'[rad]', '[rad]', '[rad/s]'}';
    hm.InputUnit  = {'[V]', '[V]','-','-','-','-','-'}';
    
   hm.u_range = [-7 7];
end