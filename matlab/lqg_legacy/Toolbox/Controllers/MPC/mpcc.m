function [x, u] = step(x,u)       
        la = 1;
        r = repmat(u(ref_ix),M,1);
        x0 = u(x0_ix);
        u0 = x(1:nu);
        x = x(nu+1:end);
        eps = 1E-8;
        k = 3;
        while la > eps
            k = k*1.1;
            gr = g(x,x0,u0,r,k);
            he = h(x,x0,k);
            [x, la] = newt_step(x, gr, he);
        end
        
        x = [x; x(end-nu+1:end)];
        u = x(1:nu);        
end


function [x lambda] = newt_step(x, grad, hess, A)

    if nargin < 4
        A = [];
    end

    ma = size(A,1);
    KKT_mat = [hess A.'; A zeros(ma)];
    KKT_lhs = [-grad; zeros(ma,1)];
    dx = KKT_mat\KKT_lhs;

    x = x + dx(1:end-ma);

    lambda = dx(1:end-ma).'*hess*dx(1:end-ma);
end


function fh = objectiveFunction(sys, M, Q1, Q2, u_cstr, x_cstr)

    sys = sys('y','u');

    n = size(sys.A,1);
    nu = length(sys.inputgroup.u);
    A = eye(n*(M+1));
    E = eye(nu*(M+1));

    for m=1:M
        rows = n*m+1:n*m+n;
        cols = n*(m-1)+1:n*(m-1)+n;
        A(rows,cols) = -sys.A;

        rows = nu*m+1:nu*m+nu;
        cols = nu*(m-1)+1:nu*(m-1)+nu;
        E(rows,cols) = -eye(nu);
    end

    B = kron(eye(M), sys.B);

    C = inv(A);
    C22 = C(n+1:end, n+1:end)*B;
    C21 = C(n+1:end, 1:n);

    E22 = E(nu+1:end, nu+1:end);
    E21 = E(nu+1:end, 1:nu);

    Q1p = kron(eye(M),Q1);
    Q2p = kron(eye(M),Q2);

    Q = C22.'*Q1p*C22 + E22.'*Q2p*E22;
    b = -2*C22.'*Q1p;
    d = 2*C22.'*Q1p*C21;
    e = 2*E22.'*Q2p*E21;

    fh = {@f, @g, @h}; 

    u_ub = repmat(u_cstr(:,2),M,1);
    u_lb = repmat(u_cstr(:,1),M,1);

    x_ub = repmat(x_cstr(:,2),M,1);
    x_lb = repmat(x_cstr(:,1),M,1);         

    % objective function
    function y = f(x,x0,u0,r,k)
        y = x.'*Q*x + x.'*b*r + x.'*d*x0 + x.'*e*u0 +  sum(exp(k*(x-u_ub))) ...
            + sum(exp(k*(-x+u_lb))) + sum(exp(k*(C22*x-x_ub))) ...
            + sum(exp(k*(-C22*x+x_lb)));
    end

    % gradientb*r
    function y = g(x,x0,u0,r,k)
       y = 2*Q*x + b*r  + d*x0 + e*u0 + k*exp(k*(x-u_ub)) ...
            - k*exp(k*(-x+u_lb)) + k*C22.'*exp(k*(C22*x+C21*x0-x_ub)) ...
            - k*C22.'*exp(k*(-C22*x-C21*x0+x_lb)); 
    end

    % hessian
    function y = h(x,x0,k)
       y = 2*Q + k^2*diag(exp(k*(x-u_ub))) ...
            + k^2*diag(exp(k*(-x+u_lb))) + k^2*C22.'*diag(exp(k*(C22*x+C21*x0-x_ub)))*C22 ...
            + k^2*C22.'*diag(exp(k*(-C22*x-C21*x0+x_lb)))*C22;
    end
end
