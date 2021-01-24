%% Testbench for lgq generated code

 x = single(rand(1,8))
 u = randi(5,1,5)
 y = randi(8,1,2)'
 
 y = lqg_lego_y(x,int32([y',u]))
 x_o = lqg_lego_x_next(x,int32([y',u]))
 
 
 