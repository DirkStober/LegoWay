h = 0.3;
x = (1:h:10)';


% straight line test
y = x.^2;

[yp_num cut_beg cut_end] = num_diff(y, 1, h);

yp_analytic = 2*x(1+cut_beg:end-cut_end);

plot([yp_num yp_analytic]);


% sin test
y = sin(x);

[yp_num cut_beg cut_end] = num_diff(y, 1, h);

yp_analytic = cos(x(1+cut_beg:end-cut_end));

figure
plot([yp_num yp_analytic]);