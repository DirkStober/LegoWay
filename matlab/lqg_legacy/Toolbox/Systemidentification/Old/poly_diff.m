function dp = poly_diff(p)

n = length(p);

coeff = (n-1):-1:1;

dp = p(1:end-1).*coeff;