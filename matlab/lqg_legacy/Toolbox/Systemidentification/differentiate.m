function [dy t] = differentiate(y,Ts)

Fpass = 0.20;  % Passband Frequency
Fstop = 0.35;  % Stopband Frequency
Apass = 1;     % Passband Ripple (dB)
Astop = 60;    % Stopband Attenuation (dB)

% Low pass filter signal before differentiation
h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop);
Hd = design(h, 'equiripple');
numTaps = length(Hd.numerator);
y = filter(Hd.numerator,1,y);

% Differentiate
%dy = (y(2:end) - y(1:(end-1)))/(2*Ts);

dy = (-y(5:end) + 8*y(4:end-1) - 8*y(2:end-3) + y(1:end-4))/(12*Ts);

% Time vector
t = Ts*(1-numTaps/2) + (0:(length(dy)-1))*Ts; 