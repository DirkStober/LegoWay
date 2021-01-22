function [reg_d, reg_c] = ssFdbkRegInt(sys, K, L, Ts)

A_tilde = (sys.A - sys.B*K(1:3) - L*sys.C);

A_reg = [A_tilde -sys.B*K(4); 0 0 0 0];
B_reg = [L;1];
C_reg = -K;
D_reg = 0;

reg_c = ss(A_reg, [zeros(4,1) B_reg], C_reg, [zeros(1,1) D_reg]);
%reg_c = ss(A_reg, B_reg, C_reg, D_reg);
reg_d = c2d(reg_c, Ts);

%reg_c = setNameAndGroups(reg_c,sys_aug,'LQG');
%reg_d = setNameAndGroups(reg_d,sys_aug,'LQG');

end