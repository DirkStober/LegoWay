%% Load state space model -------------------------------------------------
cs = getHipsterSS();
Ts = 2E-3;
const = hipster_constants();
% discrete reduced representation
rcs = ss(cs.A,cs.B(:,1:2),cs.C(1:3,:),cs.D(1:3,1:2));
ds = c2d(rcs,Ts);
%% Controller design ------------------------------------------------------
% Designvariables to Kalman filter
R1 = diag([1 1]);
R2 = 1E-7*diag([10 10 1]);   
% Designvariables to LQ
Q1 = diag([1 1 1 1]);
Q2 = 0.01*diag([1 1]);
%%
% LQG servo controller with integral action

[reg_c,reg_d] = lqg_legoway(cs,R1,R2,Q1,Q2,Ts,true);
reg = reg_d;
kalman_0_ref = ss(reg_d.A,[reg_d.B(:,3:5),reg_d.B(:,1:2)],diag(ones(1,8)),0,Ts);

%% The code generation needs the constant matrices:
lgq_controller_gen_A = reg.A;
lgq_controller_gen_B = reg.B;
lgq_controller_gen_C = reg.C;
lgq_controller_gen_D = reg.D;

%% Simulation initial values:
dx_0 = 0;
x_0 = 0;
dpsi_0 = 0;
psi_0 = 0;
%% Residual Generation
ns = 6;
% Create ss representation to generate Y,U
yuw = yu_window(ns,Ts);
[rsC,H_us,H_os,vi_s] = parity_space(ds,Ts,ns);
r0 = ps_single(ds,Ts,ns,1);
r1 = ps_single(ds,Ts,ns,2);
r2 = ps_gyro(rsC,vi_s,ds);
%%
% Generate fault and disturbance ps matrix
[H_f,H_d] = ps_matrices(ds);
T = optim([2 5],H_f,H_d,vi_s);
r34 = T*[vi_s,-vi_s*H_us];
rC = [r0;r1;r2;r34];
%%  faults
%start of fault and end of fault
fault_start = 10;
fault_stop = 30;
f_t = [fault_start;fault_stop];

% sensor fault offset
f_s_offset = [0;0;0];

% sensor fault drift
f_s_drift = [0;0;0];

% gain fault
% [1;1] fault free case
f_a_gain = [ 1 ; 1];

% offset fault
% [0;0] fault free case
f_a_offset = [ 0 ; 0];

% time delay 
% [0;0] fault free case
f_a_delay = [0;0];
