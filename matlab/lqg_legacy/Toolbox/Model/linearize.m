function linMod = linearize(nlinMod, x0, u0)
    
    [ny nu nx] = size(nlinMod);
    
    if nargin < 2 || isempty(x0)
        x0 = zeros(nx,1);
    end
    
    if nargin < 3 || isempty(u0)
       u0 = zeros(nu,1); 
    end
    
    p = nlinMod.fh;
    p = @(x) p(0,x);
    J = jacobianest(p,[x0; u0]);
    A = J(1:nx, 1:nx);
    B = J(1:nx, nx+1:nx+nu);
    
    p = nlinMod.gh;
    J = jacobianest(p,[x0; u0]);
    C = J(1:ny,1:nx);
    D = J(1:ny, nx+1:nx+nu);
    
    linMod = ss(A,B,C,D);
    linMod.InputGroup.u     = nlinMod.InputGroup.u; 
    linMod.InputGroup.w     = nlinMod.InputGroup.w;
    linMod.InputGroup.v     = nlinMod.InputGroup.v;
    linMod.OutputGroup.y    = nlinMod.OutputGroup.y;
    linMod.StateName        = nlinMod.StateName;
    linMod.InputName        = nlinMod.InputName;
    linMod.OutputName       = nlinMod.OutputName;
    linMod.UserData         = nlinMod.UserData;
end