% HANDLE TO FUNCTION DESCRIBING THE NONLINEAR SYSTEM
%
% Description:
%   h = get_nlin_handle(c) returns a function handle to the m-file that 
%   describes the nonlinear system for the robot.The intended use for this 
%   handle is as input argument to ode45, wich is used for simulation.
%   See matlab documentation on ode45 for more information.
%
% Example:
%   c = constants()
%   h = get_nlin_handle(c);
%   returns a function handle that could be used as input argument for ode45.
%
% See also: -

function h = get_hipster_fh()  

Const = hipster_constants();

% System dimensions
ny = 3;            
nx = 6;
nw = 2;

% Load needed constants
mw  = Const.mw;     % wheel mass
mb  = Const.mb;     % body mass

R   = Const.R;      % wheel radius
W   = Const.W;      % half body width
L   = Const.L;      % length from wheel axle to center of mass

Iw  = Const.Iw;     % wheel moment of inertia
Ij  = Const.Ij;     % jaw moment of inertia
Ip  = Const.Ip;     % pitch moment of inertia
Ixx = Const.Ixx;

Jm = Const.Jm;      % tröghetsmoment för motorn

g  = Const.g;       % earth gravitation 

mc1 = Const.mc1;    % motor constant 1 = Bm + Kt*Kb/Ra;
mc2 = Const.mc2;    % motor constant 2 = Kt/Ra; 

noise      = randn(nw, 10000);
counter    = 0;

% Memory allocation for speed
Ainv = zeros(3);
B    = zeros(3,1);
C    = zeros(3,2);
res1 = zeros(3,1);
res2 = zeros(3,1); 
res3 = zeros(3,1);
res4 = zeros(4,1);
dy   = zeros(13,1);
pn   = zeros(nw,1);
h = @nlin_sys; 

% Matrix C, see documentation.
C(1,1) = mc2/R;       C(1,2) = C(1,1);
C(2,1) = mc2*W/R;     C(2,2) = -C(2,1);
C(3,1) = -mc2;        C(3,2) = C(3,1);

pn = ones(nw,1);

    % function n_lin_sys gives the nonlinear first order system describing
    % the robot.
    %
    % y = [x, phi, psi, x_dot, phi_dot, psi_dot, Vl, Vr, w1, w2]
    %
    % is the vector containing the variables that must be saved between
    % calls. 
    
    function ddy = nlin_sys(t, y)
        
        % Matrix A, see documentation
        a11 = mb + 2*(mw + (Jm + Iw)/R^2); 
        a12 = 0;
        a13 = mb*L*cos(y(3))-2*Jm/R;
        
        a21 = 0;
        a22 = mb*L^2*sin(y(3))^2 + 2*(mw + (Iw + Jm)/R^2)*W^2 + Ij*cos(y(3))^2 + Ixx*sin(y(3)^2);
        a23 = 0;
        
        a31 = mb*L*cos(y(3)) - 2*Jm/R;
        a32 = 0;
        a33 = mb*L^2 + Ip + 2*Jm;

        % General formula for the inverse of a 3*3 matrix ---------------
        den  = (a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 ...
                                            + a13*a21*a32 - a13*a22*a31);
        
        Ainv(1,1) =  (a22*a33 - a23*a32)/den;
        Ainv(1,2) =  (a13*a32 - a12*a33)/den;
        Ainv(1,3) =  (a12*a23 - a13*a22)/den;
        Ainv(2,1) =  (a23*a31 - a21*a33)/den;
        Ainv(2,2) =  (a11*a33 - a13*a31)/den;
        Ainv(2,3) =  (a13*a21 - a11*a23)/den;
        Ainv(3,1) =  (a21*a32 - a22*a31)/den;
        Ainv(3,2) =  (a12*a31 - a11*a32)/den;
        Ainv(3,3) =  (a11*a22 - a12*a21)/den;

        %----------------------------------------------------------------
        
        
        % Matrix B, see documentation.
        B(1) = 2/R*mc1*(y(4)/R - y(6)) - mb*L*sin(y(3))*y(6)^2;

        B(2) = (2*(mb*L^2 + Ixx - Ij)*cos(y(3))*sin(y(3))*y(6) ...
             + 2*W^2/R^2*mc1)*y(5);

        B(3) = 2*mc1*(-y(4)/R + y(6)) ...
             - (mb*L^2 + Ixx - Ij)*sin(y(3))*cos(y(3))*y(5)^2 ...
             - mb*L*g*sin(y(3));

        % Calculation of C*[y(7); y(8)], optimized for speed.
        res1(1) = C(1,1)*y(7) + C(1,2)*y(8); 
        res1(2) = C(2,1)*y(7) + C(2,2)*y(8); 
        res1(3) = C(3,1)*y(7) + C(3,2)*y(8);  

%         counter = mod(counter,10000) + 1;
%         counter  = counter + 1;
%         if(t == 0)
%             pn = ones(nw,1);
%         else
%             pn = noise(:, mod(ceil(t*10000),10000)+1);
%         end
        
        

        % first three entries of LHS
        dy(1) = y(4);
        dy(2) = y(5);
        dy(3) = y(6);

        res2  = Ainv*(res1 - B);
        
        res3(1) = pn(1)*C(1,1)*y(9) + pn(2)*C(1,2)*y(10);
        res3(2) = pn(1)*C(2,1)*y(9) + pn(2)*C(2,2)*y(10);
        res3(3) = pn(1)*C(3,1)*y(9) + pn(2)*C(3,2)*y(10);
        
        res4 = Ainv*res3;
        % last three entries of LHS
        dy(4) = res2(1) + res4(1);
        dy(5) = res2(2) + res4(2);
        dy(6) = res2(3) + res4(3);
        
        % Input voltages are constant over the sampling period
        dy(7) = 0;
        dy(8) = 0;
        dy(9) = 0;
        dy(10) = 0;
        ddy = dy;
    end
end
    

  
