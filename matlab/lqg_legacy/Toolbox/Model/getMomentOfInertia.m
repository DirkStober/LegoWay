%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getMomentOfInertia.m
% Calculates the moment of inertia around each axis, for a rigid body wich
% is composed of one or several rigid bodies.
%
% INPUT:
%    bodies: A vector of structs. Each struct should describe one body of
%    wich the completet body is built up of. The struct must have fields
%   
%   Field   Type        Meaning       
%   mass    scalar      bodys mass
%
%   com     1*3 vector  position vector for Center Of Mass [x, y, z] 
%
%   size    1*3 vector  bodys dimensions, width, height and depth.
%                       width, height and depth are the length of the 
%                       sides parrallell to x, y and z axis respectively.
%
% OUTPUT:
%   Ixx: moment of inertia around x axis
%   Iyy: moment of inertia around y axis
%   Izz: moment of inertia around z axis
%   COM: position vector for center of mass
%
% copyright (C) hipster inc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [Ixx, Iyy, Izz, COM] = getMomentOfInertia(bodies)

Ixx = 0;            % moment of inertia around x-axis
Iyy = 0;            % moment of inertia around y-axis
Izz = 0;            % moment of inertia around z-axis

COM = [0,0,0];      % Center of mass (x, y, z)
mCumSum = 0;        % Cumulative mass

for j = 1:length(bodies)
    
    m = bodies(j).mass;
    mCumSum = mCumSum + m;
    
    COM = COM + m/(mCumSum)*(bodies(j).com - COM); 
end

for j = 1:length(bodies)
    
    m = bodies(j).mass;
    w = bodies(j).size(1);
    h = bodies(j).size(2);
    d = bodies(j).size(3);
    
    pos = bodies(j).com - COM;  %position vector to COM
    
    % inertias are equal to the sum of the inertia for each body. Inertia
    % is calculated as if the bodies were rectangular prisms, the
    % steiner term is added also.
    Ixx = Ixx + 1/12*m*(d^2 + h^2) + m*sum(pos([2 3]).^2);
    Iyy = Iyy + 1/12*m*(d^2 + w^2) + m*sum(pos([1 3]).^2);
    Izz = Izz + 1/12*m*(h^2 + w^2) + m*sum(pos([1 2]).^2);
end

return
end

