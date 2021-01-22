function cs = getHipsterSS()
    perfindex_x = [2 4];
    perfindex_y = [];
    hm = getHipsterModel();
    % Working point
    x0 = zeros(hm.nx,1);
    u0 = zeros(hm.nu,1);
    cs = nonlinear2ss(hm,x0,u0,perfindex_x,perfindex_y);
end