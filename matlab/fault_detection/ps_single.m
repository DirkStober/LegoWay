
% ps_space_single creates a ps residual generator using just one sensor
% output and forms in properly to be connected to the [Y(k) U(k)] vector


function rC = ps_single(ds,Ts,ns,sensor)
rsc = parity_space(ds,Ts,ns,sensor);
ys = 3;
rC = [zeros(1,ys*(ns+1)),rsc(1,(ns+1+1):end)];
for i = 0:ns
    rC(1,i*ys+sensor) = rsc(1,i+1);
end
end

