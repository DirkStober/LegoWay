% Creates the closed loop system. For the closed loop system with plant sys
% feedback and kalman gain L and K respectively. And reference gain Lr. 

function sys_cl = ss_cl(sys,L,K,Lr)
    [A,B,C,D] = ssdata(sys);
    Ac = [A -B*L; zeros(size(A)) A-B*L-K*C];
    Bc = [B*Lr; B*Lr];
    Cc = C;
    Dc = D;
    sys_cl = ss(Ac,Bc,Cc,Dc);
end