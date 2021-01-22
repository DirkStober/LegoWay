% Connects the conroller reg and state estimator designed for the system sys
% An integrating system is added if an input for integration is detected in
% reg. 

% reg is a static gain of the formm
% ss([L; Li; Lr]) with inputgroups {x,ei,r} and outputgroup {u}

% est can be a dynamical system, but must have inputgroups {y,u} and
% outputgroup x_hat

function csys = connect_sys(sys,reg,est)


nu = length(est.inputgroup.u);
ny = length(est.inputgroup.y);
nx = size(est.A,1);


L = reg.D;

% Is the controller a servo controller
isServo = isfield(reg.inputgroup,'r');

if isServo
    nr = length(reg.inputgroup.r);
    Lr = L(reg.inputgroup.r,:);
    refnames = strcat('ref_',sys.outputnames(sys.outputgroup.z));
    refunits = sys.outputunits(sys.outputgroup.z);
    Br = -eye(nr);
else
    nr = 0;
    Lr = [];
    refnames = [];
    refunits = [];
    Br = [];
end

% Is the controller integrating
isIntegrating = isfield(reg.inputgroup,'ei');


if isIntegrating
    nz = size(M,1);
    Li = L(reg.inputgroup.ei,:);
    intnames = reg.inputnames(reg.inputgroup.ei);
    intunits = reg.inputunits(reg.inputgroup.ei);
    if ~isServo
        Br = zeros(nz);
    end
else
    Li = [];
    M = [];
    nz = 0;
    intnames = [];
    intunits = [];
end

% Complete regulator system
[Ak, Bk, Ck, Dk] = ssdata(est);
Ac = [Ak zeros(nx,nz); M zeros(nz,nz)];
Bc = blkdiag(Bk,Br);
Cc = [-L Li]; 
Dc = Lr;
csys = ss(Ac,Bc,Cc,Dc);

% Inputgroups
csys.inputgroup.u = est.inputgroup.u;
csys.inputgroup.y = est.inputgroup.y;
csys.inputgroup.r = 0;

% Outputgroups
csys.outputgroup.u = 1:nu;

% Inputnames
csys.inputnames = [est.inputnames; refnames]; 

% Outputnames
csys.outputnames = reg.outputnames;

% Statenames
csys.statenames = [est.statenames; intnames];

% Inputunits
csys.inputunits = [est.inputunits; refunits];

% Outputunits
csys.outputunits = reg.outputunits;

% Stateunits
csys.stateunits = [est.stateunits; intunits];

