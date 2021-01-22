% A controller that will set light diode in active mode

function areg = regLS()

ud.sensorsAndRefs = [5, 0];

ud.actuators = [1 0];
            
areg = ss(0,0,0,0,0.01);

areg.outputgroup.u = [1];
areg.OutputName = {'-'};
areg.StateName = {'-'};
areg.InputName = {'y'};
areg.inputgroup.ref = 1;
areg.Note = 'LS';
areg.UserData = ud;