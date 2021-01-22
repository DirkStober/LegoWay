function reg_d = lq_hipster(Q1, Q2, Ts)

cs = getHipsterSS();

R1 = eye(2);
R2 = eye(3);

% LQG servo controller with
[~, ~, L] = lqgi_servo(cs, R1, R2, Q1, Q2, Ts, false);

%% A differentiating observer
n = 3;
pass_ix = 1:n;
diff_ix = 1:2;
int_ix = 3;
alpha = 0.001;

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

cntr = [-L; eye(6)]*di_sys;

%% Calculation of Lr
sys_yu = cs('y','u');
M = cs('z','u').C;
B = sys_yu.B;
A = sys_yu.A;
sg = (M/(B*L - A + eye(size(A))*1E-6))*B; % System static gain

nr = size(M,1);
nu = size(B,2);
ny = size(sys_yu.C,1);
nx = size(L,2);

% least squares solution for feedforward matrix Lr
Lr = (sg'*sg)\sg';
feedf_gain = ss(Lr);
feedf_gain.inputgroup.r = 1:nr;
feedf_gain.outputgroup.u = 1:nu;

reg_c = parallel(feedf_gain, cntr, [], [], 1:nu, 1:nu);
%% 

reg_c.inputgroup.y = nr+1:nr+ny;
reg_c.inputgroup.r = 1:nr;
reg_c.outputgroup.u = 1:nu;
reg_c.outputgroup.x = nu+1:nu+nx;

reg_c.InputName = {'ref_yaw','ref_vel','theta_l','theta_r','pitch_vel'};
reg_c.StateName = strseq('x',1:size(cntr.A,1));
reg_c.OutputName = {'V_left','V_right','x_hat','yaw_hat','pitch_hat','vel_hat','yaw_vel_hat','pitch_vel_hat'};



if verLessThan('matlab', '8.9.0')
    refUnit = sys.stateUnit(sys.outputgroup.z);
    reg_c.StateUnit = [sys_yu.stateUnit; intUnit];
    reg_c.InputUnit = [refUnit; sys_yu.outputUnit];
    reg_c.OutputUnit= [sys_yu.inputUnit];
end           


reg_d  = c2d(reg_c, Ts, 'tustin');
% Transform state variables since tustin changes them in matlab versions
% previous to matlab 8.0
if ~verLessThan('matlab', '8.0.0')
    reg_d.B = reg_d.B*Ts;
    reg_d.C = reg_d.C/(Ts);
end

% Restore state names
reg_d.StateName = reg_c.StateName;

reg_d.notes = {'LQ'};

if verLessThan('matlab', '8.9.0')
    refUnit = sys.stateUnit(sys.outputgroup.z);
    reg_d.StateUnit = [sys_yu.stateUnit; intUnit];
    reg_d.InputUnit = [refUnit; sys_yu.outputUnit];
    reg_d.OutputUnit= [sys_yu.inputUnit];
end

