sys = ss([0.5 0; 0 0.5], [1 0; 0 1], eye(2),0, 1);

nx = 2;
nu = 2;

M = 10;
Q1 = eye(2);
Q2 = 0.01*eye(2);
r = 5*ones(nx*(M+1),1);


u_constr = [-3 3;
             -3 3];
x_constr = [-inf 8;
            -inf 6];

fh = objectiveFunction(sys, M, Q1, Q2, r, u_constr, x_constr);

A = [eye(nu) zeros(nu, M*nu)];

x = [zeros(nu,1); zeros(M*nu,1)];
k = 3;

%% 
k = k*1.05
x = newt_step_2(x, fh{2}, fh{3},A,k)

%%

u = reshape(x,nu,M+1);
lsim(sys,u(:,2:end),0:(M-1), [0;0])
