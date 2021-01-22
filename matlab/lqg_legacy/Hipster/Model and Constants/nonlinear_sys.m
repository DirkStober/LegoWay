function dy = nonlinear_sys(t, y)

dy = [0 0 0 0 0 0 0 0 0 0]';

stdvPn = 0.0*[0 0 0 1 1 1]';

Ts  = 0.005;

mw  = 0.0332;   %wheel mass
mb  = 0.58715;  %body mass

R   = 0.04;     %wheel radius
W   = 0.16/2;   %half body width
L   = 0.144/2;  %length from wheel axle to center of mass
bd  = 0.04;     %body depth

Iw  = mw*R^2/2; %wheel moment of inertia
Ij  = mb*((2*W)^2 + bd^2)/12 + 2*(Iw/2 + mw*W^2); %jaw moment of inertia
Ip  = mb*((2*L)^2 + bd^2)/12; %pitch moment of inertia
Izz = mb*((2*W)^2 + bd^2)/12;
Ixx = mb*((2*W)^2 + (2*L)^2)/12;

Jm = 1E-5;      % tröghetsmoment för motorn
Bm = 1.1278E-3; % viskositetskonstant
Kt = 0.31739;   % proportionalitetskonstant från 'i' till 'tau'.
Kb = 0.46839;   % proportionalitetskonstant från 'theta_dot' till 'eb'.
Ra = 6.69;      % inre resistans

g  = 9.82;       %earth gravitation 

mc1 = 8.5007e-004;  % motor constant 1 = Bm + Kt*Kb/Ra;
mc2 = 0.0018;       % motor constant 2 = Kt/Ra; 

Ainv = zeros(3);

deadzone_deg = 3; %Deadzone = +- 3 deg
I_gear = 1E-5;


% Glitch fix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modified "constants" taking the deadzone in the motors in consideration
dy(9)  = -(1/R*y(4) + W/R*y(5) -1*y(6) - Kt/(Ra*I_gear)*y(8));

if(abs(y(9)) >= pi/180*(deadzone_deg)) 
    d = 1;
    if(y(9)*dy(9) > 0)
        dy(9) = 0;
    end
else
    d = 1;%0;
end

dy(10) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A1 = mb + 2*(mw + (Jm + Iw)/R^2);
% A2 = 2/R^2 * (Bm + Kt*Kb/Ra);
% A3 = mb*L*cos(y(3))-2*Jm/R;
% A4 = mb*L*sin(y(3));
% A5 = Kt/(R*Ra);
% A6 = 2*(Bm + Kt*Kb/Ra)/R;
% 
% B1 = mb*L*cos(y(3)) - 2*Jm/R;
% B2 = 2/R * (Bm + Kt*Kb/Ra);
% B3 = mb*L^2 + Ip + 2*Jm;
% B4 = (mb*L^2 + Ixx - Ij)*sin(y(3))*cos(y(3));
% B5 = mb*L*g*sin(y(3));
% B6 = Kt/Ra;
% B7 = 2*(Bm + Kt*Kb/Ra);
% 
% C1 = mb*L^2*sin(y(3))^2 + 2*(mw + (Iw + Jm)/R^2)*W^2 + Ij*cos(y(3))^2 + Ixx*sin(y(3));
% C2 = 2*(mb*L^2 + Ixx - Ij)*cos(y(3))*sin(y(3));
% C3 = 2*W^2/R^2 * (Bm + Kt*Kb/Ra);
% C4 = W*Kt/(R*Ra);


% den = A1*B3-A3*B1;

a11 = mb + 2*(mw + (d*Jm + Iw)/R^2); a12 = 0;                                                                                    a13 = mb*L*cos(y(3))-2*Jm/R;
a21 = 0;                             a22 = mb*L^2*sin(y(3))^2 + 2*(mw + (Iw + d*Jm)/R^2)*W^2 + Ij*cos(y(3))^2 + Ixx*sin(y(3)^2); a23 = 0;
a31 = mb*L*cos(y(3)) - d*2*Jm/R;     a32 = 0;                                                                                    a33 = mb*L^2 + Ip + d*2*Jm;

%A = [a11 a12 a13; a21 a22 a23; a31 a32 a33];

% General formula for the inverse of a 3*3 matrix ---------------
% Ainv =  [a22*a33 - a23*a32, a13*a32 - a12*a33, a12*a23 - a13*a22;
%          a23*a31 - a21*a33, a11*a33 - a13*a31, a13*a21 - a11*a23;
%          a21*a32 - a22*a31, a12*a31 - a11*a32, a11*a22 - a12*a21];

Ainv(1,1) =  a22*a33 - a23*a32;
Ainv(1,2) =  a13*a32 - a12*a33;
Ainv(1,3) =  a12*a23 - a13*a22;
Ainv(2,1) =  a23*a31 - a21*a33;
Ainv(2,2) =  a11*a33 - a13*a31;
Ainv(2,3) =  a13*a21 - a11*a23;
Ainv(3,1) =  a21*a32 - a22*a31;
Ainv(3,2) =  a12*a31 - a11*a32;
Ainv(3,3) =  a11*a22 - a12*a21;



den  = (a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);

Ainv = Ainv/den;
%----------------------------------------------------------------

b1 = d*2/R*mc1*(y(4)/R - y(6))...
     - mb*L*sin(y(3))*y(6)^2;

b2 = (2*(mb*L^2 + Ixx - Ij)*cos(y(3))*sin(y(3))*y(6) ...
     + d*2*W^2/R^2*mc1)*y(5);

b3 = d*2*mc1*(-y(4)/R + y(6)) ...
     - (mb*L^2 + Ixx - Ij)*sin(y(3))*cos(y(3))*y(5)^2 ...
     - mb*L*g*sin(y(3));

B = [b1; b2; b3];


e11 = mc2*d/R;    e12 = e11;
e21 = mc2*d*W/R;  e22 = -e21;
e31 = -mc2*d;     e32 = e31;

E = [e11 e12; e21 e22; e31 e32];


% dy(1) = y(4) + stdvPn(1)*randn();
% dy(2) = y(5) + stdvPn(2)*randn();
% dy(3) = y(6) + stdvPn(3)*randn(); 
% 
% dy(4)=-( (A2*B3+A3*B2)*y(4) - (A6*B3+A3*B7)*y(6) + A4*B3*y(6)^2 - A3*B4*y(5)^2 + A3*B5 - (A5*B3 + A3*B6)*(y(7) + y(8)))/den + stdvPn(4)*randn();
%     
% dy(5) = -( (C3 + C2*y(6))*y(5) + C4*(y(8) - y(7)))/C1 + stdvPn(5)*randn();
% 
% 
% 
% dy(6) = -( (A6*B1+A1*B7)*y(6) - (A1*B2+A2*B1)*y(4) + A4*B1*y(6)^2 - A1*B4*y(5)^2 - A1*B5 + (A5*B1 + A1*B6)*(d*y(7) + d*y(8)))/den + stdvPn(6)*randn();
% dy(7) = 0;
% dy(8) = 0;

dy(1:3) = [y(4); y(5); y(6)]; 
dy(4:6) = Ainv*(E*[y(7); y(8)] - B);
dy(7)   = 0;
dy(8)   = 0;
    

  
