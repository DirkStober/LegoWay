
close all
clear all
addpath(genpath('.'));

%% Create input signal for identification
% An N-sample long prbs with major frequency content in [w_low, w_high], and
% amplitude between ulow and uhigh

N      = 1000;       % Number of samples
Ts     = 5E-3;       % Sampling period
f_ny   = 1/(2*Ts);   % Nyquist frequency

w_low  = 1;
w_high = 5;
band   = [w_low, w_high]/f_ny;    % frequency content band, normalized

u_low  = -7.5;
u_high =  7.5;  
levels = [u_low, u_high];         % voltage range

sinedata  = [1, 10, 1];

u_sumsine = idinput(N,'sine', band, levels, sinedata); 
u_prbs    = idinput(N,'prbs', band, levels);

M = 300;

u_step = [zeros(M,1); 4*ones(N-M,1)] + 2;
u_sim  = u_step;

simulinkDCmotorInit;

%% Generate C code

this = pwd;
cd ../../Hipster_sw/SI_utils
u2c(u_step, 'u');
cd(this);

%% Get data from experiment

addpath '../../Hipster_sw/SI_utils'
%load motor_si_070709_sinusar;     % logged data from experiment, containing y and u vector
load motor_si_070724_step_2_6;

y  = y;
ut = u; 

plot(y)
%%

[th, dth, ddth, u] = prepDataForIdent(y, ut, Ts);

figure

plot([th dth])

%%

dth = prepDataForIdent(dth, u, Ts);

plot(dth);

%%

n     = length(y);

ydata = deg2rad(y);
xdata = Ts*(0:n-1)'; 

ind = 1:400;

p     = polyfit(xdata(ind), ydata(ind), 10);
y_est = polyval(p, xdata(ind));

plot(xdata(ind), [y_est ydata(ind)])

%%

dp = poly_diff(p);

dydata = polyval(dp, xdata(ind));

plot(dydata);

%%

K     = 1.66;

x1    = 223;
x2    = 266;
y1    = 2.123;
y2    = 6.263;

slope = (y2 - y1)/(x2 - x1)/Ts;
T     = K/slope;

a = 1/(4*T);
b = (K/T/4);

mc1_est = a*I;
mc2_est = b*I;

%% Get data from simulation

dy = dth.signals.values;
y  = rad2deg(th.signals.values);

plot(dy);
figure;
plot(y);
ut = u_sim(:,2);

%%

% Prepare data for identification. Smoothing of quantization steps etc. 
[th, dth, ddth, u] = prepDataForIdent(y, ut, Ts);
%u = ut;
figure
subplot(2,1,1)
plot(dth)
title('output');
xlabel('time [s]');
ylabel('angular vel [rad/s]');
subplot(2,1,2);
plot(u)
title('input');
xlabel('time [s]');
ylabel('input voltage [V]');

%%

n     = 300;

ydata = deg2rad(y(1:n));
xdata = Ts*(0:n-1)'; 

p     = polyfit(xdata, ydata, 3);
y_est = polyval(p, xdata);

plot(xdata, [y_est ydata])

d     = p.*[3 2 1 0];
d     = d(1:3);
dd    = d.*[2 1 0];
dd    = d(1:2);

dydata  = dy(1:n);

figure;

dy_est  = polyval(d,  xdata);
ddy_est = polyval(dd, xdata);  

plot(xdata, [dy_est dydata]);

figure
plot(ddy_est);

K     = 2.03;
slope = ddy_est(1);
T     = K/slope;

a = 1/T;
b = K/T;

%% Transient analysis

n     = 30;
xdata = Ts*(0:n)';
ydata = dth(1:n+1);

p = polyfit(xdata, ydata, 1);

K = max(dy);
slope = (dy(3) - dy(2))/Ts;
T = K/slope;

a = 1/T;
b = K/T;

%% TEMP compare

d = (length(dy) - length(dth))/2;

plot([dy(d+1:end-d) dth]);
figure;
plot([ut(d+1:end-d) u]);

%% Select subsection of the data that will be used in the identification
% 
% dth = dy;
% ddth = zeros(size(dth));
% th = zeros(size(dth));
% u = ut;

