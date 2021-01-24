% optimizes for gyro sensor
function rC = ps_gyro(rsC,vi_s,ds)

[hf,hd] = ps_matrices(ds,[0 0; 0 0; 1 1],zeros(6,2),[zeros(6,3),diag([1 1 1 1 1 1])],[diag([0.1 0.1 1]),zeros(3,6)]);
T = optim([2,5],hf,hd,vi_s);

tmp = T*rsC;
rC = tmp(1,:);
end

