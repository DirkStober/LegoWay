
cs = getDragsterSS();
Ts = 0.05;
ds = c2d(cs,Ts);                                        
%% Regulator design -------------------------------------------------------

M = 50;

Q1 = [10 0; 0 0.001];
Q2 = 10;

u_constr = [-10 10];
x_constr = [0 10; -10 10];

reg = mpc_reg(ds, M, Q1, Q2, u_constr, x_constr);
%%
nx = 2;
nu = 1;

r = [0; 0];
x = [0; zeros(M*nu,1)];
x0 = [0.1; 0];
y = x0;
fh =  reg.userdata.f;

[x t] = fh(x,[y; r]);

lsim(ds('y','u'),x,0:Ts:M*Ts, x0)