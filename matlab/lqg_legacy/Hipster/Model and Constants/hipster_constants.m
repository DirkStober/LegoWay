% CONSTANTS FOR MATHEMATICAL MODEL OF ROBOT
%
% Description:
%   c = constants() returns a struct with all the constants needed for the 
%   mathematical model of the robot. The constants included are
%   
%   --Wheel constants ------------------------
%       *mw     :wheel mass
%       *R      :wheel radius
%       *W      :wheel axis half width
%       *Iw     :wheel moment of inertia around axis
%
%  --Body constants --------------------------
%       *mb     :body mass
%       *Ip     :pitch moment of inertia
%       *Ij     :jaw moment of inertia
%       *Ixx    :tilt moment of inertia
%       *L      :Distance from wheel axis to CoG for body
%
%  --Motor constants -------------------------
%       *Jm     :shaft moment of inertia
%       *Bm     :viscous friction constant
%       *Kt     :current to torque proportionality constant
%       *Kb     :back EMF constant
%       *Ra     :internal resitivity
%       *mc1    :motor constant 1 = (Bm + KtKb/Ra)
%       *mc2    :motor constant 2 = Kt/Ra
%
%   --Other constants ------------------------
%       *g      :earth gravity
%       *
% Example:
%   c = constants();
%   I = c.Ixx;
%   will assign I the value of Ixx
%
% See also: -


function Const = hipster_constants()

%--------------------------------------------------------------------------
% Wheel constants
%--------------------------------------------------------------------------
Const.mw = 0.0332;   % wheel mass
Const.R  = 0.04;     % wheel radius
Const.W  = 0.16/2;   % halfwidth wheel axis
Const.Iw = Const.mw*Const.R^2/2; %wheel moment of inertia


% A test to move the body higher with a length of
shift = 0.0;


%--------------------------------------------------------------------------
% Body constants
%--------------------------------------------------------------------------

% Brick dimensions and weight
brick.mass      = 0.260;                        % mass in kg
brick.com       = [0, 0, 0];                    % center of mass in meters
brick.size      = [0.075, 0.115, 0.0475];       % widh, height and depth, in meters

motorMass       = 0.100;                        % motor mass in kg 

perOfMassUpper = 0.8;                           % 80 % of the motors total weight is located in the "upper" part

% Motor upper part
motorUpperLeft.mass  = motorMass*perOfMassUpper;% mass in kg
motorUpperLeft.com   = [0.0575,  -0.035-shift, 0];     % center of mass in meters
motorUpperLeft.size  = [0.04, 0.06, 0.05];      % widh, height and depth in meters

% Motor lower part
motorLowerLeft.mass  = motorMass*(1-perOfMassUpper);      % mass in kg
motorLowerLeft.com   = [0.0575, -0.08-shift, 0];      % center of mass in meters
motorLowerLeft.size  = [0.02, 0.05, 0.03];      % widh, height and depth in meters

% Motor right
motorUpperRight      = motorUpperLeft;          % motors are identical
motorUpperRight.com  = motorUpperLeft.com.*[-1, 1, 1]; % except for their x placement

motorLowerRight      = motorLowerLeft;          % motors are identical
motorLowerRight.com  = motorLowerLeft.com.*[-1, 1, 1]; % except for their x placement

% moment of inertia and COM for the body composed of brick and two motors
[Const.Ip, Const.Ij, Const.Ixx, COM] = ...
    getMomentOfInertia([brick, motorUpperLeft, motorLowerLeft, motorUpperRight, motorLowerRight]); 

% add wheels for jaw inertia
Const.Ij = Const.Ij + 2*(Const.Iw/2 + Const.mw*Const.W^2);

L1       = 0.11 + shift;     % Distance from com of brick and wheel axis in meters 
Const.mb = 0.58715;  % Body mass (includes all extra parts)
Const.L  = L1+COM(2);% Length from wheel axle to center of mass

%--------------------------------------------------------------------------
% Motor constants
%--------------------------------------------------------------------------

Const.Jm    = 5E-4; %1E-6   % tröghetsmoment för motorn
Const.Bm    = 1.1278E-3;    % viskositetskonstant
Const.Kt    = 0.31739;      % proportionalitetskonstant från 'i' till 'tau'.
Const.Kb    = 0.46839;      % proportionalitetskonstant från 'theta_dot' till 'eb'. 
Const.Ra    = 6.8562;         % inre resistans

Const.mc1   = Const.Bm + Const.Kt*Const.Kb/Const.Ra;% 0.0136; %;   %7.8414e-004; %% %4.3918e-004;    % motor constant 1 = Bm + Kt*Kb/Ra;
Const.mc2   = Const.Kt/Const.Ra; %   0.0226; %% 0.0016;      % %       %9.6574e-004;    % motor constant 2 = Kt/Ra; 

Const.deadzone = 0;         % Deadzone in degrees
Const.I_gear   = 1E-6;      % Gear inertia

%--------------------------------------------------------------------------
% Other constants
%--------------------------------------------------------------------------

Const.Ts    = 0.01; % Sample time for regulator  
Const.g     = 9.82;  % earth gravitation

Const.bd = 0.04;     % body depth




