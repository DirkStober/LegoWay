% DRAW MODEL
%
% Description:
%   draw_model(x_hist, y_hist, Const, frame_frac) displays a "movie" of the
%   simulation. Frame frac specifies the fraction of the frames that should
%   be drawn. e.g. frame_frac = 5 will display everey 5:th frame of the
%   availible frames.
%
% Arguments:
%   x_hist:     a vector where column n contains the values of the states
%               at sample n. Obtained as output from simulate.m.
%
%   y_hist:     a vector where column n contains the values of the states
%               at sample n. Obtained as output from simulate.m.
%
%   Const:      struct containing the mathematical constants for the model.
%               Obtained from constants.m.
%
%   frame_frac: Frame frac specifies the fraction of the frames that should
%               be drawn.
%
% Example:
%   [x_hist, y_hist] = simulation(...)
%   c = constants();
%   frame_frac = 5;
%   draw_model(x_hist, y_hist, c, frame_frac);
%   
%   will show a movie of the simulation done with simulation.m
%
% See also: simulation, constants


function draw_model(sim_res, frame_frac, Const)

if nargin < 3
    Const = constants();
end

if nargin < 2 || isempty(frame_frac)
    frame_frac = 1;
end

x_hist = sim_res.x;
y_hist = sim_res.y;

N = length(x_hist);
R = Const.R;
L = Const.L;
W = Const.W;
Ts = Const.Ts;
b = linspace(0, 2*pi, 25);
cos_b = cos(b);
y_wheel = R+R*sin(b);

figure(1);
h1 = subplot(1,2,1);
set(h1,'DrawMode','fast');
set(h1,'NextPlot','replace');
set(h1, 'XLim',[-2*R 2*R], 'Ylim', [-2*L, 2*L]);


h2 = subplot(1,2,2);
set(h2,'DrawMode','fast');
set(h2,'NextPlot','replace');


% Draw 
for j = 1:frame_frac:N
    
    theta      = -(y_hist(1,j) + x_hist(3,j));
    y_bodyline = [R (R+2*L*cos(x_hist(3,j)))];
    x_bodyline = [x_hist(1,j) x_hist(1,j)+2*L*sin(x_hist(3,j))];    
   
    x_wheel = x_hist(1,j)+R*cos_b;
    
    anglemarker_x = [x_hist(1,j)+R*cos(theta) x_hist(1,j)+0.8*R*cos(theta)];
    anglemarker_y = [R+R*sin(theta) R+0.8*R*sin(theta)];
    
    % Draw from side
    plot(h1, x_bodyline,y_bodyline, x_wheel, y_wheel, anglemarker_x, anglemarker_y);
    set(h1, 'XLim',[-3*R+x_hist(1,j) 3*R+x_hist(1,j)], 'Ylim', [0, 6*R]);
    title(h1,sprintf('Model from side %.1f sec.', Ts*j));
xlabel(h1,'dist [m]');

    % Draw from above
    plot(h2,W*[cos(x_hist(2,j)) cos(x_hist(2,j)+pi)],W*[sin(x_hist(2,j)) sin(x_hist(2,j)+pi)]);
    set(h2, 'YLim',W*[-1.1 1.1]);
    title(h2,'Model from above');
        xlabel(h2,'x [m]');
ylabel(h2,'y [m]');
    
    %axis([h1 h2], 'equal');
    drawnow

end



