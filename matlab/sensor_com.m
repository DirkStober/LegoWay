
%% Connects to the LegoWay and plots live residuals for the sensors
% Get connection by running sudo ./btconnect TEOBALD 0

h = 0;  
while(h ~= 3)
    h = fopen('/dev/rfcomm0');
    pause(1);
end

disp("Opened rfcomm 0 succesfully start the progrm");



x = zeros(35,1);

raw_data = zeros(5,5000*10);
time =zeros(1,5000);

close
clear title
figure('Name','Residuals for sensor faults')
subplot(311)
title('S 1')
pl = plot(nan,nan);
xline(3000);
yline(8,'r');
yline(-8,'r');
subplot(312)
title('S2')
p2 = plot(nan,nan);
yline(8,'r');
yline(-8,'r');
subplot(313)
title('S2')
p3 = plot(nan,nan);
r = zeros(3,1);
r3_cum = 0;
%%
for i = 1 : 5000
	% It is required to read one byte before reading package
	try
		fread(h,1,'char');
		time(i) = fread(h,1,'int');
        for j = 1:10
    			raw_data(:,(i-1)*10 + j) = fread(h,5,'int');
                k = (i-1)*10 + j;
                if k > 7
                   k = (i-1)*10 + j;
                   r = rC(1:3,:)*[raw_data(:,k-6);raw_data(:,k-5);raw_data(:,k-4);raw_data(:,k-3);raw_data(:,k-2);raw_data(:,k-1);raw_data(:,k)];
                end
                r3_cum = r3_cum + r(3);
                pl.XData(end+1) = k;
                p2.XData(end+1) = k;
                p3.XData(end+1) = k;

                pl.YData(end+1) = r(1);
                p2.YData(end+1) = r(2);
                p3.YData(end+1) = r3_cum;
                drawnow limitrate
        end
	catch
		disp(sprintf('Read %d values',i*10));
		time = time(1:i-1);
		raw_data = raw_data(:,1:(i-1)*10);
		break;
	end
end
% Post process data
disp('Finished Reading Data');
fclose(h)




