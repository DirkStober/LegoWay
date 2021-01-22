function [x lambda] = newt_step(x, grad, hess, A)

if nargin < 4
    A = [];
end

ma = size(A,1);
KKT_mat = [hess A.'; A zeros(ma)];
KKT_lhs = [-grad; zeros(ma,1)];
if cond(KKT_mat) < 1E10
    dx = KKT_mat\KKT_lhs;   
    x = x + dx(1:end-ma);
    lambda = dx(1:end-ma).'*hess*dx(1:end-ma);
else
    lambda = 0;
end
