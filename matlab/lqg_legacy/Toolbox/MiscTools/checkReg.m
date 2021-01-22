% Regulator must have 
% Inputgroups: y ref 
% Outputgroups: u 

function emsg = checkReg(reg)
    tf = isfield(reg.InputGroup, 'y');
    if ~tf
       emsg = 'Controller must have inputgroup y';
       return
    end
    tf = isfield(reg.inputgroup, 'r');
     if ~tf
       emsg = 'Controller must have inputgroup r';
       return
    end
    tf = isfield(reg.outputgroup, 'u');
     if ~tf
       emsg = 'Controller must have outputgroup u';
       return
     end
    emsg = 0;
end