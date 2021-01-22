% Integrating system on state space form
%
% y = u/s

function isys = intsys(N)

if nargin < 1
    N = 1;
end

A = 0;
B = 1;
C = 1;
D = 0;

isys = [];
for i=1:N
    tempsys = ss(A,B,C,D);
    isys = append(tempsys,isys);
end

