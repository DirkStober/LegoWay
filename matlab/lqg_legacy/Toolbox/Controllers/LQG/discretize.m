function reg_d = discretize(reg_c,Ts)

reg_d  = c2d(reg_c, Ts, 'tustin');
% Transform state variables since tustin changes them in matlab versions
% previous to matlab 8.0
if verLessThan('matlab', '8.0.0')
    reg_d.B = reg_d.B*Ts;
    reg_d.C = reg_d.C/(Ts);
end

reg_d.staten = reg_c.staten;
reg_d.stateunit = reg_c.stateunit;
reg_d.notes = reg_c.notes;
reg_d.userd = reg_c.userd;  