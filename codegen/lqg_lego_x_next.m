% function x_o = lgq_lego_x_next(x,u)
%     %#codegen
%     A = (coder.const(feval('evalin','base','lgq_controller_gen_A')));
%     B = (coder.const(feval('evalin','base','lgq_controller_gen_B')));
%     x_o = A*x' + B*single(u)';
% end

function x_o = lqg_lego_x_next(x,u)
    %#codegen
    A = (coder.const(feval('evalin','base','lgq_controller_gen_A')));
    B = (coder.const(feval('evalin','base','lgq_controller_gen_B')));
    u_in = single(u);
    u_in(1) = u_in(1)*(8/60);
    u_in(2) = u_in(2)*(8/60);
    x_o = A*x' + B*u_in';
end