function kest = kalman_estimator(sys, R1, R2, intOn)


% Default value for integration is false
if nargin < 4
    intOn = false;  
end

% Check controller input and output groups
emsg = checkSys(sys);
if emsg ~= 0
   error(emsg); 
end

% System from input u to output y
sys_yu = sys('y','u');

% Matrices and dimensions of the ss model
M = sys('z',:).C;

% System dimensions
[ny, nu] = size(sys_yu);
nx = size(sys.A,1);
nz = length(sys.outputgroup.z);
nr = nz;
nw = length(sys.inputgroup.w);

% Check weight matrix dimensions
assert(all(size(R1) == [nw nw]),['R1 must be a matrix with nw = ' num2str(nw) ' rows and colums']); 
assert(all(size(R2) == [ny ny]),['R2 must be a matrix with ny = ' num2str(ny) ' rows and colums']); 

%% Kalman filter
if intOn
    sys_aug = getAugSys(sys,M);
    kest = kalman(sys_aug('y',{'u','r','w'}),R1,R2);
    kest.inputgroup.r = nu+1:nu+nr;
else
    kest = kalman(sys('y',{'u','w'}),R1,R2); 
end

kest.inputgroup.u = 1:nu;
kest.inputgroup.y = kest.inputgroup.Measurement;
kest.inputgroup.KnownInput = [];
kest.inputgroup.Measurement = [];