
Bm    = 1.1278E-3;    % viskositetskonstant
Kt    = 0.31739;      % proportionalitetskonstant från 'i' till 'tau'.
Kb    = 0.46839;      % proportionalitetskonstant från 'theta_dot' till 'eb'. 
Ra    = 6.69;         % inre resistans

mass = 0.072;
r    = 0.04;
%I    = 100*mass*r^2/2;
I    = 2*0.12*0.14^2;

t = Ts*(0:N-1)';
u_sim = [t u_sim]; 
noise = [t deg2rad(0.5)*randn(N,1)];

mc1 = Bm + Kt*Kb/Ra; 
mc2 = Kt/Ra; 

