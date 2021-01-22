Order = [3 2 6]; %[Ny Nu Nx];

%% Parameters
Const = constants();

clear Parameters
j=0;

%j=j+1;
% Parameters(j).Name = 'L';
% Parameters(j).Unit = 'm';
% Parameters(j).Value = Const.L;
% Parameters(j).Minimum = Const.L-1.5;
% Parameters(j).Maximum = Const.L+1.5;
% Parameters(j).Fixed = false;

j=j+1;
Parameters(j).Name = 'Iw';
Parameters(j).Unit = 'kg*m^2';
Parameters(j).Value = Const.Iw;
Parameters(j).Minimum = 0;
Parameters(j).Maximum = Inf;
Parameters(j).Fixed = false;

% j=j+1;
% Parameters(j).Name = 'Ij';
% Parameters(j).Unit = 'kg*m^2';
% Parameters(j).Value = Const.Ij;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;

% j=j+1;
% Parameters(j).Name = 'Ip';
% Parameters(j).Unit = 'kg*m^2';
% Parameters(j).Value = Const.Ip;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;
% 
% j=j+1;
% Parameters(j).Name = 'Jm';
% Parameters(j).Unit = 'kg*m^2';
% Parameters(j).Value = Const.Jm;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;
% 
% j=j+1;
% Parameters(j).Name = 'Kt';
% Parameters(j).Unit = 'Nm/A';
% Parameters(j).Value = Const.Kt;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;
% 
% j=j+1;
% Parameters(j).Name = 'Kb';
% Parameters(j).Unit = 'V/(rad/s)';
% Parameters(j).Value = Const.Kb;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;
% 
% j=j+1;
% Parameters(j).Name = 'Ra';
% Parameters(j).Unit = 'ohm';
% Parameters(j).Value = Const.Ra;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;
% 
% j=j+1;
% Parameters(j).Name = 'Bm';
% Parameters(j).Unit = 'Nm/(rad/s)';
% Parameters(j).Value = Const.Bm;
% Parameters(j).Minimum = 0;
% Parameters(j).Maximum = Inf;
% Parameters(j).Fixed = false;


%% Initial states

j=1;
InitialStates(j).Name = 'x';
InitialStates(j).Unit = 'm';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;

j=j+1;
InitialStates(j).Name = 'jaw';
InitialStates(j).Unit = 'rad';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;

j=j+1;
InitialStates(j).Name = 'pitch';
InitialStates(j).Unit = 'rad';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;

j=j+1;
InitialStates(j).Name = 'vel';
InitialStates(j).Unit = 'm/s';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;

j=j+1;
InitialStates(j).Name = 'jaw angular vel.';
InitialStates(j).Unit = 'rad/s';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;

j=j+1;
InitialStates(j).Name = 'pitch angular vel.';
InitialStates(j).Unit = 'rad/s';
InitialStates(j).Value = 0;
InitialStates(j).Minimum = -inf;
InitialStates(j).Maximum = inf;
InitialStates(j).Fixed = false;


%% Measured data

y = y_hist(2:end,:)';
u = [u_hist' u_hist'];
Ts = Const.Ts;
y(:,3) = -y(:,3);
data = iddata(y(1:4,:),u(1:4,:),Ts);

%% Do system identification

m = idnlgrey(@nonlinearkane, Order, Parameters, InitialStates)
m.Algorithm.Display = 'on';
m.Algorithm.MaxIter = 2;
m.Algorithm.Tolerance = 10e6;
m_est = pem(data, m);