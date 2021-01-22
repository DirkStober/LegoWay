function h = get_hipster_gh()  

Const = hipster_constants();

R   = Const.R;      % wheel radius
W   = Const.W;      % half body width
C = [1/R W/R -1 0 0 0;
     1/R -W/R -1 0 0 0;
     0 0 0 0 0 1];
h = @g;

T = diag([1 1 -1]);

    function y = g(x)
        y = T*C*x(1:6) + x(11:13);
        %y = round(180/pi*y)*pi/180;
    end
end
