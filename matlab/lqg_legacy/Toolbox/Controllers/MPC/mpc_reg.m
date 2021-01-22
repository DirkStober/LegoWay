function reg = mpc_reg(sys, M, Q1, Q2, u_constr, x_constr)

nx = size(sys.A,1);
nu = length(sys.inputgroup.u);
ny = length(sys.outputgroup.y);
nr = length(sys.outputgroup.z);

fh = objectiveFunction(sys, M, Q1, Q2, u_constr, x_constr);
g = fh{2};
h = fh{3};

A = sys('y','u').A;
B = sys('y','u').B;

reg = ss(zeros(nu*(M)), zeros(nu*(M), ny+nr), zeros(nu, nu*(M)), 0);

reg.InputGroup.y = 1:ny;
reg.InputGroup.r = ny+1:ny+nr;

reg.OutputGroup.u = 1:nu;

reg.StateName = strseq('u',0:nu*(M)-1);
reg.InputName = [sys.outputname(sys.outputgroup.y); sys.outputname(sys.outputgroup.z)];
reg.OutputName = [sys.inputname(sys.inputgroup.u)];

ref_ix = reg.InputGroup.r;
u_ix = reg.OutputGroup.u;
x0_ix = reg.InputGroup.y;

reg.userdata.f = @step;
reg.notes = 'MPC';

reg.Ts = sys.Ts;

    % Input x = [u0 u], u = [x0, ref]
    % Output x = [u0 ... u_M-1], u = u0
    function [x, u] = step(x,u)
        global k
        r = repmat(u(ref_ix),M,1);
        x0 = u(1:2);
        u0 = x(1:nu);
        x = [x(nu+1:end); x(end-nu+1:end)];
        eps = 1E-6;
        %k = 3;
        %k = 3;
        k = k*0.8;
        n_iter = 0;
        for i = 0:5
            k = k*1.1;
            la = 1;
            while la > eps
                gr = g(x,x0,u0,r,k);
                he = h(x,x0,k);
                [x, la] = newt_step(x, gr, he);
                n_iter = n_iter + 1;
            end
            if la == 0
                break;
            end
        end
        disp(n_iter);
        u = x(1:nu);        
    end
end