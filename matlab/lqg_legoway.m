% function lqi_legoway creates a LQG servo regulator with integral action.
% The outputted regulator reg will take as input the reference signal
% followed by the feedbacksignal y. Use positive feedback when connecting
% the regulator to the plant.

% INPUT:
% R1        -> cov matrix for process noise
% R2        -> cov matrix for measurement noise
% Q1        -> Weight matrix for z in the design of L
% Q2        -> Weight matrix for u in the design of L

% OUTPUT:
% reg_c     <- regulator as an LTI object, continous time
% reg_d     <- regulator as an LTI object, discrete time
% L         <- statefeedback gain matrix
% K         <- Kalman gain.


function [reg_c, reg_d, L, K,kest] = lqg_legoway(sys, R1, R2, Q1, Q2, Ts, intOn)


% Default value for integration is false
if nargin < 7
    intOn = false;  
end

% Check controller input and output groups
emsg = checkSys(sys);
if emsg ~= 0
   error(emsg); 
end

% System from input u to output y
sys_yu = sys('y','u');

% Matrices and dimensions of the ss model
M = sys('z',:).C;

% System dimensions
[ny, nu] = size(sys_yu);
nx = size(sys.A,1);
nz = length(sys.outputgroup.z);
nr = nz;
nw = length(sys.inputgroup.w);
if intOn
    nxi = size(M,1);  
else
    nxi = 0;
end

% Check weight matrix dimensions
assert(all(size(R1) == [nw nw]),['R1 must be a matrix with nw = ' num2str(nw) ' rows and colums']); 
assert(all(size(R2) == [ny ny]),['R2 must be a matrix with ny = ' num2str(ny) ' rows and colums']); 
assert(all(size(Q1) == [nz+nxi nz+nxi]),['Q1 must be a matrix with nz+nxi = ' num2str(nz+nxi) ' rows and colums']);
assert(all(size(Q2) == [nu nu]),['Q2 must be a matrix with nu = ' num2str(nu) ' rows and colums']); 


%% Kalman filter
if intOn
    sys_aug = getAugSys(sys,M);
    [kest,K] = kalman(sys_aug('y',{'u','r','w'}),R1,R2);
    kest.inputgroup.r = nu+1:nu+nr;
else
    [kest,K] = kalman(sys('y',{'u','w'}),R1,R2); 
end

kest.inputgroup.u = 1:nu;
kest.inputgroup.y = kest.inputgroup.Measurement;
kest.inputgroup.KnownInput = [];
kest.inputgroup.Measurement = [];
%% Augmented system, sys plus integrating system

% remove uncontrollable sates to get better conditioning of the system
[ixu ixn] = findUnessState(sys('z','u'));

% Reduced system
sys_r = removeStates(sys('z','u'), ixu);

if (intOn)
    sys_r  = getAugSys(sys_r, sys_r.C);    
end

% Balance system to get better numerical conditioning 
[sys_b, T] = ssbal(sys_r);  

% Calculate feedback gain and transform back to unbalanced system
Lc = lqry(sys_b(:,'u'), Q1, Q2);
Lc = Lc*T;

L = zeros(nu,nx+nxi);
L(:,[ixn (nx+1):(nx+nxi)]) = Lc;
 
% % State part of feedback
Lx = L(:, 1:nx);

state_gain = ss(-L);
state_gain.outputgroup.u = 1:nu;
%% Calculation of Lr
B = sys_yu.B;
A = sys_yu.A;
sg = (M/(B*Lx - A + eye(nx,nx)*1E-6)*B); % System static gain

% least squares solution for feedforward matrix Lr
Lr = (sg'*sg)\sg';
feedf_gain = ss(Lr);
feedf_gain.inputgroup.r = 1:nr;
feedf_gain.outputgroup.u = 1:nu;
%% The complete regulator system

reg_c = series(kest('StateEstimate',:),state_gain);

if intOn
    reg_c = parallel(reg_c, feedf_gain, reg_c.inputgroup.r, ...
        feedf_gain.inputgroup.r, reg_c.outputgroup.u, feedf_gain.outputgroup.u);
else
    reg_c = parallel(reg_c, feedf_gain,[], [], reg_c.outputgroup.u, ...
        feedf_gain.outputgroup.u); 
end

reg_d = c2d(reg_c,Ts);

end

