function reg = setNameAndGroups(reg,sys,name)

sys_yu = sys('y','u');

nu = length(sys.inputgroup.u);
nx = length(sys.statename);
ny = length(sys.outputgroup.y);
nr = length(sys.outputgroup.z);

xName = sys.staten;
zName = sys.outputname(sys.outputgroup.z); 
yName = sys.outputname(sys.outputgroup.y);
uName = sys.inputname(sys.inputgroup.u);
refUnit = sys.stateUnit(sys.outputgroup.z);

reg.inputn    = [strcat('ref_', zName); yName];
reg.staten    = [strcat(xName, '_hat')];
reg.outputn   = uName;

reg.inputg.r = 1:nr;
reg.inputg.y = nr+1:nr+ny;

reg.outputg.u = 1:nu;

%reg.StateUnit = [sys_yu.stateUnit; intUnit];
%reg.InputUnit = [refUnit; sys_yu.outputUnit];
%reg.OutputUnit= [sys_yu.inputUnit];

reg.Notes = name;
                     