% reg = lq_twip(Q1,Q2)
% 
% Input     Type            Description           
% Q1        2*2 Matrix      Penalty matrix for the performance signal z
% Q2        2*2 Matrix      Penalty matrix for the input signal u
%
% Output    Type            Description
% reg       LTI object      An lq controller using G_{obs} as observer. reg
%                           can be simulated or executed
%                           on the real system using the twip_gui.
% 


function reg = lq_twip(Q1,Q2)

if nargin ~= 2
    error('myApp:argChk', ['Wrong number of input arguments see help below \n\n ' help('lq_twip')]);
end

sys = getHipsterSS();
sys_zu = sys('z','u');

nz = size(sys_zu.C,1);
nu = size(sys_zu.B,2);

assert(size(Q1,1) == nz && size(Q1,2) == nz,['Q1 must be a ' num2str(nz) '*' num2str(nz) ' matrix']);
assert(size(Q2,1) == nu && size(Q2,2) == nu,['Q2 must be a ' num2str(nu) '*' num2str(nu) ' matrix']);

th = 1E4;

if Q2(1,1) == Q2(2,2) && Q1(1,1)/Q1(2,2) >= th
    warning(['The ratio q11/rho is too high. This can potentially degrade' ...
            ' the performace of the closed loop system']);
end

% Sampling period
Ts = 5E-3;       

% Controller
reg = lq_hipster(Q1,Q2,Ts);

reg = annotateReg(reg);

end