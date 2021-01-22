%% V_max = k_b*A*V_bat + k*B

k_b = 0.46839; %V/(rad/s)

rpm = [141 147.7];
v_bat = [7.7 8];

theta_dot = 2*pi/60*rpm; %rad/s

P = polyfit(v_bat, theta_dot, 1);

A = P(1)
B = P(2)

a = k_b*A/1000
b = k_b*B