function [reg_c,reg_d] = lqg_servo(cs, R1, R2, Q1, Q2, Ts,int_on)
if(nargin < 7) 
    int_on = false;
end
[reg_c, reg_d] = lqgi_servo(cs, R1, R2, Q1, Q2, Ts, int_on);