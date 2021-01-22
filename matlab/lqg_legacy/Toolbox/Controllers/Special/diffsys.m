% A differentiating system on state space form
%
% y = s*u/(alpha*s + 1)
%
% alpha, is the low pass filter parameter. Half gain is located at
% w = 1/alpha
%

function dsys = diffsys(alpha, N)

if nargin < 2
    N = 1;
else
    if length(alpha) == 1
        alpha = alpha*ones(N,1);
    end
end

dsys = [];
for i = 1:N
    A = -1/alpha(i);
    B = 1/alpha(i);
    C = -1/alpha(i);
    D = 1/alpha(i);
    tempsys = ss(A,B,C,D);
    dsys = append(tempsys,dsys);
end
    
    
    
    
    
        