
function sim_data = nlin_sim(reg, t, refCell, stdvPn, stdvMn, state_init, nlinModel, discORcont)

% Sampling period
Ts = reg.Ts;

% System dimensions
ny = length(nlinModel.OutputGroup.y);
nu = length(nlinModel.InputGroup.u);
nx = nlinModel.nx;
nw = length(nlinModel.InputGroup.w);
nv = length(nlinModel.InputGroup.v);

% Controller dimensions
nr_r = length(reg.InputGroup.r);
[ny_r nu_r] = size(reg);
nx_r = size(reg.A,2);

if nargin < 8 || isempty(discORcont)
    discORcont = 'cont';
end

if nargin < 6 || isempty(state_init)
    state_init = zeros(nx, 1);
end

if nargin < 5 || isempty(stdvMn)
    stdvMn = zeros(ny, 1);
end

if nargin < 4 || isempty(stdvPn)
    stdvPn = zeros(nx, 1);
end

% Build reference signal
for i=1:nr_r
    if i <= length(refCell) && ~isempty(refCell{i})
        r(i,:) = getRef(t, Ts, refCell{i});
    else
        r(i,:) = getRef(t, Ts, {zero()});
        warning(['No specified reference for state: ' num2str(i) '. Assuming zero reference']);
    end
end

% Simulate with discrete or continous plant
if strcmp(discORcont, 'cont')
    cont = 1;
else
    cont = 0;
end

% Number of steps to run simulation
N = ceil(t/Ts);          

%% Simulation

% Initialization
if(length(state_init) == nx)
    x = state_init;
else
    error(['x0 must be of length nx = ' num2str(nx) '. Thank you sir.']);
end
u  = zeros(nu,1);
xr = zeros(nx_r,1);
ur = zeros(nu_r,1);
yr = zeros(ny_r,1);
y = zeros(ny,1);

% Recording variables
u_hist = zeros(nu,N);
x_hist = zeros(nx,N);
y_hist = zeros(ny,N);

ur_hist = zeros(nu_r,N);
xr_hist = zeros(nx_r,N);
yr_hist = zeros(ny_r,N);

% Extract matrices for speed
Ar = reg.A;
Br = reg.B;
Cr = reg.C;
Dr = reg.D;
Ts = reg.Ts;

% Connection idexes
rr_ix = reg.inputgroup.r;
yr_ix = reg.inputgroup.y;
ur_ix = reg.outputgroup.u;

% Model handles
g = nlinModel.gh;
f = nlinModel.fh;

% Saturation values
u_max = nlinModel.u_range(:,2);
u_min = nlinModel.u_range(:,1);
x_max = nlinModel.x_range(:,2);
x_min = nlinModel.x_range(:,1);

% Special fix for MPC
if strcmp(reg.notes,'MPC')
    fr = reg.userdata.f;
end

% Show progress bar
h = waitbar(0,'Simulation in progress, please wait...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0)
gray = [0.5 0.5 0.5];
white = [1 1 1];
orange = [1 0.6 0];
set(findobj(h,'type','patch'), ...
'edgecolor',gray,'facecolor',orange)
set(h,'Color',white)

% If a complete process noise vector is not given, create one
if size(stdvPn,2) == 1
    w_mat = Ts*diag(stdvPn)*randn(nw,N);
elseif size(stdvPn,2) == N
    w_mat = stdvPn;
else
    error(['Length of stdvPn must be ' num2str(N) ' or 1.']);
end

% If a complete measurement noise vector is not given, create one
if size(stdvMn,2) == 1
    v_mat = diag(stdvMn)*randn(nv,N);
elseif size(stdvMn,2) == N
     v_mat = stdvMn;
else
    error(['Length of stdvMn must be ' num2str(N) ' or 1.']);
end

% simulation loop
for j = 1:N
   
   % Process and measurement noise for iteration j
   w = w_mat(:,j);
   v = v_mat(:,j);
   
   % Input vector for plant
   plant_input = [x; u; w; v];
    
    % Measurment for current iteration
    y = g(plant_input);
    
    % save simulation data for each step in simulation
    u_hist(:,j) = u;
    x_hist(:,j) = x;
    y_hist(:,j) = y;    
    
    ur_hist(:,j) = ur;
    xr_hist(:,j) = xr;
    yr_hist(:,j) = yr;
    
    % Controller input
    if isempty(r)
        ur(rr_ix) = zeros(nr,1);
        ur(yr_ix) = y;
    else
        ur(rr_ix) = r(:,j);
        ur(yr_ix) = y;
    end
    
    % Controller output
    
    % Special fix for MPC
    if strcmp(reg.notes,'MPC')
        [xr yr] = fr(xr, ur);
    else
        % Controller output
        yr = Cr*xr + Dr*ur;    

        % Propagate controller states
        xr = Ar*xr + Br*ur; 
    end
        
    % System input, clipped
    yr(ur_ix) = max(min(yr(ur_ix),u_max),u_min);
    u = yr(ur_ix);
    plant_input = [x; u; w; v];
    
    % Propagate system state
    if cont
        % Continous time propagation
        [~,dx] = ode45(f, [0 Ts], plant_input);    
        x = dx(end,1:nx)';
    else
        % Discrete time propagation
        x = f(plant_input);
    end
    
    % Clip state vector
    x = max(min(x,x_max),x_min);
    
    % Print progress
    waitbar(j/N)
    
    % Check for Cancel button press
    if getappdata(h,'canceling')
        break
    end
end

% Collect simulation data in a sim_data struct
sim_data(1).Ts = Ts;
sim_data(1).RegName = 'Plant';
sim_data(1).StateName = nlinModel.StateName;
sim_data(1).InputName = nlinModel.InputName(nlinModel.InputGroup.u);
sim_data(1).OutputName = nlinModel.OutputName(nlinModel.OutputGroup.y);
sim_data(1).states = x_hist;
sim_data(1).inputs = u_hist;
sim_data(1).outputs = y_hist;                                       
sim_data(1).ctrl_loop_start_ms = 0:Ts*1E3:(t-Ts)*1E3;

sim_data(2).Ts = Ts;
sim_data(2).RegName = reg.notes{1};
sim_data(2).StateName = reg.StateName;
sim_data(2).InputName = reg.InputName;
sim_data(2).OutputName = reg.OutputName;
sim_data(2).states = xr_hist;
sim_data(2).inputs = ur_hist;
sim_data(2).outputs = yr_hist;                                       
sim_data(2).ctrl_loop_start_ms = 0:Ts*1E3:(t-Ts)*1E3;

sim_data(1).StateUnit = nlinModel.StateUnit;
sim_data(1).InputUnit = nlinModel.InputUnit(nlinModel.InputGroup.u);
sim_data(1).OutputUnit = nlinModel.OutputUnit(nlinModel.OutputGroup.y);


if ~verLessThan('matlab', '8.0.0')
    sim_data(2).StateUnit = reg.StateUnit;
    sim_data(2).InputUnit = reg.InputUnit;
    sim_data(2).OutputUnit = reg.OutputUnit;
else
    sim_data(2).StateUnit = cell(nx_r,1);
    sim_data(2).InputUnit = cell(nu_r,1);
    sim_data(2).OutputUnit = cell(ny_r,1);
    
    for i = 1:nx_r
        sim_data(2).StateUnit{i} = '';
    end
    
    for i = 1:nu_r
        sim_data(2).InputUnit{i} = '';
    end
    
    for i = 1:ny_r
        sim_data(2).OutputUnit{i} = '';
    end
end

delete(h);

    
    
    
    