% Controller that feeds the refrence signals directly to the output

function reg = inptFeedTrg(num_refs, Ts)

A = 0;
B = zeros(1,num_refs);
C = zeros(num_refs,1);
D = eye(num_refs);
reg = ss(A,B,C,D,Ts);
reg.InputGroup.y = [];
reg.InputGroup.ref = 1:num_refs;
reg.OutputGroup.u = 1:num_refs;
reg.OutputName = strseq('u',1:num_refs);
reg.InputName = strseq('r',1:num_refs);
reg.Note = 'InFeedThrg';

reg.UserData.sensorsAndRefs = [3 0;
                      3 0];
                  
reg.UserData.actuators = [1 0;
                 1 1];