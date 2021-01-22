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

function sim_twip_disturbance(reg)

if nargin ~= 1
    disp('Wrong number of input arguments, see help below');
    help sim_twip
end

% Number of seconds to simulate
t = 4;

% Rename reference field to be consistent with other convention
if isfield(reg.inputgroup, 'ref')
    r_ix = reg.inputgroup.ref;
    reg.inputgroup.ref =[];
    reg.inputgroup.r = r_ix;
end

% Initial state
x0  = [0 0 0 0 0 0]';  

% Reference signals
% ref{1}  = {step(0,45*pi/180)};
% ref{2}  = {step(0.5,-0.1)};  

ref{1}  = {zero()};
ref{2}  = {zero()};

N = t/reg.Ts;

% Process and measurement noise
noise_intensities = 0.5;
pn = noise_intensities*diag(sqrt([1 1])')*(randn(2,N)); 
mn = noise_intensities*diag(sqrt(1e-5*[1 1 1])')*(randn(3,N));                                                   
%stdvPn(1:2,:) = stdvPn(1:2,:) - 1;
pn(:,10) = 1  ;


% Function handle to the nonlinear model
model_handle = getHipsterModel();

% Simulation
sim_data = simulation(reg, t, ref, pn, mn, x0, model_handle); 


%% Plot
n = 2;

map = {{'x'},{'x_hat'}; 
{'yaw'},{'yaw_hat'};
{'pitch'},{'pitch_hat'};
{'vel'},{'vel_hat'};
{},{'V_right','V_left'}};

MAP = repmat(map,1,n/2);
MAP{2,2} = {'yaw_hat','ref_yaw'};
MAP{4,2} = {'vel_hat','ref_vel'};
tit = {'x','yaw','pitch','vel','input'};

%plotld(sim_data,MAP,[],'name',2,[],tit);
plot_mode = 'all';
nsec = [];
plotld(sim_data, MAP, [], 'name', 2, [], tit, plot_mode, nsec)

% Add lines for the maximum and minumum values of the input signal
subplot(3,2,5);
hold on;
plot([0 t], [7 7], 'r--');
plot([0 t], -[7 7], 'r--');

legend({'V_{left}','V_{right}','Max/Min'});
