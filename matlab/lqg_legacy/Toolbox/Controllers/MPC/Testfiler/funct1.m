function fh = funct1()

a = 2;
b = 3;

fh = {@f, @g, @h};

    function y = f(x)
        y = (x(1)-a)^6 + (x(2)-b)^2;
    end

    function y = g(x)
        y = [6*(x(1)-a)^5; 2*(x(2)-b)];
    end

    function y = h(x)
        y = [30*(x(1)-a)^4 0; 0 2];
    end

end