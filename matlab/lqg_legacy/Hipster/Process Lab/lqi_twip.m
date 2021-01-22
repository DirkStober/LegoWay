% reg = lqi_twip(Q1,Q2,Qe,R1,R2)
% 
% Input     Type            Description           
% Q1        2*2 Matrix      Penalty matrix for the performance signal z
% Q2        2*2 Matrix      Penalty matrix for the input signal u
% Qe        2*2 Matrix      Penalty matrix for the integrated control error
% R1        2*2 Matrix      Process noise covariance matrix. Used by Kalman
%                           filter
% R2        3*3 Matrix      Measurement noise covariance matrix. Used by
%                           Kalman filter.
%
%
% Output    Type            Description
% reg       LTI object      An lqq controller with integral action. reg
%                           can be used as input to sim_twip, or executed
%                           on the real system using the twip_gui.
% 

function reg = lqi_twip(Q1,Q2,Qi,R1,R2)

if nargin ~= 5
    error('myApp:argChk', ['Wrong number of input arguments see help below \n\n ' help('lqi_twip')]);
end


sys = getHipsterSS();

nz = length(sys.outputgroup.z);
nu = length(sys.inputgroup.u);
nw = length(sys.inputgroup.w);
nv = length(sys.inputgroup.v);
ni = nz;

assert(size(Q1,1) == nz && size(Q1,2) == nz,['Q1 must be a ' num2str(nz) '*' num2str(nz) ' matrix']);
assert(size(Q2,1) == nu && size(Q2,2) == nu,['Q2 must be a ' num2str(nu) '*' num2str(nu) ' matrix']);
assert(size(R1,1) == nw && size(R1,2) == nw,['R1 must be a ' num2str(nw) '*' num2str(nw) ' matrix']);
assert(size(R2,1) == nv && size(R2,2) == nv, ['R2 must be a ' num2str(nv) '*' num2str(nv) ' matrix']);
assert(size(Qi,1) == ni && size(Qi,2) == ni,['Qe must be a ' num2str(ni) '*' num2str(ni) ' matrix']);

% Load state space model 
cs = getHipsterSS();

% Augment state and integrated state penalty matrices
Q1 = blkdiag(Q1,Qi);

% Sampling period
Ts = 5E-3;     

% LQG servo controller with integral action
[~, reg_d] = lqgi_servo(cs, R1, R2, Q1, Q2, Ts, true);

% Specify connections between outputs, inputs, sensors and actuators
reg = annotateReg(reg_d);

end