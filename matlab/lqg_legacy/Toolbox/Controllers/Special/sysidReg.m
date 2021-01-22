%
% sireg 
% u = D*r 
% 
% y is the measured data that shall be logged, but is not used in the 
% feedback loop. 
%
% y ---*
%       .---.
% r --->| D |--->u
%       .---.
%
% Discreteized with sampling period Ts
%

function sireg = sysidReg(y_ix, r_ix, D, Ts, y_names, r_names, u_names)

nu = length(y_ix) + length(r_ix);
ny = size(D,1);

Ar = 0;
Br = zeros(1, nu);
Cr = zeros(ny,1);
Dr = [zeros(ny,length(y_ix)) D];

sireg = ss(Ar,Br,Cr,Dr,Ts);

sireg.InputGroup.y = y_ix;
sireg.InputGroup.r = r_ix;
sireg.OutputGroup.u = 1:ny;

if nargin < 5 || isempty(y_names)
    y_names = strseq('y',1:length(y_ix));
end

if nargin < 6 || isempty(r_names)
    r_names = strseq('r',1:length(r_ix));
end    

if nargin < 7 || isempty(u_names)
    u_names = strseq('u',1:ny);
end    

u_names = u_names(:);
y_names = y_names(:);
r_names = r_names(:);

sireg.OutputName = u_names;
sireg.InputName = [y_names; r_names];
sireg.StateName = '-';
sireg.Note = 'si_reg';
  