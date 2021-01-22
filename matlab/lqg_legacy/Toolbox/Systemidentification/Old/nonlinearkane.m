function [dx,y] = nonlinearkane(t, x, u, Iw, FileArgument)
%function [dx,y] = nonlinearkane(t, x, u, L, Iw, Ij, Ip, Jm, Kt, Kb, Ra, Bm, FileArgument)

addpath ../Ny
Const = constants();

Ip = Const.Ip;
Jm = Const.Jm;
Kt = Const.Kt;
Kb = Const.Kb;
Ra = Const.Ra;
Bm = Const.Bm;
L = Const.L;
Ij = Const.Ij;

phi = x(2);
psi = x(3);
x_dot = x(4);
phi_dot = x(5);
psi_dot = x(6);

vr = u(1);
vl = u(2);

A1 = 2*Const.mw + Const.mb + 2*Jm/Const.R^2 + 2*Const.Iw/Const.R^2;
A2 = 2/Const.R^2 * (Bm + Kt*Kb/Ra);
A3 = Const.mb*L*cos(psi);
A4 = Const.mb*L*sin(psi);
A5 = Kt/(Const.R*Ra);

B1 = Const.mb*L*cos(psi) - 2*Jm/Const.R;
B2 = 2/Const.R * (Bm + Kt*Kb/Ra);
B3 = Const.mb*L^2 + Ip;
B4 = Const.mb*L^2*sin(psi)*cos(psi);
B5 = Const.mb*L*Const.g*sin(psi);
B6 = Kt/Ra;

C1 = (2*Const.W^2 + Const.R^2/2)*Const.mw + Const.mb*L^2*sin(psi)^2 + Ij...
        + 2*Jm*Const.W^2/Const.R^2 + 2*Const.W^2*Iw/Const.R^2;
C2 = Const.mb*L^2*sin(psi)*cos(psi);
C3 = 2*Const.W^2/Const.R^2 * (Bm + Kt*Kb/Ra);
C4 = Const.W*Kt/(Const.R*Ra);

dx = [x_dot;
    phi_dot;
    psi_dot;
    B3/(A1*B3-A3*B1) * (-(A2 + A3*B2/B3)*x_dot + (A3*B4/B3 - A4)*psi_dot^2 ...
        -A4*phi_dot^2 - (A3*B6/B3 + A5)*(vr+vl));
    1/C1*(-C2*psi_dot*phi_dot - C3*phi_dot + C4*(vr-vl));
    -A1/(B3*A1-B1*A3) * ( (B1*A2/A1 + B2)*x_dot + (B1*A4/A1 - B4)*psi_dot^2 ...
        +B1*A4/A1*phi_dot^2 - B5 + (B1*A5/A1 + B6)*(vr+vl) )];
    
y = [1/Const.R Const.W/Const.R 0 0 0 0;
     1/Const.R -Const.W/Const.R 0 0 0 0;
      0 0 0 0 0 1] * x;
  
  %y