function [reg_d, reg_c] = ssFdbkReg(sys, L, K, Ts)

A_reg = (sys.A - sys.B*K - L*sys('y',:).C);
B_reg = L;
C_reg = -K;
D_reg = 0;

nx = size(A_reg,1);
ny = size(sys('y',:),1);

reg_c = ss(A_reg, [zeros(nx,ny) B_reg], C_reg, [zeros(ny,ny) D_reg]);
reg_d = c2d(reg_c, Ts);

reg_c = setNameAndGroups(reg_c,sys,'LQG');
reg_d = setNameAndGroups(reg_d,sys,'LQG');

end