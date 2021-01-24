
function y = lqg_lego_y(x,u)
    %#codegen
    C = (coder.const(feval('evalin','base','lgq_controller_gen_C')));
    D = (coder.const(feval('evalin','base','lgq_controller_gen_D')));
    % changed 100 -> 60
    tmp = (C*x' + D*single(u)')*60/8;
    y = int32([saturate_60(tmp(1));saturate_60(tmp(2))]);
end

function d_out = saturate_60(d_in)
    d_out = min(60,max(-60,d_in));
end