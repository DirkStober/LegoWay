k = 10;
id_ss = idss(ds('y',:));
data = iddata(y_hist(4:6,:)',u_hist',ds.Ts, 'outputname', {'theta r', 'theta l', 'pitch vel'});
compare(data, id_ss, 10); 