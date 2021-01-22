% function lqi_reg creates a LQG servo regulator with integral action.
% The outputted regulator reg will take as input the reference signal
% followed by the feedbacksignal y. Use positive feedback when connecting
% the regulator to the plant.

% INPUT:
% R1        -> cov matrix for process disturbance
% R2        -> cov matrix for measurement disturbance
% Q1        -> Weight matrix for z in the design of L
% Q2        -> Weight matrix for u in the design of L

% OUTPUT:
% reg_c     <- regulator as an LTI object, continous time
% reg_d     <- regulator as an LTI object, discrete time
% L         <- statefeedback gain matrix
% K         <- Kalman gain.


function reg_c = lq_servo(sys, Q1, Q2, intOn)

% Default value for integration is false
if nargin < 4
    intOn = false;  
end

% Check systems input and output groups
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
assert(all(size(Q1) == [nz+nxi nz+nxi]),['Q1 must be a matrix with nz+nxi = ' num2str(nz+nxi) ' rows and colums']);
assert(all(size(Q2) == [nu nu]),['Q2 must be a matrix with nu = ' num2str(nu) ' rows and colums']); 


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

reg_c = ss([L Lr]);
reg_c.inputgroup.x = 1:(nx+nxi);
reg_c.inputgroup.r = (nx+nxi+1):(nx+nxi+nr);
reg_c.outputgroup.u = 1:nu;


