%--------------------------------------------------------------------------
% Mainscript for design, simulation and analysis of LQ controller
%--------------------------------------------------------------------------

%% Get state space model 
cs = getHipsterSS();
                                        
%% Controller design

% Sampling period
Ts = 1E-2;                   

% Scaling matrices  
[Du Dz] = getScaleMtrx(cs); 

% Designvariables to LQ      
Q1 = Dz\diag([0.1 0.1])/Dz;
Q2 = 0.01*(Du\diag([1 1])/Du);

% Controller
reg = lq_hipster(Q1,Q2,Ts);

% Specify connections between outputs, inputs, sensors and actuators
lq_reg_a = annotateReg(reg);

%% Simulation 

% Number of seconds to simulate
t = 2;

% Make nonlinear simulation
sim_data = simulate_hipster(reg, t); 

%% Plot
hipster_plot(sim_data)

%  Hipster Inc® 2012 ©reg 


        