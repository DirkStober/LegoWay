% This matlab file is used to generate residuals using the parity space approach
%
% [rC,H_us,H_os,v] = parity_space(cs,Ts,ns,sensor)
%
% ds: discrete state space model of plant
% Ts: discrete sample time
% ns: parity space rank s
% sensor: if given only generate residual for that sensor
function [rC,H_us,H_os,v] = parity_space(ds,Ts,ns,sensor)
	% check for which to generate residuals
	if(nargin < 4)
		sensor = 1:size(ds.C,1);
	end
	y_len = size(sensor,2);

	
	d_s = [y_len,2];

	H_us = zeros((ns+1)*d_s(1) , (ns+1)*d_s(2));
	
	A = ds.A;
	B = ds.B;
	C = ds.C(sensor,:);
	%Works because D = 0
	for y = 1:ns
		yi =(y*d_s(1) + 1):(y+1)*d_s(1);
		for x = 0:(y-1) 
			xi = x*d_s(2)+1:(x+1)*d_s(2);
			H_us(yi,xi) = C*(A^(y-1-x))*B;
		end
	end
	o_s = [y_len,size(A,2)];

	H_os = zeros((ns +1)*o_s(1) , o_s(2));
	for y = 0:ns
		yi = (y*o_s(1) + 1):((y+1)*o_s(1));
		H_os(yi,:) = C*(A^y);
	end

	v = null(H_os','r')';		
	% r_s = v*(y(k) - H_us*u(k))
	rC = [v,-v*H_us];

end
