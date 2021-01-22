% [r,x] = fault_detection(raw_data,k_ss,res_ss)
%
% Inputs:
% raw_data: 	data from legoWay [y;u]
% ns: 	s
% rC:	residual generators
%
% Outputs:
% r: 		array of residuals
%
% Uses raw data [y;u] to perform fault detection 

function [r] = fault_detection(raw_data,ns,r_in)
	len = size(raw_data,2);
	r = zeros(size(r_in,1),len);
	
    %reshape rC to handle input data correctly
    rC = raw_ps_convert(ns,r_in);
    
    cur = zeros((ns+1)*5,1);
	for i = ns+2:(len-1)
        for j = 0:ns
           cur(j*5+1:(j+1)*5,1) = raw_data(:,i-(ns-j)) ;
        end
		
		r(:,i) = rC*cur;
	end
end


function rC = raw_ps_convert(ns,r_in)

rC = r_in;
ys =3;
us = 2;
yu = ys+us;
for i = 0:ns
    rC(i*yu+1:i*yu+3,:) = r_in(i*ys+1:(i+1)*ys,:);
    rC(i*yu+4:i*yu+5,:) = r_in(ys*(ns+1)+i*us+1:i*us+2,:)*8/60;
end

end