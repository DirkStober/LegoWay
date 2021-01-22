% A differentiating and integrating observer
%
%
% n - number of inputs
% pass_ix - indexes for the inputs that shall only be passed to the output
% diff_ix - indexes for the inputs that shall be differentiated
% int_ix  - indexes for the inputs that shall be integrated
% 
% output of system is given by 
% [out(pass_ix); out(diff_ix); out(int_ix)]


function sys = diff_int_obs(n, pass_ix, diff_ix, int_ix, alpha)

if nargin < 5
    alpha = 1;
end

pass_ix = pass_ix(:);
diff_ix = diff_ix(:);
int_ix = int_ix(:);

np = length(pass_ix);
nd = length(diff_ix);
ni = length(int_ix);

ny = np + nd + ni;
nu = n;

inpsys = eye(n);

psys = eye(np);
dsys = diffsys(alpha,nd);
isys = intsys(ni);
 
blksys = append(inpsys, psys, dsys, isys);
connections = [(n+1:np+n)' pass_ix;
               (n+np+1:np+nd+n)' diff_ix;
               (n+np+nd+1:n+np+nd+ni)' int_ix];
inputs = 1:nu;
outputs = n+1:n+ny;

sys = connect(blksys,connections,inputs, outputs);
end