% System must have 
% Inputgroups: u w v
% Outputgroups: y z 

function emsg = checkSys(reg)
    expected_inputg = {'u','w','v'};
    expected_outputg = {'y','z'};
    tf = isfield(reg.inputgroup, expected_inputg);
    if ~tf
       emsg = ['System is missing inputgroup(s) ' [expected_inputg{~tf}]];
       return
    end
    tf = isfield(reg.outputgroup, expected_outputg);
    if ~tf
       emsg = ['System is missing outputgroup(s) ' [expected_outputg{~tf}]];
       return
    end
    emsg = 0;
end