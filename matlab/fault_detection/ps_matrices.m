%Function to generate H_f and H_d for different fault and
% distubance dynamics
% default is generated for F_f = 0, E_f = B 
% => generates residuals for actuator faults
function [H_f,H_d] = ps_matrices(ds,F_f,E_f,E_d,F_d)


sensor = 1:3;
if nargin < 2
	F_f = [zeros(3,2)];
	E_f = [ds.B(:,1:2)];
	
	E_d = [zeros(6,3),diag([1 1 1 1 1 1])];
	F_d = [diag([0.1 0.1 1]),zeros(3,6)] ;
end
ns = 6;
d_s = size(F_f);
H_f = zeros((ns+1)*size(F_f,1),(ns+1)*size(F_f,2));
H_d = zeros((ns+1)*size(F_d,1),(ns+1)*size(F_d,2));

H_f(1:size(F_f,1),1:size(F_f,2)) = F_f;
for y = 1:ns
	yi =(y*d_s(1) + 1):(y+1)*d_s(1);
	for x = 0:(y)
		xi = x*d_s(2)+1:(x+1)*d_s(2);
		if (x == y)
			H_f(yi,xi) = F_f;
		else
			H_f(yi,xi) = ds.C(sensor,:)*(ds.A^x)*E_f;
		end
	end
end
d_s = size(F_d);
H_d(1:size(F_d,1),1:size(F_d,2)) = F_d;
for y = 1:ns
	yi =(y*d_s(1) + 1):(y+1)*d_s(1);
	for x = 0:(y)
		xi = x*d_s(2)+1:(x+1)*d_s(2);
		if x == y
			H_d(yi,xi) = F_d;
		else
			H_d(yi,xi) = ds.C(sensor,:)*(ds.A^x)*E_d;
		end
	end
end
end	
