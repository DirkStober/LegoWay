function t = linesearch(f, x, dx, gradX)

alpha = 0.25;
beta  = 0.5;
t = 1;

while f(x+t*dx) > f(x) + alpha*t*gradX.'*dx
    t = beta*t;
end