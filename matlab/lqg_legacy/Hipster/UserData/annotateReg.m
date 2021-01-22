function reg = annotateReg(reg)

if strcmp(reg.notes, 'LQI') || strcmp(reg.notes, 'LQG')

    ud.sensorsAndRefs =    [3, 0;
                            3, 0;
                            2, 0;
                            2, 1;
                            1, 3];

    ud.actuators = [1 0;
                    1 1];
    reg.UserData = ud;

    reg.inputgroup.ref = reg.inputgroup.r;
    reg.inputgroup.r = [];
elseif strcmp(reg.notes, 'LQ') 
     ud.sensorsAndRefs =[3, 0;
                         3, 0;
                         2, 0;
                         2, 1;
                         1, 3];

    ud.actuators = [1 0;  
                    1 1;
                    2 4;
                    2 4;
                    2 4;
                    2 4;
                    2 4;
                    2 4];
                
    reg.UserData = ud;

    reg.inputgroup.ref = reg.inputgroup.r;
    reg.inputgroup.r = [];
end