% The nonlinear model is given by
%
% dx/dt = f(x,u,w)
% y = g(x,u,v)
%

classdef nonlinModel
   properties
      % function handle to x_dot = f(x,u) and y = g(x,u)
      fh; 
      gh; 
      
      % Input output groups
      InputGroup = [];
      OutputGroup =[];
      
      % Names
      InputName = cell(1);
      OutputName = cell(1);
      StateName = cell(1);
      
      % Units
      InputUnit = cell(1);
      OutputUnit = cell(1);
      StateUnit = cell(1);
      
      % Additional user data
      UserData = [];
      
      % Input, output and state dimensions
      nx;
      ny;
      nu;
      
      % Saturation values
      u_range = [-inf inf];
      x_range = [-inf inf];
   end
   methods
       function nm = nonlinModel(fh,gh, ny, nu, nx)
            nm.fh = fh;
            nm.gh = gh;
            nm.ny  = ny;
            nm.nu = nu;
            nm.nx = nx;
            nm.StateName = strseq('x',1:nx);
            nm.OutputName = strseq('y',1:ny);
            nm.InputName =  strseq('u',1:nu); 
       end
       
       function [ny nu nx] = size(nm)
            ny = nm.ny;
            nu = nm.nu;
            nx = nm.nx;
       end
       
   end
end
