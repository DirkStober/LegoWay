function varargout = plot_gui2(varargin)
% PLOT_GUI2 M-file for plot_gui2.fig
%      PLOT_GUI2, by itself, creates a new PLOT_GUI2 or raises the existing
%      singleton*.
%
%      H = PLOT_GUI2 returns the handle to a new PLOT_GUI2 or the handle to
%      the existing singleton*.
%
%      PLOT_GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_GUI2.M with the given input arguments.
%
%      PLOT_GUI2('Property','Value',...) creates a new PLOT_GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot_gui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot_gui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot_gui2

% Last Modified by GUIDE v2.5 18-Jun-2015 11:25:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_gui2_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_gui2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before plot_gui2 is made visible.
function plot_gui2_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to plot_gui2 (see VARARGIN)
    
    %addpath Toolbox/MiscTools/

    % Choose default command line output for plot_gui2
    handles.output = hObject;    
    
    global plot_handles;
    plot_handles = [];
    
    % Init timers once and for all
    global timer_live_handle;
    timer_live_handle = timer(...
        'TimerFcn', {@on_live_timer,hObject}, ...
        'Period', 0.5, ...
        'ExecutionMode', 'fixedSpacing', ...
        'StartDelay', 0.5);
    
    global timer_status_handle;
    timer_status_handle = timer(...
        'TimerFcn', {@on_status_timer,hObject}, ...
        'Period', 2, ...
        'ExecutionMode', 'fixedSpacing', ...
        'StartDelay', 2);
    start(timer_status_handle);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes plot_gui2 wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    % Fill the "Signal" list with signals from input parameter list
    if length(varargin) >= 2
        handles.log_path = varargin{2};
    else
        error('Log path must be specified, eg. plot_gui2([], ''c:\LogDir'')');
    end
    
    % Fill the "Signal" list with signals from input parameter list
    if length(varargin) >= 3
        populateSignalList(handles.lstSignals, varargin{3});
    end
    
    % Show sidebar or not?
    if length(varargin) >= 4
        set(handles.panelSidebar, 'Visible', varargin{4});
    end
    
    % Select a certain log file?
    if length(varargin) >= 5
        handles.select_log_file = varargin{5};
    end
    
    % Show simulation button?
    enable_sim = 'on';
    if length(varargin) >= 6
        if ~isempty(varargin{6})
            enable_sim = varargin{6};
        end
    end
    set(handles.btnSimulate, 'Visible', enable_sim);
    set(handles.btnSimulate, 'Enable',  enable_sim);
    
    % Reference mappings
    handles.ref_mappings = struct('left', [0 +0.2], 'right', [0 -0.2], 'up', [1 0.1], 'down', [1 -0.1]);
    if length(varargin) >= 7
        handles.ref_mappings = varargin{7};
    else
        % Default for TWIP
        handles.ref_mappings = struct('left', [0 +0.2], 'right', [0 -0.2], 'up', [1 +0.1], 'down', [1 -0.1]);
    end
    
    if isempty(handles.ref_mappings) || ~isfield(handles.ref_mappings, 'up')
        set(handles.btnUp, 'Visible', 'off');
    end
    if isempty(handles.ref_mappings) || ~isfield(handles.ref_mappings, 'down')
        set(handles.btnDown, 'Visible', 'off');
    end
    if isempty(handles.ref_mappings) || ~isfield(handles.ref_mappings, 'left')
        set(handles.btnLeft, 'Visible', 'off');
    end
    if isempty(handles.ref_mappings) || ~isfield(handles.ref_mappings, 'right')
        set(handles.btnRight, 'Visible', 'off');
    end
    
    % Readme text displayed as Start-info when clicking at Start button
    handles.startup_readme_str = '';
    if length(varargin) >= 8
        handles.startup_readme_str = varargin{8};
    end
    
    % Create toolbar
    handles.hToolbar = uitoolbar(hObject);
    
    % Sidebar toolbar button
    handles.hToolBtnSidebar = uitoggletool(handles.hToolbar, ...
        'CData', imread('Icons/settings.png'), ...
        'TooltipString', 'Show/hide "Plot options"', ...
        'HandleVisibility', 'off', ...
        'OnCallback',  @toolBtnSidebar_OnCallback, ...
        'OffCallback', @toolBtnSidebar_OffCallback);

    % Control toolbar button
    handles.hToolBtnControl = uitoggletool(handles.hToolbar, ...
        'CData', imread('Icons/wheel.png'), ...
        'TooltipString', 'Show/hide "Control bar"', ...
        'HandleVisibility', 'off', ...
        'OnCallback',  @toolBtnControl_OnCallback, ...
        'OffCallback', @toolBtnControl_OffCallback);    
    
    % 10 sec time window?
    handles.hToolBtn10sec = uitoggletool(handles.hToolbar, ...
        'CData', imread('Icons/10_sec.png'), ...
        'TooltipString', 'Only log data from the last 10 seconds are shown now. Click to show everything.', ...
        'HandleVisibility', 'off', ...
        'Separator', 'on', ...
        'OnCallback',  @toolBtn10sec_Callback, ...
        'OffCallback', @toolBtn10sec_Callback);
    
    % Legend toolbar button
    handles.hToolBtnLegend = uitoggletool(handles.hToolbar, ...
        'CData', imread('Icons/legend.png'), ...
        'TooltipString', 'Show/hide legend text', ...
        'HandleVisibility', 'off', ...
        'State', 'on', ...
        'ClickedCallback',  @toolBtnLegend_Callback);
