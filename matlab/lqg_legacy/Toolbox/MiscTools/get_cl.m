% Returns transferfunction for system sys, with
%  
% Inputgroups
%   u = inputsignal
%   w = processnoise
% 
% Outputgroups
%   y = measured signal
%   z = performance signal
%
%
% Controlled by controller reg with
%
% Inputgroups
%   r = reference signal
%   y = measured signal
%
%  Outputgroups
%   u = controllsignal
%
% The returned closed loop system will be given by
%
%   w
%   |
%   .--->o-----o-----> z
%        | Sys |
%   .--->o-----o---.-> y
%  u|              |  
%   .----o-----o<--.
%        | Reg |
%   r -->o-----o
%
% With
% 
% Inputgroups
%   r = reference signal
%   w = process noise
%
% Outputgroups
%   y = measured signal  
%   z = performance signal
%

function cl_sys = get_cl(sys, reg)
checkSys(sys);
checkReg(reg);

% Appended system
blksys = append(sys,reg);

% Connection for sys output y to reg input y
q1 = [blksys.inputgroup.y(:) blksys.outputgroup.y(:)];
% Connection for reg output u to sys input u
q2 = [blksys.inputgroup.u(:) blksys.outputgroup.u(:)];

% Connection matrix
Q = [q1; q2];

% Closed loop inputs
clin = [blksys.inputgroup.r, blksys.inputgroup.w];

% Closed loop outputs
clout = [blksys.outputgroup.z, blksys.outputgroup.y];
cl_sys = connect(blksys,Q, clin, clout);

% cl_sys.A(cl_sys.A < 1E-15) = 0;
% cl_sys.B(cl_sys.B < 1E-15) = 0;
% cl_sys.C(cl_sys.C < 1E-15) = 0;
% cl_sys.D(cl_sys.D < 1E-15) = 0;
end
