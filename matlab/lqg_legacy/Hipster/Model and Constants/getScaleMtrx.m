%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getScaleMtrx returns two scaling matrices, one to scale the input u with
% and another to scale the states with. The input states specifies wich 
% states the user would like to get a scaling matrice for 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Du Dz] = getScaleMtrx(sys)

M = sys('z',:).C;
zi =  mod(find(M.'),6);

u_max           = 8;

x_max           = 0.05;
jaw_max         = deg2rad(10);
pitch_max       = deg2rad(5);
vel_max         = 0.3;
pitch_vel_max   = deg2rad(10);
jaw_vel_max     = deg2rad(10);

max_vec = [x_max jaw_max pitch_max vel_max pitch_vel_max jaw_vel_max];

Du = u_max;
Dz = diag(max_vec(zi));