i_beg = round(length(dth)/6);     % index beginning, do not use the inital data that are affected by transients
i_end = round(length(dth)*(8/9)); % index end

th_s = th(i_beg:i_end);
th_s = detrend(th_s);

dth_s = dth(i_beg:i_end);         % selected output data sequence 
dth_s = detrend(dth_s);           % detrend data

ddth_s = ddth(i_beg:i_end);       % selected output data sequence 
ddth_s = detrend(ddth_s);         % detrend data

u_s = u(i_beg:i_end);             % selected input data sequence
%u_s = detrend(u_s);              % detrend data

% Show part of the data selected for identification
square_x = [i_beg i_end]';
square_y = [max(dth) max(dth)]';

area(square_x, square_y, 'FaceColor', [1 1 0], 'BaseValue', min(dth))
hold on;
plot(dth)
axis tight

%%

ydata  = dth_s;
n      = length(ydata);
xdata  = Ts*(0:(n-1))';
f      = fittype('a * sin( 2*pi*b*x + c)');

a_init = max(ydata);
b_init = 3;
c_init = 0;
init   = [a_init b_init c_init];

fit1   = fit(xdata, ydata, f, 'StartPoint', init);

plot(fit1, xdata, ydata);

dth_s = fit1(xdata);
a = fit1.a;
b = fit1.b;
c = fit1.c;
ddth_s = 2*pi*b*a*cos(2*pi*b*xdata + c);

%%  PEM

data  = iddata(dth_s, u_s, Ts); 

% Structure and initial values for ss model to be identified
A  = 0; 
B  = 0;
C  = 1;
D  = 0; 
K  = 0;
x0 = dth(1);
m  = idss(A, B, C, D, K, x0, 'Ts', 0, 'SSparameterization', 'structured');    %Samplingtime Ts = 0 indicates continous model

% Specification of wich parameters are to be estimated. x0 is the inital
% value of state
m.As = NaN;
m.Bs = NaN;
m.Cs = m.C;
m.Ds = m.D;
m.Ks = m.K;
m.x0s = x0;

% identify parameters
est_mod = pem(data,m); 

mc1_est = -est_mod.a*I;
mc2_est =  est_mod.b*I;

p = [mc1/mc1_est mc2/mc2_est];

%% IV Method

% ms   = 5;               % max shift
% 
% y_0  = th(1+ms:end);    % y(t)
% y_m1 = th(1+ms-1:end-1);% y(t-1)
% y_m2 = th(1+ms-2:end-2);% y(t-2)
%

% u_m1  = u(1+ms-1:end-1); % u(t-1)
% u_m2 = u(1+ms-2:end-2); % u(t-2)
% u_m3 = u(1+ms-3:end-3); % u(t-3)
% u_m4 = u(1+ms-4:end-4); % u(t-4)
% u_m5 = u(1+ms-5:end-5); % u(t-5)

u_m1  = u_s(1:end-1);
u_0   = u_s(2:end); 
dth_0 = dth_s(2:end);
ddth_0= ddth_s(2:end);

Z    = [u_m1 u_0]';
PHI  = [dth_0 u_0]';
Y    = ddth_0;

ZPHI = Z*PHI';

est  = ZPHI\(Z*Y);  

mc1_est = -est(1)*I;
mc2_est =  est(2)*I;

%% Least Squares

Y = ddth_s;
PHI = [dth_s u_s];
est = PHI\Y;

%% Verification

% Load fresh data set for verification
% load motor_si_070709_prbs_ver

[y_ver dy_ver ddy_ver u_ver] = prepDataForIdent(y, ut, Ts);
y_sim = sim(est_mod, u_ver);
plot([y_sim dy_ver]);

data = iddata(dy_ver, u_ver);
figure
resid(est_mod, data)

figure
const = constants();
model = idss(-const.mc1/(I), const.mc2/(I), 1, 0, 0, dy_ver(1), 0);

u_ver_id = iddata([], u_ver, Ts);
y_sim = sim(model, u_ver_id);

plot([y_sim.y dy_ver]);
