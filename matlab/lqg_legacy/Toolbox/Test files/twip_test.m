Q1 = eye(2);
Q2 = eye(2);
R1 = eye(2);
R2 = eye(3);
Qe = eye(2);

% Correct calls
reg1 = lq_twip(Q1,Q2);
reg2 = lqg_twip(Q1,Q2,R1,R2);
reg3 = lqi_twip(Q1,Q2,Qe,R1,R2);

% Wrong number of input parameters
try
    disp('lq_twip: wrong number of inputs');
    reg1 = lq_twip(Q1);
catch e
    disp(e.message);
end 

try
    disp('lqg_twip: wrong number of inputs');
    reg1 = lqg_twip(Q1,Q2,R1);
catch e
    disp(e.message);
end 

try
    disp('lqi_twip: wrong number of inputs');
    reg1 = lqi_twip(Q1,Q2,Qe,R1);
catch e
    disp(e.message);
end
