% returns matrix T: r = T*rC 
% it returns optimization for two faults 
% if only optimized for one fault use H_f as if the fault was applied twice
% t_in is a starting T for the optimization
function T = optim(c,H_f,H_d,vi_s,t_in)
c1 = c(1);
c2 = c(2);
if nargin < 5
	t0 = struct;
	t0.ti = ones(1,15);
	
	t0.ti = [-1.0000    1.0000    1.0000   -1.0000    1.0000    1.0000   -1.0000    1.0000,...
		1.0000   -1.0000    1.0000    0.5420   -1.0000    1.0000   -1.0000];
	t1.ti = [1.0000   -1.0000    1.0000    1.0000   -1.0000    1.0000    1.0000   -1.0000,...
		1.0000    1.0000   -1.0000    0.6354    1.0000   -1.0000   -1.0000];
else
	t0 = t_in;
end	

f0 = zeros(size(H_f,2),1);
f1 = zeros(size(H_f,2),1);
d0 = ones(size(H_d,2),1);
for i = 1 : size(H_f,2)/2
	f0(i*2 -1) =  1;
	f1(i*2) =  1;
	
end

ti = optimvar('ti',1,15,'Type','continuous',...
	'LowerBound',-1,'UpperBound',1);

prob = optimproblem('ObjectiveSense','minimize'); 

T = [];
prob.Objective =  c1 *1/((ti*vi_s*H_f*f0)^2) + c2*((ti*vi_s*H_d*d0)^2);
sol  =solve(prob,t0);
T = [T;sol.ti];
prob.Objective =  c1 * 1/((ti*vi_s*H_f*f1)^2) + c2*(ti*vi_s*H_d*d0)^2;
sol  =solve(prob,t1);
T = [T;sol.ti];
end
