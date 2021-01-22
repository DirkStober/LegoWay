%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Mainscript for design, simulation and analysis of LQI regulator
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initalization ----------------------------------------------------------
clear all
close all 

addpath(genpath('.')); 
cs = getHipsterSS();
                                        
%% Controller design ------------------------------------------------------

% Sampling period
Ts = 0.01;                   

% Scaling matrices  
[Du Dz] = getScaleMtrx(cs); 

% Designvariables to LQ      
Q1 = Dz\diag([10 1 1])/Dz;
Q2 = 2*(Du\diag([1 1])/Du);

reg = lq_hipster(Q1,Q2,Ts);
reg_h = annotateReg(reg);
%% Simulation -------------------------------------------------------------

% Number of seconds to simulate
t = 10;

% Make nonlinear simulation
sim_data = simulate_hipster(reg, t); 

%% Plot -------------------------------------------------------------------
hipster_plot(sim_data)

%  Hipster Inc® 2012 ©


