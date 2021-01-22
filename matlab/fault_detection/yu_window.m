function yu_ss = yu_window(ns,Ts)
% yu_window creates a state space representation to create a vector
% ns: residual rank 
% Ts: discrete time interval
% Y(k) = [ y(k-ns) ... y(k)]
% U(k) = [ u(k-ns) ... u(k)] 
% input = [y(k) u(k)]
% output = [Y(k) U(k)]

us = 2;
ys = 3;
ymax = (ys+us)*(ns);
r_A  = [zeros(ymax,ys),[diag(ones(1,ys*(ns-1)));zeros(ymax-(ys*(ns-1)),ys*(ns-1))],...
		zeros(ymax,us),[zeros(ys*(ns),us*(ns-1));diag(ones(1,us*(ns-1)));zeros(us,us*(ns-1))]];
r_B = [zeros(ys*(ns-1),ys+us);[diag(ones(1,ys)),zeros(ys,us)];zeros(us*(ns-1),ys+us);...
		[zeros(us,ys),diag(ones(1,us))]];

ymax = (ys +us)*(ns+1);
r_C = [[diag(ones(1,ns*ys));zeros(ymax-ns*ys,ns*ys)],...
    [zeros(ymax-(ns+1)*us,ns*us);diag(ones(1,ns*us));zeros(us,ns*us)]];
r_D = [zeros(ys*ns,ys+us);[diag(ones(1,ys)),zeros(ys,us)];...
    zeros(us*ns,ys+us);[zeros(us,ys),diag(ones(1,us))]];
 
yu_ss = ss(r_A,r_B,r_C,r_D,Ts);

end

