% Function pidreg
%
% Creates a pid reglator
%
% U(s) = (Kp + Ki/s +Kd*s/(alpha*s + 1))*E(s)
%
% Kp, Ki, Kd are the constants for the proportional, integrating
% and differentiating part respectively. 
% Alpha is the low pass filter parameter for the differentiating part.
%
% Function returns both the continous and discrete LTI objects, where
% the sampling period Ts is used for the discrete system.

function [pid_c pid_d] = pidreg(Kp, Ki, Kd, alpha, Ts)

if(Kd == 0)
    Kd = 0.00001;
end

A = [0 0; 0 -1/(Kd*alpha)];
B = [Ki; 1/(Kd*alpha)]*[1 -1];
C = [1 -1/alpha];
D = (Kp + 1/alpha)*[1 -1];

% Fp = tf(Kp, 1);
% Fi = tf(Ki,[1 0]);
% Fd = tf([Kd 0], [alpha*Kd 1]);
% 
% Fc = Fp + Fi + Fd;
% Fd = c2d(Fc, Ts);
%[A,B,C,D] = ssdata(Fd);

pid_c = ss(A,B,C,D);
pid_c.inputgroup.y = 2;
pid_c.inputgroup.r = 1;
pid_c.outputgroup.u = 1;
pid_c.InputName = {'ref','y'};
pid_c.StateName = {'xi','xd'};
pid_c.OutputName = {'u'};
pid_d = c2d(pid_c, Ts);
pid_d.notes = 'PID';

