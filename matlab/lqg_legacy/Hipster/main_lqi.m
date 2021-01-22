% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%
% Mainscript for design, simulation and analysis of LQG controller
%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  


%% Load state space model -------------------------------------------------
cs = getHipsterSS();
                                        
%% Controller design ------------------------------------------------------

% Scaling matrices  
[Du Dz] = getScaleMtrx(cs); 
Dzi = blkdiag(Dz,Dz);
         %%                                                   
% Designvariables to Kalman filter
R1 = diag([1 1]);
R2 = 1E-7*diag([10 10 1]);                                              
%%
% Designvariables to LQ
Q1 = diag([1 1 1 1]);
Q2 = 0.01*diag([1 1]);
%%
% Sampling period
Ts = 1E-3;     
%%
% LQG servo controller with integral action
[reg_c, reg_d] = lqi_servo(cs, R1, R2, Q1, Q2, Ts);

% Specify connections between outputs, inputs, sensors and actuators
lqi_reg_a = annotateReg(reg_d);

%% Simulation -------------------------------------------------------------

% Number of seconds to simulate
t = 2;

% Run simulation
sim_data = simulate_hipster(reg_d, t); 

%% Plot simulation results ------------------------------------------------
hipster_plot(sim_data)




