function di_sys = difint_estimator()

cs = getHipsterSS();

%% A differentiating and integrating observer designed for Hipster
n = 3;
pass_ix = 1:n;
diff_ix = 1:2;
int_ix = 3;
alpha = 0.1;

%[theta_l theta_r psi_dot] 
%   -> [theta_l theta_r psi_dot theta_l_dot theta_r_dot psi] 
di_sys = diff_int_obs(n, pass_ix, diff_ix, int_ix, alpha);

permutationmat = [1 0 0 0 0 0;
                  0 1 0 0 0 0;
                  0 0 0 0 0 1;
                  0 0 0 1 0 0;
                  0 0 0 0 1 0;
                  0 0 1 0 0 0];
              
%[theta_l theta_r psi_dot theta_l_dot theta_r_dot psi]  
%     -> [theta_l theta_r psi theta_l_dot theta_r_dot psi_dot]              
di_sys = permutationmat*di_sys;

D = [cs.C(1:2,1:3); 0 0 cs.C(3,6)];

G = blkdiag(D,D);
                                                                                 
%[theta_l theta_r psi theta_l_dot theta_r_dot psi_dot]
%   -> [x phi psi x_dot phi_dot psi_dot]
di_sys = G\di_sys;

%% 

di_sys.inputgroup.y = 1:3;
di_sys.outputgroup.x_hat = 1:6;

di_sys.InputName = {'theta_l','theta_r','pitch_vel'};
%di_sys.StateName = {'x_hat','yaw_hat','pitch_hat','vel_hat','yaw_vel_hat','pitch_vel_hat'};
di_sys.OutputName = {'x_hat','yaw_hat','pitch_hat','vel_hat','yaw_vel_hat','pitch_vel_hat'};

