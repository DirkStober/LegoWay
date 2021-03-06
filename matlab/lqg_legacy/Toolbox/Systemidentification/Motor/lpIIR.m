function Hd = lpIIR(Ts)
%LPIIR Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.8 and the Signal Processing Toolbox 6.11.
%
% Generated on: 11-Jul-2009 21:55:05
%

Fpass = 10;    % Passband Frequency
Fstop = 15;    % Stopband Frequency
Apass = 1;     % Passband Ripple (dB)
Astop = 60;    % Stopband Attenuation (dB)
Fs    = 1/Ts;  % Sampling Frequency

h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);

Hd = design(h, 'butter', ...
    'FilterStructure', 'df1tsos', ...
    'MatchExactly', 'stopband');



% [EOF]
