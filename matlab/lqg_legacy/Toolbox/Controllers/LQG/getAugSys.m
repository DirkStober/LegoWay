function sys_aug = getAugSys(sys, M)

delta = 1E-4;

nx  = size(sys.A,1);
nxi = size(M,1);

Ai = -delta*eye(nxi);
Bi = -eye(nxi);
Ci = eye(nxi);
Di = 0;

sys_int = ss(Ai,Bi,Ci,Di);
sys_int.inputname = strseq('r',1:nxi);
sys_int.inputgroup.r = 1:nxi;
sys_int.statename = strseq('xi',1:nxi);
sys_int.outputgroup.xi = 1:nxi;

sys_aug = append(sys,sys_int);
sys_aug.A(nx+1:nx+nxi,1:nx) = M;

% A_aug   = [A, zeros(nx, nxi); M, -eye(nxi)*delta];
% B_aug   = [B; zeros(nxi, nu)];
% C_aug   = [M zeros(nxi) ; zeros(nxi,nx) eye(nxi)];
% sys_aug = ss(A_aug, B_aug, C_aug, 0);

