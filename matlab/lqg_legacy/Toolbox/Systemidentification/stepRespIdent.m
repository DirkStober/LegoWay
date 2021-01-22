function [y u t] = stepRespIdent(cntr,stepSize,t)

logpath = 'c:/Logs';
 
global hc;

hc.setReg(cntr);
hc.start();

pause(2);
hc.setRef(2, stepSize, 1);
pause(t);
hc.stop();

%%
log_files = getLogFilesSortedByDate(logpath);
log_file_latest = fullfile(logpath, log_files(1).name);
lf = RobotLogFile(log_file_latest);
log_data = lf.getFullLog();

y = log_data.inputs(cntr.inputgroup.y,:);
u = log_data.outputs(cntr.outputgroup.u,:);

Ts = log_data.Ts;

t = (0:size(y,2)-1)*Ts;


end