%         'OffCallback', @toolBtnLegend_OffCallback);
    
    % Live plot toolbar button
    handles.hToolBtnLive = uitoggletool(handles.hToolbar, ...
        'CData', imread('Icons/live_plotting2.png'), ...
        'TooltipString', 'Toggle live plotting', ...
        'HandleVisibility', 'off', ...
        'Separator', 'on', ...
        'OnCallback',  @toolBtnLive_OnCallback, ...
        'OffCallback', @toolBtnLive_OffCallback);
    
    % "Refresh plot" toolbar button
    handles.hToolBtnRefreshPlots = uipushtool(handles.hToolbar, ...
        'CData', imread('Icons/manual_refresh.png'), ...
        'TooltipString', 'Refresh plots', ...
        'HandleVisibility', 'off', ...
        'ClickedCallback',  @toolBtnRefreshPlots_Callback);
    
    % "New log file" toolbar button
    handles.hToolBtnNewLogFile = uipushtool(handles.hToolbar, ...
        'CData', imread('Icons/new_sheet.png'), ...
        'TooltipString', 'Continue to save log data in new file', ...
        'HandleVisibility', 'off', ...
        'ClickedCallback',  @toolBtnNewLogFile_Callback);
    
    % Connection Manager toolbar button
    handles.hToolBtnConnectionManager = uipushtool(handles.hToolbar, ...
        'CData', imread('Icons/connection_manager.png'), ...
        'TooltipString', 'Launch Connection Manager (advanced)', ...
        'HandleVisibility', 'off', ...
        'Separator', 'on', ...
        'ClickedCallback',  @toolBtnConnectionManager_Callback);
    
    % Disconnect toolbar button
    handles.hToolBtnDisconnect = uipushtool(handles.hToolbar, ...
        'CData', imread('Icons/remove.png'), ...
        'TooltipString', 'Disconnect from robot', ...
        'HandleVisibility', 'off', ...
        'ClickedCallback',  @toolBtnDisconnect_Callback);
    
    set(handles.hToolBtnControl, 'State', 'on');
    
    set(handles.btnMoveUp,   'CData', imread('Icons/arrow_up.png'));
    set(handles.btnRemove,   'CData', imread('Icons/remove.png'));
    set(handles.btnMoveDown, 'CData', imread('Icons/arrow_down.png'));
    
    pollAndUpdateStatus(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Create context menu for log file list
    cmenu = uicontextmenu;
    uimenu(cmenu, 'Label', 'Remove this log file...', 'Callback', {@contextMenuRem,false});
    uimenu(cmenu, 'Label', 'Remove all log files...', 'Callback', {@contextMenuRem,true});
    uimenu(cmenu, 'Label', 'Open containing folder', 'Separator', 'on', 'Callback', @contextMenuOpenFolder);
    set(handles.lstFiles, 'UIContextMenu', cmenu);
    
    refreshFilelist(handles);
    lstFiles_Callback(handles.lstFiles, [], handles);

    % Start plot update timer
    %startTimer(handles);
    
    % Enable live update by default if Sidebar is hidden
    if strcmp(get(handles.panelSidebar, 'Visible'), 'off')
        drawnow;
        set(handles.hToolBtnSidebar, 'State', 'off');
        %set(handles.hToolBtnLive, 'State', 'on');
        %handles = startTimer(handles.panelSidebar, handles);
        guidata(hObject, handles);
    else
        set(handles.hToolBtnSidebar, 'State', 'on');
    end
    
    % Update handles structure
    %guidata(hObject, handles);
    
% Populates the signal list with signals from 'signals'   
function populateSignalList(hSigList, signals)
    list = {};
    for cur_plot=signals.' 
        if isempty(list)
            list = cur_plot{1};
        else
            list = [list ; '------' ; cur_plot{1}];
        end
    end
    
    set(hSigList, 'String', list);
    
    
% The check status timer callback    
function on_status_timer(obj, event, hFigure)
    try
        global hc
    %     'timer'
        if ~isempty(hc) && hc.isvalid()
            if hc.isConnectionLost()
                % Get the handles to all objects
                handles = guidata(hFigure);
    %             'timer: fel'

                clear GLOBAL hc;
                pollAndUpdateStatus(handles);
                msgbox('Connection to robot lost. Please turn off and on the NXT brick and try to reconnect.');
            end
        end
    catch e
        
    end
    
    
% The live-update timer callback    
function on_live_timer(obj, event, hFigure)
    try
        % Get the handles to all objects
        handles = guidata(hFigure);

        % Refresh the file list (new files might have been created)
        refreshFilelist(handles);

        % Select the most recent file
        set(handles.lstFiles, 'Value', 1);

        updatePlotsFromGUI(handles);
    catch e
%         disp(e);
    end
    

% --- Outputs from this function are returned to the command line.
function varargout = plot_gui2_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on selection change in lstSignals.
function lstSignals_Callback(hObject, eventdata, handles)
    % hObject    handle to lstSignals (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns lstSignals contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from lstSignals
    
    
% --- Executes during object creation, after setting all properties.
function lstSignals_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lstSignals (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in cmbStates.
function cmbStates_Callback(hObject, eventdata, handles)
    % hObject    handle to cmbStates (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns cmbStates contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from cmbStates


% --- Executes during object creation, after setting all properties.
function cmbStates_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to cmbStates (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in cmbInputs.
function cmbInputs_Callback(hObject, eventdata, handles)
    % hObject    handle to cmbInputs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns cmbInputs contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from cmbInputs


% --- Executes during object creation, after setting all properties.
function cmbInputs_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to cmbInputs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in cmbOutputs.
function cmbOutputs_Callback(hObject, eventdata, handles)
    % hObject    handle to cmbOutputs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns cmbOutputs contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from cmbOutputs


% --- Executes during object creation, after setting all properties.
function cmbOutputs_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to cmbOutputs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in cmbStates.
function SOI_Callback(hObject, eventdata, handles)
    % hObject    handle to cmbStates (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get var. name
    contents = get(hObject,'String');
    if size(contents, 1) > 1
        val = contents{get(hObject,'Value')};
    else
        val = contents;
    end
    
    % Get 

    % Add signal at the end of listbox
    set(handles.lstSignals, ...
                'String', [get(handles.lstSignals, 'String') ; val], ...
                'Value', 1);

    % Create and update plots
    updatePlotsFromGUI(handles);


function bounds = calcPlotBounds(handles)
    posSidebar = get(handles.panelSidebar, 'Position');
    
    % assume the size of the side bar is zero if it's not visible
    if strcmpi(get(handles.panelSidebar, 'Visible'), 'off')
        posSidebar(3) = 0;
        posSidebar(4) = 0;
    end
    bounds.x_min = posSidebar(1) + posSidebar(3) + 50;
    
    posControl = get(handles.panelControl, 'Position');
    
    % assume the size of the control bar is zero if it's not visible
    if strcmpi(get(handles.panelControl, 'Visible'), 'off')
        posControl(3) = 0;
        posControl(4) = 0;
    end
    
    posFig = get(handles.figure1, 'Position');
    bounds.x_max = posFig(3) - posControl(3) - 30;
    bounds.y_max = posFig(4) - 30;    
    bounds.y_min = 60;
    
    
function handles = stopTimer(th, handles)
%     fprintf('Stopping timer... ');
    if ~isempty(th) && isvalid(th)
        while strcmp(th.running, 'on')
            stop(th);
            pause(0.01);
        end
%         delete(th)
%         while isvalid(th) %strcmp(th.running, 'on')
%             pause(0.01);
%         end
        %pause(1);
    end
    %set(handles.hToolBtnLive, 'State', 'off');
    set(handles.lstFiles, 'Enable', 'on');
%     set(handles.hToolBtnLegend, 'Enable', 'on');
%     set(handles.figure1, 'ToolBar', 'figure');
%     set(handles.figure1, 'MenuBar', 'figure');
%     fprintf('stopped!\n');
    
function handles = startTimer(th, hParent, handles)
%     fprintf('Starting timer... ');
    handles = stopTimer(th, handles);
%     new_th = timer(...
%         'TimerFcn', @on_timer, ...
%         'Period', 0.5, ...
%         'ExecutionMode', 'fixedSpacing', ...
%         'UserData', hParent, ...%gcbo, ...
%         'StartDelay', 0.5);
    start(th);
    %set(handles.hToolBtnLive, 'State', 'on');
    set(handles.lstFiles, 'Enable', 'off');
%     set(handles.hToolBtnLegend, 'Enable', 'off');
%     set(handles.figure1, 'ToolBar', 'none');
%     set(handles.figure1, 'MenuBar', 'none');
%     fprintf('started!\n');


function updatePlotsFromGUI(handles)
    % Parse signals
    signals = getSignals(handles.lstSignals);

    % Get selected log filename
    filename = getLogFilename(handles.lstFiles, handles.log_path);
    
    % Read the entire log file
    if ~isempty(filename)
        lf = newLogFileObj(filename);
        log_data = lf.getFullLog();
        clear lf
    else
        log_data = [];
    end
    
    % Plot in sliding window or not?
    time_window_style.cmd = 'all';
    time_window_style.arg = 0;
    if strcmp(get(handles.hToolBtn10sec, 'State'), 'on')
        time_window_style.cmd = 'last_nsec';
        time_window_style.arg = 10;
    end
    
    % Legend style
    show_legend = strcmp(get(handles.hToolBtnLegend, 'State'), 'on');
    
    updatePlots(log_data, signals, handles, show_legend, [], time_window_style);

function updatePlots(log_data, signals,  handles, show_legend, titles, time_window_style)
    if nargin < 6
        time_window_style.cmd = 'all';
        time_window_style.arg = 0;
    end

	global plot_handles;
    
    % Clear if any plot_handle is invalid
    if ~all(ishandle(plot_handles))
        plot_handles = [];
    end

    % Need to create new plots?
    if length(plot_handles) ~= length(signals)
%         disp('Skapar nya plottar');
        delete(plot_handles);

        bounds = calcPlotBounds(handles);
        pos = calcPlotPositions(length(signals), bounds);
        plot_handles = createPlots(handles.figure1, pos);
    end
    
    %drawnow; %pertest
    
    if show_legend
        legend_style = 'name';
    else
        legend_style = 'off';
    end
    
    % Plot the signals
%     try        
        plotld(log_data, signals, plot_handles, legend_style, 1, [], titles, time_window_style.cmd, time_window_style.arg);
%     catch e
%     end


function pos = calcPlotPositions(num_plots, bounds)
    space_height = 80;
    
    % Calc sizes
    x_s = bounds.x_max - bounds.x_min;
    y_s = ((bounds.y_max-bounds.y_min) - space_height*(num_plots-1)) / num_plots;
    
    x_p = bounds.x_min;
    y_p = bounds.y_max - y_s;
    
    pos = zeros(num_plots,4);
    for k=1:num_plots
        % Add position
        pos(k,:) = [x_p y_p x_s y_s];        
        
        y_p = y_p - y_s-space_height;
        y_p = max(0, y_p);
    end

function plot_handles = createPlots(h_parent, pos)
    % Create plots
    plot_handles = [];
    for k=1:size(pos,1)
        % Add plot
        cur_pos = pos(k,:);
        h = axes('Parent', h_parent, 'Units', 'pixels', 'Position', cur_pos);
        
        plot_handles = [plot_handles h];
    end    
    
    
function filename = getLogFilename(lstFiles, log_path)
    % Get log filename
    c = get(lstFiles, 'String');

    len = size(c, 1);
    if len > 1
        filename = c{get(lstFiles, 'Value')};
    elseif len == 1
        filename = cell2mat(c);
    else
        filename = '';
    end
    
    % Include the log path as well
    if ~isempty(filename)
        filename = fullfile(log_path, filename);
    end

% Parses the signal list box and returns the result in a cell array    
function signals = getSignals(lstToShow)
    signals = {};
    j = 1;
    for k=get(lstToShow, 'String')'
        if strcmp(k, '------')
            if ~isempty(signals)
                j = j + 1;
            end
        elseif length(signals) ~= j
            signals{j} = k;
        else
            signals{j} = [signals{j} ; k];
        end
    end
    
    signals = signals.';
    
    
function obj = getObjFromWorkspace(name)
    obj = [];
    
    if evalin('base', ['exist(''' name ''', ''var'')'])
        obj = evalin('base', name);
    end
        

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %%%%%%%%%%%%%%%%%%%%%
    % Adjust sidebars
    %%%%%%%%%%%%%%%%%%%%%
    % Get currents sizes/positions
    posFig         = get(handles.figure1, 'Position');
    posPanControl  = get(handles.panelControl, 'Position');
    posPanSidebar  = get(handles.panelSidebar, 'Position');
    posLogfiles    = get(handles.panLogFiles, 'Position');
    posController  = get(handles.panController, 'Position');
    
    % Adjust Control panel
    if strcmpi(get(handles.panelControl, 'Visible'), 'on')
        % Make Control panel cover entire height
        posPanControl(1) = posFig(3) - posPanControl(3);
        posPanControl(2) = 0;
        posPanControl(4) = posFig(4);
        set(handles.panelControl, 'Position', posPanControl);
        
        % Move up all children in panel
        controller_section_offset = posFig(4) - posController(2) - posController(4) - 20;
        for h=get(handles.panelControl, 'Children').'
            pos = get(h, 'Position');
            pos(2) = pos(2) + controller_section_offset;
            set(h, 'Position', pos);
        end
    end
    
    % Adjust Sidebar
    if strcmpi(get(handles.panelSidebar, 'Visible'), 'on')
        % Make sidebar cover entire height
        posPanSidebar(2) = 0;
        posPanSidebar(4) = posFig(4);
        set(handles.panelSidebar, 'Position', posPanSidebar);
        
        % Move up all children in panel
        logfiles_offset = posFig(4) - posLogfiles(2) - posLogfiles(4) - 20;
        for h=get(handles.panelSidebar, 'Children').'
            pos = get(h, 'Position');
            pos(2) = pos(2) + logfiles_offset;
            set(h, 'Position', pos);
        end
    end
    
    global plot_handles;
    num_plots = length(plot_handles);
    bounds = calcPlotBounds(handles);
    pos = calcPlotPositions(num_plots, bounds);
    for k=1:num_plots
        set(plot_handles(k), 'Position', pos(k,:));
    end
    

% --- Executes on selection change in cmbFiles.
function cmbFiles_Callback(hObject, eventdata, handles)
    % hObject    handle to cmbFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns cmbFiles contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from cmbFiles


% --- Executes during object creation, after setting all properties.
function cmbFiles_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to cmbFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in btnRefresh.
function btnRefresh_Callback(hObject, eventdata, handles)
    % hObject    handle to btnRefresh (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    refreshFilelist(handles);
    lstFiles_Callback(handles.lstFiles, [], handles);
    

function all_files = getLogFilesSortedByDate(path)
    % Grab a list of log files in the 'log_path' dir
    log_files = dir(fullfile(path, '*.log'));
    mat_files = dir(fullfile(path, '*.mat'));
    all_files = [log_files ; mat_files];
    [~, indices] = sort([all_files.datenum], 2, 'descend');
    all_files = all_files(indices);
    
function [obj, type] = newLogFileObj(filename)
    [~, ~, ext] = fileparts(filename);
    switch ext
        case '.log'
            type = 'Robot';
            obj = RobotLogFile(filename);
        case '.mat'
            type = 'Simulation';
            obj = SimLogFile(filename);
        otherwise
            error(['Unknown filename extension: ' ext]);
    end
    
function refreshFilelist(handles)
    % Get a list of log files in the 'log_path' dir
    files = getLogFilesSortedByDate(handles.log_path);
    
    % Update the file list with the list
    if ~isempty(files)
        set(handles.lstFiles, 'String', {files.name});
        
%         % Select the last file?
%         if strcmp(handles.select_log_file, 'last_file')
%             set(handles.lstFiles, 'Value', length(files));
%         end
    else
        set(handles.lstFiles, 'String', '', 'Value', 1);
    end
    
    % Call callback for the Filelist
    lstFiles_Callback(handles.lstFiles, [], handles);


% --- Executes on selection change in lstFiles.
function lstFiles_Callback(hObject, eventdata, handles)
    % hObject    handle to lstFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = get(hObject,'String') returns lstFiles contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from lstFiles

    % Get selected log file
    log_files = get(hObject,'String');
    
    selected_log_file = '';
    type = '';
    reg_name = '';
    state_name = '';
    input_name = '';
    output_name = '';
    if ~isempty(log_files)
        selected_log_file = log_files{get(hObject,'Value')};

        % Read the signal names from the selected log file
        [lf, type] = newLogFileObj(fullfile(handles.log_path, selected_log_file));
        log_header = lf.getHeader();
        clear lf;
        
        if ~isempty(log_header)
            reg_name = log_header.RegName;
            state_name = log_header.StateName;
            input_name = log_header.InputName;
            output_name = log_header.OutputName;
        end
    end
    
    % Populate 'state', 'input' and 'output' pull-down menus
    set(handles.lblRegInfoFilename, 'String', selected_log_file);
    set(handles.lblRegInfoDataSource, 'String', type);
    set(handles.lblRegInfoRegName, 'String', reg_name);

    if ~isempty(state_name)
        set(handles.cmbStates,  'String', state_name);
        set(handles.cmbStates,  'Visible', 'on');            
    else
        set(handles.cmbStates,  'Visible', 'off');
    end

    if ~isempty(input_name)
        set(handles.cmbInputs,  'String', input_name);
        set(handles.cmbInputs,  'Visible', 'on');            
    else
        set(handles.cmbInputs,  'Visible', 'off');
    end

    if ~isempty(output_name)            
        set(handles.cmbOutputs,  'String', output_name);
        set(handles.cmbOutputs,  'Visible', 'on');
    else
        set(handles.cmbOutputs,  'Visible', 'off');
    end
    
    updatePlotsFromGUI(handles);

    
% --- Executes during object creation, after setting all properties.
function lstFiles_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lstFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in btnNewPlot.
function btnNewPlot_Callback(hObject, eventdata, handles)
    % hObject    handle to btnNewPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Add a "New plot" at the end of listbox
    set(handles.lstSignals, ...
                'String', [get(handles.lstSignals, 'String') ; {'------'}], ...
                'Value', 1);


% --- Executes on button press in btnMoveUp.
function btnMoveUp_Callback(hObject, eventdata, handles)
    % hObject    handle to btnMoveUp (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    val = get(handles.lstSignals, 'Value');
    s = get(handles.lstSignals, 'String');
    if val > 1
        tmp = s{val};
        s{val} = s{val-1};
        s{val-1} = tmp;
        set(handles.lstSignals, 'String', s, 'Value', val-1);
        
        % Create and update plots
        updatePlotsFromGUI(handles);
    end


% --- Executes on button press in btnRemove.
function btnRemove_Callback(hObject, eventdata, handles)
    % hObject    handle to btnRemove (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    contents = get(handles.lstSignals, 'String'); %returns lstToShow contents as cell array
    ind = get(handles.lstSignals, 'Value');
    if ind > 0
        num_items = size(contents, 1);
        if num_items > 1
            val = contents{ind}; %returns selected item
        else
            val = contents;
        end

        % Remove selected item from list
        set(handles.lstSignals, 'String', [contents(1:ind-1) ; contents(ind+1:end)], 'Value', min(1, num_items-1));
    end

    % Create and update plots
    updatePlotsFromGUI(handles);

    
% --- Executes on button press in btnMoveDown.
function btnMoveDown_Callback(hObject, eventdata, handles)
    % hObject    handle to btnMoveDown (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    val = get(handles.lstSignals, 'Value');
    s = get(handles.lstSignals, 'String');
    if val < size(s,1)
        tmp = s{val};
        s{val} = s{val+1};
        s{val+1} = tmp;
        set(handles.lstSignals, 'String', s, 'Value', val+1);
        
        % Create and update plots
        updatePlotsFromGUI(handles);
    end
    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Stop and delete timer
    global timer_status_handle;    
    stop(timer_status_handle);
    delete(timer_status_handle);

    global timer_live_handle;
    handles = stopTimer(timer_live_handle, handles);
    delete(timer_live_handle);

    guidata(hObject, handles);

    % Hint: delete(hObject) closes the figure
    delete(hObject);
%     'Close: Deleted'

function toolBtnLive_OnCallback(hObject, eventdata)
% 'live on'
    global timer_live_handle;
    handles = guidata(hObject);
    set(handles.hToolBtnRefreshPlots, 'Enable', 'off');
    handles = startTimer(timer_live_handle, hObject, handles);
    guidata(hObject, handles);
    
function toolBtnLive_OffCallback(hObject, eventdata)
%     'live off'
    global timer_live_handle;
    handles = guidata(hObject);
    handles = stopTimer(timer_live_handle, handles);
    set(handles.hToolBtnRefreshPlots, 'Enable', 'on');
    guidata(hObject, handles);

function toolBtnSidebar_OnCallback(hObject, eventdata)
    handles = guidata(hObject);
    set(handles.panelSidebar, 'Visible', 'on');
    figure1_ResizeFcn(handles.figure1, [], handles);
    guidata(hObject, handles);
    
function toolBtnSidebar_OffCallback(hObject, eventdata)
    handles = guidata(hObject);
    set(handles.panelSidebar, 'Visible', 'off');
    figure1_ResizeFcn(handles.figure1, [], handles);
    guidata(hObject, handles);
    
function toolBtnControl_OnCallback(hObject, eventdata)
    handles = guidata(hObject);
    set(handles.panelControl, 'Visible', 'on');
    figure1_ResizeFcn(handles.figure1, [], handles);
    guidata(hObject, handles);
    
function toolBtnControl_OffCallback(hObject, eventdata)
    handles = guidata(hObject);
    set(handles.panelControl, 'Visible', 'off');
    figure1_ResizeFcn(handles.figure1, [], handles);
    guidata(hObject, handles);
    
function toolBtnLegend_Callback(hObject, eventdata)
    handles = guidata(hObject);
    updatePlotsFromGUI(handles);        
    guidata(hObject, handles);
    
function toolBtnRefreshPlots_Callback(hObject, eventdata)
    handles = guidata(hObject);
%     profile on
    if strcmp(get(handles.hToolBtnLive, 'State'), 'off')
        updatePlotsFromGUI(handles);
    end
%     profile viewer
    guidata(hObject, handles);
        
function toolBtnConnectionManager_Callback(hObject, eventdata)
    RobotConnect([], false);
    
function toolBtnDisconnect_Callback(hObject, eventdata)
    global hc;
    clear GLOBAL hc;
    
    handles = guidata(hObject);
    pollAndUpdateStatus(handles);
    guidata(hObject, handles);
    
function toolBtnNewLogFile_Callback(hObject, eventdata)
    global hc;
    if ~isempty(hc) && hc.isvalid()
        hc.requestNewLogFile();
    end

function toolBtn10sec_Callback(hObject, eventdata)
    if strcmp( get(hObject, 'State'), 'on')
        set(hObject, 'TooltipString', 'Only log data from the last 10 seconds are shown now. Click to show everything.');
    else
        set(hObject, 'TooltipString', 'All log data are shown now. Click to show only log data from the last 10 seconds.');
    end
    handles = guidata(hObject);
    updatePlotsFromGUI(handles);
    guidata(hObject, handles);
    

function contextMenuRem(hObject, eventdata, rem_all)
    handles = guidata(hObject);
    
    if strcmpi(get(handles.lstFiles, 'Enable'), 'off')
        msgbox('Please disable live plotting before attempting to delete file');
        return;
    end
    
    if rem_all
        filenames = get(handles.lstFiles, 'String');        
        choice = questdlg(...
            'Are you sure that you want to move all log files to the Recycle bin?', ...
            'Remove all files?', ...
            'Yes', 'No', ...
            'No');
    else
        %get selected filename, strip the path and add it to a cell array
        [~,name,ext] = fileparts(getLogFilename(handles.lstFiles, handles.log_path));
        filename = [name ext];
        filenames = {filename};        
        choice = questdlg(...
            ['Are you sure that you want to move "' filenames '" to the Recycle bin?'], ...
            'Remove file?', ...
            'Yes', 'No', ...
            'No');
    end   
    
    if strcmp(choice, 'Yes')
        %delete file(s)
        prev_state = recycle;
        recycle on;
        for file=filenames.'
            filename_complete = fullfile(handles.log_path, cell2mat(file));
            delete(filename_complete);
        end
        recycle(prev_state);        
        
        %correct log file list index
        ind = get(handles.lstFiles, 'Value');
        cnt = length(get(handles.lstFiles, 'String')) - length(filenames);
        if ind > cnt
            set(handles.lstFiles, 'Value', cnt);
        end
        
        refreshFilelist(handles);
    end
    
function contextMenuOpenFolder(hObject, eventdata)
    handles = guidata(hObject);    
    filename = getLogFilename(handles.lstFiles, handles.log_path);    
    if ispc
        cmd = ['explorer /select,' filename];
        system(cmd);
    end
    

function txtReg_Callback(hObject, eventdata, handles)
% hObject    handle to txtReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtReg as text
%        str2double(get(hObject,'String')) returns contents of txtReg as a double


% --- Executes during object creation, after setting all properties.
function txtReg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSendReg.
function btnSendReg_Callback(hObject, eventdata, handles)
% hObject    handle to btnSendReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    status = [];
    
    lti_string = get(handles.txtReg, 'String');
    lti = getObjFromWorkspace(lti_string);
    if ~isempty(lti)
        % Connect if not connected already
        if isempty(hc) || ~hc.isvalid()
            status = RobotConnect([], true);
        end
        
        global hc; %object might have been created inside RobotConnect
        if ~isempty(hc) && hc.isvalid()
            hc.setReg(lti);
%             fprintf('Sent regulator\n');
        else
            msgbox(sprintf('\nCould not send controller to robot because there is no active connection with the robot. Please try again!\n'), 'modal');
        end
    else
        msgbox(sprintf(['\nNo regulator "' lti_string '" in workspace.\n']), 'modal');
    end
    
    pollAndUpdateStatus(handles);

% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    if ~isempty(hc) && hc.isvalid()
        % Show start information dialog
        global dontDisplayStartInfoMsgAgain;
        if ~isempty(handles.startup_readme_str) && (isempty(dontDisplayStartInfoMsgAgain) || ~dontDisplayStartInfoMsgAgain)
            dontDisplayStartInfoMsgAgain = RobotStartInfoMsg([], handles.startup_readme_str);
        end
        drawnow;
        
        % Send start command to robot
        hc.start();
        hc.requestNewLogFile();
        set(handles.hToolBtnLive, 'State', 'on');
%         fprintf('Sent start command\n');
    else
        msgbox(sprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n'), 'modal');
    end
    
    pollAndUpdateStatus(handles, 30);

% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;

    if ~isempty(hc) && hc.isvalid()
        hc.stop();
        set(handles.hToolBtnLive, 'State', 'off');
%         fprintf('Sent stop command\n');
    else
        msgbox(sprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n'), 'modal');
    end
    
    pollAndUpdateStatus(handles);

% --- Executes on button press in btnUp.
function btnUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    handles = guidata(hObject);
    
    if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'up')
        ref_set(hc, handles.ref_mappings.up);
    end

% --- Executes on button press in btnDown.
function btnDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    handles = guidata(hObject);
    
    if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'down')
        ref_set(hc, handles.ref_mappings.down);
    end

% --- Executes on button press in btnLeft.
function btnLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    handles = guidata(hObject);
    
    if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'left')
        ref_set(hc, handles.ref_mappings.left);
    end

% --- Executes on button press in btnRight.
function btnRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    handles = guidata(hObject);
    
    if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'right')
        ref_set(hc, handles.ref_mappings.right);
    end

%%%%%%%%%%%%%%%%CONTROL%%%%%%%%%%%%%%%%%%%%%%
function pollAndUpdateStatus(handles, timeout)
    status = [];
    
    global hc;
    
    if nargin < 2
        timeout = [];
    end
    
    status = [];
    if ~isempty(hc) && hc.isvalid()
        status = hc.pollForStatus(timeout);
    else
        status.conn_state = 'disconnected';
        status.running_state = 'unknown';
        status.reg_exists = 0;
    end
        
    updateStatus(handles, status);

function updateStatus(handles, status)
    red   = [0.847, 0.161, 0.0];
    green = [0.169, 0.506, 0.337];
    grey  = [0.941, 0.941, 0.941];
    
    if isempty(status)
        status.conn_state    = 'disconnected';
        status.running_state = 'unknown';
    end
    
    switch status.conn_state
        case 'connected'
%             set(handles.btnConnect, 'Enable', 'off');
            set(handles.hToolBtnDisconnect, 'Enable', 'on');            
            
        case 'disconnected'
%             set(handles.btnConnect, 'Enable', 'on');
            set(handles.hToolBtnDisconnect, 'Enable', 'off');
    end
    
    switch status.running_state
        case 'running'
            set(handles.btnStart, 'Enable', 'off');
            set(handles.btnStop, 'Enable', 'on');
            
            set(handles.btnStart, 'BackgroundColor', grey);
            set(handles.btnStop,  'BackgroundColor', red);
            
%             set(handles.btnSendReg, 'Enable', 'on');
%             set(handles.txtReg, 'Enable', 'on');
            
            set(handles.btnLeft, 'Enable', 'on');
            set(handles.btnRight, 'Enable', 'on');
            set(handles.btnDown, 'Enable', 'on');
            set(handles.btnUp, 'Enable', 'on');
            
        case 'stopped'
            if status.reg_exists
                set(handles.btnStart, 'Enable', 'on');
                set(handles.btnStart, 'BackgroundColor', green);
            else
                set(handles.btnStart, 'Enable', 'off');
                set(handles.btnStart, 'BackgroundColor', grey);
            end
            
            set(handles.btnStop, 'Enable', 'off');
            set(handles.btnStop, 'BackgroundColor', grey);
            
%             set(handles.btnSendReg, 'Enable', 'on');
%             set(handles.txtReg, 'Enable', 'on');
            
            set(handles.btnLeft, 'Enable', 'off');
            set(handles.btnRight, 'Enable', 'off');
            set(handles.btnDown, 'Enable', 'off');
            set(handles.btnUp, 'Enable', 'off');
            
        case 'unknown'
            set(handles.btnStart, 'Enable', 'off');
            set(handles.btnStop, 'Enable', 'off');
            
            set(handles.btnStart, 'BackgroundColor', grey);
            set(handles.btnStop,  'BackgroundColor', grey);
            
%             set(handles.btnSendReg, 'Enable', 'off');
%             set(handles.txtReg, 'Enable', 'off');
            
            set(handles.btnLeft, 'Enable', 'off');
            set(handles.btnRight, 'Enable', 'off');
            set(handles.btnDown, 'Enable', 'off');
            set(handles.btnUp, 'Enable', 'off');
    end
    
function handleKeyPress(key, handles)
    global hc;
    
    % Handle keypress
    switch (key)
        case 'uparrow'
            if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'up')
                ref_set(hc, handles.ref_mappings.up);
            end
            
        case 'downarrow'
            if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'down')
                ref_set(hc, handles.ref_mappings.down);
            end
            
        case 'leftarrow'
            if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'left')
                ref_set(hc, handles.ref_mappings.left);
            end
            
        case 'rightarrow'
            if ~isempty(handles.ref_mappings) && isfield(handles.ref_mappings, 'right')
                ref_set(hc, handles.ref_mappings.right);
            end
    end

    
% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);
    
% --- Executes on key press with focus on btnUp and none of its controls.
function btnUp_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);

% --- Executes on key press with focus on btnLeft and none of its controls.
function btnLeft_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);

% --- Executes on key press with focus on btnDown and none of its controls.
function btnDown_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);

% --- Executes on key press with focus on btnRight and none of its controls.
function btnRight_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);
    
% --- Executes on key press with focus on btnStart and none of its controls.
function btnStart_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);

% --- Executes on key press with focus on btnStop and none of its controls.
function btnStop_KeyPressFcn(hObject, eventdata, handles)
    handleKeyPress(eventdata.Key, handles);

    
function ref_set(hc, ref)
    if ~isempty(hc) && hc.isvalid()
        ind = ref(1);
        val = ref(2);
        hc.setRef(ind, val, 2);
%         fprintf('Sent reference\n');
    else
        msgbox(sprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n'), 'modal');
    end
    
% function ref_turn(hc, direction)
%     if ~isempty(hc) && hc.isvalid()
%         hc.setRef(0, sign(direction)*0.2, 2);
% %         fprintf('Sent reference\n');
%     else
%         msgbox(sprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n'), 'modal');
%     end
% 
% function ref_forward(hc, direction)
%     if ~isempty(hc) && hc.isvalid()
%         hc.setRef(1, sign(direction)*0.1, 2);
% %         fprintf('Sent reference\n');
%     else
%         msgbox(sprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n'), 'modal');
%     end

% --- Executes on button press in btnSimulate.
function btnSimulate_Callback(hObject, eventdata, handles)
% hObject    handle to btnSimulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Disable live plotting
    set(handles.hToolBtnLive, 'State', 'off');
    
    % Grab the controller
    reg_name = get(handles.txtReg, 'String');
    reg = getObjFromWorkspace(reg_name);
    if isempty(reg)
        msgbox(['Controller named ' reg_name ' not found in current workspace'], 'modal');
        return;
    end
    
    
    noise_on = get(handles.radiobuttonNoiseOn,'Value');
    
    % Perform the simulation
    [sim_data, map, titles] = sim_twip(reg, noise_on);
    
    % Save log data to mat file
    filename = sprintf('%s_%s.Sim.mat', datestr(now, 'yyyy-mm-dd_HH;MM;SS'), cell2mat(reg.Notes));    
    filename_full = fullfile(handles.log_path, filename);
    save(filename_full, 'reg', 'sim_data', '-mat');
    
    % Select the newly created log file
    refreshFilelist(handles); %refresh listbox with logfile names
    ind = find(strcmp(get(handles.lstFiles, 'String'), filename), 1, 'first');
    if isempty(ind)
        error('Could not select the simulation log file');
    end
    set(handles.lstFiles, 'Value', ind);
    lstFiles_Callback(handles.lstFiles, [], handles);
    
    % Update plot
    updatePlotsFromGUI(handles);

% --- Executes on button press in btnShowSignalList.
function btnShowSignalList_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowSignalList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
    if get(hObject,'Value')
        %Show
        set(handles.panSignals, 'Visible', 'on');
        set(hObject, 'String', 'Hide signals to plot (advanced) <<<');
    else
        %Hide
        set(handles.panSignals, 'Visible', 'off');
        set(hObject, 'String', 'Show signals to plot (advanced) >>>');
    end
    


% --- Executes on button press in radiobuttonNoiseOn.
function radiobuttonNoiseOn_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonNoiseOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonNoiseOn


% --- Executes on button press in radiobuttonNoiseOff.
function radiobuttonNoiseOff_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonNoiseOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonNoiseOff
