
function cs = nonlinear2ss(nlinSys, x0, u0, perfindex_x, perfindex_y)

nzx = length(perfindex_x);
nzy =  + length(perfindex_y);
nz = nzx + nzy;
linSys = linearize(nlinSys,[x0; u0]);

M = zeros(nz, nlinSys.nx);
M(1:nzx, perfindex_x) = eye(nzx);
M(nzx+1:nzy, :) = linSys('y',:).C(perfindex_y,:);

cs = ss(linSys.A,linSys.B,[linSys.C; M],[linSys.D; zeros(nz,nlinSys.nu)]);

cs.InputGroup.u = nlinSys.InputGroup.u; 
cs.InputGroup.w = nlinSys.InputGroup.w;
cs.InputGroup.v = nlinSys.InputGroup.v;
cs.OutputGroup.y = nlinSys.OutputGroup.y;
cs.OutputGroup.z = nlinSys.ny+1:nlinSys.ny+nz;

cs.StateName = nlinSys.StateName;
cs.InputName = nlinSys.InputName;
cs.OutputName = [nlinSys.OutputName; cs.StateName(perfindex_x); cs.StateName(perfindex_y)];

if verLessThan('matlab', '8.0.0')
   
else
    cs.StateUnit  = nlinSys.StateUnit;
    cs.OutputUnit = [nlinSys.OutputUnit; cs.StateUnit(perfindex_x); cs.StateUnit(perfindex_y)];
    cs.InputUnit  = nlinSys.InputUnit;
end





