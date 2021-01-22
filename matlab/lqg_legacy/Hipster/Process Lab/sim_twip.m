% sim_twip(reg)
%
% Input     Type           Description
% reg       LTI ojbect     A controller created by some of the functions
%                          lq_twip, lqg_twip or lqi_twip.
%
% Output    Type           Description
% Plot      Figure         A figure showing the simulation results. The
%                          nonlinear continous time system controlled with
%                          a sampling controller reg is simulated.
%                          Initially the system is at rest. At time t=0 a
%                          step of 45 deg in the yaw reference is applied,
%                          and at time t=0.5 s a step of 0.1 m/s in the
%                          velocity reference is applied.

function [sim_data, map, titles] = sim_twip(reg, noise_on)

if nargin ~= 2
    disp('Wrong number of input arguments, see help below');
    help sim_twip
end

skip_plot = false;
if nargout == 3
    skip_plot = true;
elseif nargout ~= 0
    disp('Wrong number of output arguments, see help below');
    help sim_twip
end

% Number of seconds to simulate
t = 2;

% Rename reference field to be consistent with other convention
if isfield(reg.inputgroup, 'ref')
    r_ix = reg.inputgroup.ref;
    reg.inputgroup.ref =[];
    reg.inputgroup.r = r_ix;
end

 % Initial state
x0  = [0 0 0 0 0 0]';  


% Reference signals
ref{1}  = {step(0,45*pi/180)};
ref{2}  = {step(0.5,0.1)};  
%ref{2}  = {zero()};

N = t/reg.Ts;

% Process and measurement noise standard deviation
if noise_on
    noise_intensities = 0.01;
else
    noise_intensities = 0;
end
stdvPn = 200*noise_intensities*diag(sqrt([1 1])')*(randn(2,N)); 
stdvMn = 0.01*noise_intensities*diag(sqrt(1e-5*[1 1 1])')*(randn(3,N));                                                   

% Function handle to the nonlinear model
model_handle = getHipsterModel();

% Simulation
sim_data_tmp = simulation(reg, t, ref, stdvPn, stdvMn, x0, model_handle); 

%% PERTEST
sim_data.Ts      = sim_data_tmp(2).Ts;
sim_data.RegName = sim_data_tmp(2).RegName;

sim_data.StateName  = [sim_data_tmp(1).StateName  ; sim_data_tmp(2).StateName];
sim_data.InputName  = [sim_data_tmp(1).InputName  ; sim_data_tmp(2).InputName];
sim_data.OutputName = [sim_data_tmp(1).OutputName ; sim_data_tmp(2).OutputName];

sim_data.StateUnit  = [sim_data_tmp(1).StateUnit  ; sim_data_tmp(2).StateUnit];
sim_data.InputUnit  = [sim_data_tmp(1).InputUnit  ; sim_data_tmp(2).InputUnit];
sim_data.OutputUnit = [sim_data_tmp(1).OutputUnit ; sim_data_tmp(2).OutputUnit];

sim_data.states  = [sim_data_tmp(1).states  ; sim_data_tmp(2).states];
sim_data.inputs  = [sim_data_tmp(1).inputs  ; sim_data_tmp(2).inputs];
sim_data.outputs = [sim_data_tmp(1).outputs ; sim_data_tmp(2).outputs];

sim_data.ctrl_loop_start_ms = sim_data_tmp(2).ctrl_loop_start_ms;
%%%%%%%%%%%%






%% Plot
n = 2;

map_tmp = {{'x'},{'x_hat'}; 
{'yaw'},{'yaw_hat'};
{'pitch'},{'pitch_hat'};
{'vel'},{'vel_hat'};
{},{'V_right','V_left'}};

map = repmat(map_tmp,1,n/2);
map{2,2} = {'yaw_hat','ref_yaw'};
map{4,2} = {'vel_hat','ref_vel'};
titles = {'x','yaw','pitch','vel','input'};

if ~skip_plot
    plotld(sim_data,map,[],'name',2,[],titles);

    % Add lines for the maximum and minumum values of the input signal
    subplot(3,2,5);
    hold on;
    plot([0 2], [7 7], 'r--');
    plot([0 2], -[7 7], 'r--');

    legend({'V_{left}','V_{right}','Max/Min'});
end
