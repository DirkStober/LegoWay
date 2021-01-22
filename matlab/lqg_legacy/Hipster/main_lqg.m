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
                                                            
% Designvariables to Kalman filter
R1 = diag([0.1 0.1]);
R2 = 1E-3*diag([10 10 1]);   

% Designvariables to LQ
Q1 = diag([0.1 0.1]);
Q2 = 0.001*diag([1 1]);

% Sampling period
Ts = 5E-3;                   

% LQG servo controller
[regc, regd] = lqg_servo(cs, R1, R2, Q1, Q2, Ts);

% Specify connections between outputs, inputs, sensors and actuators
lqg_reg_a = annotateReg(regd);
%% Simulation -------------------------------------------------------------

% Number of seconds to simulate
t = 2;

% Run simulation
sim_data = simulate_hipster(regd, t); 

%% Plot simulation results ------------------------------------------------
hipster_plot(sim_data)
