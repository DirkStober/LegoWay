% Get connection by running sudo ./btconnect TEOBALD 0

h = 0;  
while(h ~= 3)
    h = fopen('/dev/rfcomm0');
    pause(1);
end

disp("Opened rfcomm 0 succesfully start the progrm");
raw_data = zeros(5,5000*10);
time =zeros(1,5000);



for i = 1 : 5000
	% It is required to read one byte before reading package
	try
		fread(h,1,'char');
		time(i) = fread(h,1,'int');
        for j = 1:10
    			raw_data(:,(i-1)*10 + j) = fread(h,5,'int');
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


