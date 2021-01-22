sys = ss([0.6 .7; 0.1 0.5], [1 4; 2 0], [eye(2); eye(2)],0, 1);

sys.inputgroup.u = 1:2;
sys.inputname = strseq('u',1:2);

sys.outputgroup.y=3:4;
sys.outputgroup.z=1:2;

sys.outputname = [strseq('z',1:2); strseq('y',1:2)];
sys.statename = strseq('x',1:2);

%%
nx = 2;
nu = 2;

M = 10;

Q1 = eye(2);
Q2 = eye(2);

u_constr = [-2 5; -2 5];
x_constr = [-inf 2; -inf 6];

reg = mpc_reg(sys, M, Q1, Q2, u_constr, x_constr);
%%

r = 3*ones(nx,1);
x = zeros(M*nu,1);
x0 = [0; 0];
y = x0;
 

[x t] = reg.userdata.f(x,[y; r]);

u = reshape( x, nu, M);
lsim(sys('y','u'),u,0:(M-1), x0)
