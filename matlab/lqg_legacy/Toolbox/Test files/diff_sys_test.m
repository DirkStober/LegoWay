
n = 1;
pass_ix = 1;
diff_ix = 1;
int_ix = 1;

sys = diff_int_obs(n, pass_ix, diff_ix, int_ix);

N_ITER = 100;
x = linspace(0,2*pi,N_ITER);
u = cos(x);
t = x ;% (0:N_ITER-1)*Ts;
lsim(sys,u,t)

