function x = newton_Step(x, f, fgrad, fihess)

dx = -fihess(x)*fgrad(x);
gradX = fgrad(x);
t = linesearch(f,x,dx,gradX);
%t = 1;
x = x+t*dx;
