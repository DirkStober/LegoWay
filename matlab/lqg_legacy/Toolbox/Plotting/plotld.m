% Function plotld
%
% Plots logdata.
%
% INPUT:
%   data    ->  array of data structures containing the logdata
%   map     ->  cell array where cell (i,j) contains the variable names from data array j to plot in
%               plot i.
%   h       ->  vector of axes handles, where element i is the handle to plot i.
%   legStyle->  one of {'off','name','reg','regname'}
%               off - no legend is displayed
%               name - state names are shown in legend
%               reg - regulator names are shown in legend
%               regname - regulator and state names are shown in legend
%   numcol  ->  number of columns in the subplot grid.
%   unit    ->  cell array of strings with units to put as ylable
%   tit     ->  cell array of strings to put as title in plots.
%
%
% Example:
% % Assume that logdata1 contains the names 'a1', 'a2', 'a3', and logdata2 contains
% % the names 'b1', 'b2', 'b3'. The following code will plot a1 and b1 in plot 1,
% % a1 and a2 in plot 2, b2 in plot 3, and a3 and b3 in plot 4.
% data(1) = logdata1;
% data(2) = logdata2;
% 
% map = {{'a1'},{'b1'};
%       {'a1','a2'},{};
%       {''}{'b2'};
%       {'a3'}{'b3'};
%
% plotld(data,map);
%        

function plotld(data, map, h, legStyle, numcol, unit, tit, plot_mode, nsec)

if isempty(data) || isempty(data(1).ctrl_loop_start_ms)
    return;
end

nd = length(data);

np = size(map,1); % number of plots

if np == 0
    return;
end

if nargin < 3
    h = [];
end

if nargin < 4
    legStyle = 'off';
end

if nargin < 5
    numcol = 1;
end

if nargin < 6
   unit = []; 
end

if nargin < 7
   tit = []; 
end

if nargin < 8
   plot_mode = 'all'; 
end

if nargin < 9
    nsec = [];
end

nvars = zeros(np,1);

% Clear names that are not in the data
for i = 1:np
    for j = 1:nd
        names = [data(j).StateName; data(j).InputName; data(j).OutputName];
        mapnames = map{i,j};
        if ~isempty(mapnames)
            ix = ismember(mapnames,names);
            map{i,j} = mapnames(ix);
            % Number of variables that should be plotted in plot i
            nvars(i) = nvars(i) + length(ix);
        else
            map{i,j} = [];
        end
            
        
    end
end


% If no handles are given, create new figure.
if isempty(h)
    figure;    
    numrow = ceil(np/numcol);
    for i = 1:np
        h(i) = subplot(numrow,numcol,i);
    end
else
    if(length(h) ~= np)
       error('Number of handles must agree with number of mapping elements');
   end
end

colors = [0 0 1;
          0 1 0;
          1 0 0;
          1 1 0;
          0 1 1;
          1 0 1];
  
cc_normal = ones(np,1);
cc_ref = ones(np,1);
cc_hat = ones(np,1);
legend_names = cell(np,1);
units = cell(np,1);

linenr = ones(np,1);
line_handles = cell(np,1);
used_lhandles = cell(np,1);

% Number of lines in subplot i
nl = zeros(np,1);

for j = 1:nd
    % 
    xyu_data = [data(j).states; data(j).inputs; data(j).outputs];
    unit_data = [data(j).StateUnit; data(j).InputUnit; data(j).OutputUnit];
    names = [data(j).StateName; data(j).InputName; data(j).OutputName];
    clsm = data(j).ctrl_loop_start_ms;
    
    % Compute indexes to plot
    [ix_from, ix_to] = time_vec_ix(clsm, plot_mode, nsec);
    samplevec = ix_from:ix_to;
    
    % Remove line in between two points with a larger gap than 1/2 second
    ix = find((clsm(2:end)- clsm(1:end-1)) > 500);
    xyu_data(:,ix) = NaN;
    xyu_data(:,ix+1) = NaN;
    
    % Subtract start time and converte to seconds
    timevec = (clsm(samplevec)-clsm(1))/1000; 
   
    for i = 1:np 
        variables_to_plot = map{i,j};
        
       

        line_handles{i} = get(h(i),'Children');
        nl(i) = length(line_handles{i}); 
        
        % Go throug variables that should be plotted one by one
        for k = 1:length(variables_to_plot)
            var_to_plot = variables_to_plot(k);
            ix = names2index(names, var_to_plot);
            
            % If several varaibles with the same name are present, plot
            % only the first one
            ix = ix(1);
            
            % Ydata for varaible to plot
            y = xyu_data(ix,samplevec);
            
            if isref(var_to_plot{1})
                c = [1/cc_ref(i) 0 1-1/cc_ref(i)];
                cc_ref(i) = cc_ref(i) + 1;
            elseif ishat(var_to_plot{1})
                c = [0 1/cc_hat(i) 1-1/cc_hat(i)];
                cc_hat(i) = cc_hat(i) + 1;
            else
                c = [0 1-1/cc_normal(i) 1/cc_normal(i)];
                cc_normal(i) = cc_normal(i) + 1;
            end
                
            
            % If number of lines in the plot is lower than the number of
            % "available" lines, use an old lineobject for the plotting
            if linenr(i) <= nl(i)
                         
                set(line_handles{i}(linenr(i)),'XData',timevec, 'YData', y, 'Color', c, 'displayname', nameConverter(var_to_plot{1}));
                
                % Remember which line handles that have been used
                used_lhandles{i} = [used_lhandles{i} line_handles{i}(linenr(i))];
            
            % Otherwise create a new lineobject
            else
                lh = line(timevec,y,'Parent',h(i), 'Color', c, 'displayname', nameConverter(var_to_plot{1}));
                line_handles{i} = [line_handles{i}; lh];
                used_lhandles{i} = [used_lhandles{i} lh];
            end
            
            % Increment the number of lines that have been plotted in plot
            % i
            linenr(i) = linenr(i)+1;
            %cc_normal(i) = cc_normal(i) + 1;
            legend_names{i} = [legend_names{i} var_to_plot];
            units{i} = [units{i} unit_data(ix)];  
        end   
    end
end


for i = 1:np
    %subplot(numrow,numcol,i);
    switch legStyle
        case 'name'
            lh = legend(h(i));
            if strcmp(get(lh,'Visible'),'off') || isempty(lh)
                legend(h(i),'show');
                legend(h(i),'-DynamicLegend');
            end
        case 'off'
            legend(h(i),'off');
    end          
end


% Clear unused line objects
temp_handles = cell(np,1);
for i=1:np
    ix = ismember(line_handles{i}, used_lhandles{i});
    delete(line_handles{i}(~ix));
    temp_handles{i} = line_handles{i};
    line_handles{i}(~ix) = [];
end

% Get handles to the present legends in the figure
%fig_handle = get(h(1),'Parent');
%leg_handles = findobj(fig_handle,'Type','axes','Tag','legend');




% if strcmp(legStyle,'name')
%     for i = 1:np                
%           
%          Find legend associated with axes object h(i)
%          legend_handle = [];
%          if ~isempty(leg_handles)
%              for j = leg_handles(:)'
%                 ud = get(j,'UserData');
%                  if ud.PlotHandle == h(i)
%                     legend_handle = j;
%                  end
%              end
%          end
%         
%          Is there a legend in the subplot?
%          if ~isempty(legend_handle)
%              Line series object associated with the legend handle
%              ud = get(legend_handle,'UserData');
%              
%              llh = ud.handles;
%              lls = ud.lstrings;
%              
%              If not all line series objects in the subplot are associated with 
%              the current legend, make a new legend. Else do nothing, everything is already set
%              if length(llh) == length(used_lhandles{i}) 
%                  if ~all(strcmp(lls,legend_names{i}'))% ~isempty(setxor(llh,used_lhandles{i}))
%                      If there is a line object to make a legend for
%                      if linenr(i) > 1
%                         ix = find(leg_handles == legend_handle);
%                         leg_handles(ix) = legend(line_handles{i}, legend_names{i},'Interpreter','None');
%                      else
%                          Remove the legend
%                          ix = find(leg_handles == legend_handle);
%                          delete(legend_handle);
%                          leg_handles(ix) = [];   
%                      end
%                  end
%              else
%                  if linenr(i) > 1
%                     ix = find(leg_handles == legend_handle);
%                     leg_handles(ix) = legend(line_handles{i}, legend_names{i},'Interpreter','None');
%                  end
%              end
%              
%          Else make a new legend
%          else
%              If there is a lineobject to make a legend for
%              if linenr(i) > 1
%                 legh = legend(line_handles{i}, legend_names{i},'Interpreter','None');
%                 leg_handles = [leg_handles; legh];
%              end
%          end
%     end
% else
%     delete(leg_handles);
% end


for i = 1:np
    axis(h(i),'tight');
    set(h(i),'XGrid','on','YGrid','on');
    if ~isempty(tit)
        th = get(h(i),'Title');
        if ~strcmp(get(th,'String'), tit(i))
            set(th,'String',tit(i));
        end
    end
    
    xh = get(h(i),'Xlabel');
    if ~strcmp(get(xh,'String'), 'Time [s]')
        set(xh,'String','Time [s]');
    end
    
    nu = length(units{i});
    if nu > 0
        test_unit = units{i}{1};        
        all_same = true;
        
        test_label = test_unit;
        for j = 2:nu
            if ~strcmp(test_unit, units{i}{j})
                all_same = false;
            end
            test_label = [test_label ', ' units{i}{j}];
        end

        yh = get(h(i),'Ylabel');
        if all_same
            if ~strcmp(get(yh,'String'), test_unit)
                set(yh,'String',test_unit);
            end
        else
            if ~strcmp(get(yh,'String'), test_label)
                set(yh,'String',test_label);
            end
        end
    end
end










