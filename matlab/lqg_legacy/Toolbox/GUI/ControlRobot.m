function varargout = ControlRobot(varargin)
% CONTROLROBOT MATLAB code for ControlRobot.fig
%      CONTROLROBOT, by itself, creates a new CONTROLROBOT or raises the existing
%      singleton*.
%
%      H = CONTROLROBOT returns the handle to a new CONTROLROBOT or the handle to
%      the existing singleton*.
%
%      CONTROLROBOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLROBOT.M with the given input arguments.
%
%      CONTROLROBOT('Property','Value',...) creates a new CONTROLROBOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ControlRobot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ControlRobot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ControlRobot

% Last Modified by GUIDE v2.5 07-Nov-2011 10:51:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ControlRobot_OpeningFcn, ...
                   'gui_OutputFcn',  @ControlRobot_OutputFcn, ...
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


% --- Executes just before ControlRobot is made visible.
function ControlRobot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ControlRobot (see VARARGIN)

% Choose default command line output for ControlRobot
handles.output = hObject;


pollAndUpdateStatus(handles);
%startTimer(handles);


% [conn_state, running_state, reg_exists] = pollForStatus();
% % conn_state
% % running_state
% updateStatus(handles, conn_state, running_state, reg_exists)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ControlRobot wait for user response (see UIRESUME)
% uiwait(handles.figControlRobot);

function startTimer(handles)
    global th;
    th = timer(...
        'TimerFcn', @onTimer, ...
        'Period', 1, ...
        'ExecutionMode', 'fixedSpacing', ...
        'UserData', handles, ...%gcbo, ...
        'StartDelay', 1);
    start(th);


function onTimer(obj, event)
'timer'
    handles = obj.UserData;
    pollAndUpdateStatus(handles, 2);

function pollAndUpdateStatus(handles, timeout)
    if nargin < 2
        timeout = [];
    end
    
    [conn_state, running_state, reg_exists] = pollForStatus(timeout);
    updateStatus(handles, conn_state, running_state, reg_exists)

function [conn_state, running_state, reg_exists] = pollForStatus(timeout)
    if nargin < 1 || isempty(timeout)
        timeout = 30; %seconds
    end
    
    running_state = 'unknown';
    reg_exists = 0;
    try
        global hc
        [status, ret] = hc.getStatus(timeout);
        conn_state = 'connected';

        if ret == 0
            switch status.cur_state
                case 1
                    running_state = 'stopped';
                case 2
                    running_state = 'running';
            end
            reg_exists = status.reg_exists;
        end
    catch e
        conn_state = 'disconnected';
    end

function updateStatus(handles, conn_state, running_state, reg_exists)
    switch conn_state
        case 'connected'
            set(handles.btnConnect, 'Enable', 'off');
            set(handles.btnDisconnect, 'Enable', 'on');            
            
        case 'disconnected'
            set(handles.btnConnect, 'Enable', 'on');
            set(handles.btnDisconnect, 'Enable', 'off');
    end
    
    switch running_state
        case 'running'
            set(handles.btnStart, 'Enable', 'off');
            set(handles.btnStop, 'Enable', 'on');
            
            set(handles.btnSendReg, 'Enable', 'on');
            set(handles.txtReg, 'Enable', 'on');
            
            set(handles.btnLeft, 'Enable', 'on');
            set(handles.btnRight, 'Enable', 'on');
            set(handles.btnDown, 'Enable', 'on');
            set(handles.btnUp, 'Enable', 'on');
            
        case 'stopped'
            if reg_exists
                set(handles.btnStart, 'Enable', 'on');
            else
                set(handles.btnStart, 'Enable', 'off');
            end
            
            set(handles.btnStop, 'Enable', 'off');
            
            set(handles.btnSendReg, 'Enable', 'on');
            set(handles.txtReg, 'Enable', 'on');
            
            set(handles.btnLeft, 'Enable', 'off');
            set(handles.btnRight, 'Enable', 'off');
            set(handles.btnDown, 'Enable', 'off');
            set(handles.btnUp, 'Enable', 'off');
            
        case 'unknown'
            set(handles.btnStart, 'Enable', 'off');
            set(handles.btnStop, 'Enable', 'off');
            
            set(handles.btnSendReg, 'Enable', 'off');
            set(handles.txtReg, 'Enable', 'off');
            
            set(handles.btnLeft, 'Enable', 'off');
            set(handles.btnRight, 'Enable', 'off');
            set(handles.btnDown, 'Enable', 'off');
            set(handles.btnUp, 'Enable', 'off');
    end



% --- Outputs from this function are returned to the command line.
function varargout = ControlRobot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnConnect.
function btnConnect_Callback(hObject, eventdata, handles)
% hObject    handle to btnConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %set(hObject, 'Enable', 'off');
    
    % Close and deleted prev. HipsterComm object
    global hc;
    clear GLOBAL hc;
    
    mh = [];
    try
        global hc;

        % Create a new HipsterComm object and connect
        hc = HipsterComm(get(handles.txtLogPath, 'String'), fullfile(get_setting('root_dir'), '..', 'Binaries/'));
        ret = hc.connect(get(handles.txtComPort, 'String'));
        msg = sprintf('Successfully connected to robot\n\nPlease push the right arrow button ("RUN>") on\nthe Lego NXT brick to start the embedded control program.');
        mh = msgbox(msg, 'Connected', 'modal');
%         pollAndUpdateStatus(handles);
%         updateStatus(handles, 'connected', 'stopped', 0);

    %         fprintf('Successfully connected to robot\n');
    %         fprintf('\nPlease push the right arrow button ("RUN>") on\nthe Lego NXT brick to start the embedded control program.\n');
    catch e
    %         fprintf('Connection failed');
        waitfor(msgbox('Connection attempt failed. Please try again.', 'Connection attempt failed', 'modal'));
%         updateStatus(handles, 'disconnected', 'unknown', 0);
    end
    
    pollAndUpdateStatus(handles, 90);
    delete(mh);
    

function txtComPort_Callback(hObject, eventdata, handles)
% hObject    handle to txtComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtComPort as text
%        str2double(get(hObject,'String')) returns contents of txtComPort as a double


% --- Executes during object creation, after setting all properties.
function txtComPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnDisconnect.
function btnDisconnect_Callback(hObject, eventdata, handles)
% hObject    handle to btnDisconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %set(hObject, 'Enable', 'off');

    global hc;
    clear GLOBAL hc;
    
    %set(hObject, 'Enable', 'on');
    pollAndUpdateStatus(handles);


% --- Executes on button press in btnUp.
function btnUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    ref_forward(hc, +1);

% --- Executes on button press in btnDown.
function btnDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    ref_forward(hc, -1);

% --- Executes on button press in btnLeft.
function btnLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    ref_turn(hc, +1);

% --- Executes on button press in btnRight.
function btnRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    ref_turn(hc, -1);


% --- Executes on key press with focus on figControlRobot and none of its controls.
function figControlRobot_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figControlRobot (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    % Handle keypress
    switch (eventdata.Key)
        case 'uparrow'
            ref_forward(hc, +1);
        case 'downarrow'
            ref_forward(hc, -1);
        case 'leftarrow'
            ref_turn(hc, +1);
        case 'rightarrow'
            ref_turn(hc, -1);
    end
    
function ref_turn(hc, direction)
    if ~isempty(hc)
        hc.setRef(0, sign(direction)*0.2, 2);
        fprintf('Sent reference\n');
    else
        fprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n');
    end

function ref_forward(hc, direction)
    if ~isempty(hc)
        hc.setRef(2, sign(direction)*0.1, 2);
        fprintf('Sent reference\n');
    else
        fprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n');
    end



function txtLogPath_Callback(hObject, eventdata, handles)
% hObject    handle to txtLogPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLogPath as text
%        str2double(get(hObject,'String')) returns contents of txtLogPath as a double


% --- Executes during object creation, after setting all properties.
function txtLogPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLogPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    set(handles.txtLogPath, 'String', uigetdir(get(handles.txtLogPath, 'String')));



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
    
    lti_string = get(handles.txtReg, 'String');
    if evalin('base', ['exist(''' lti_string ''', ''var'')'])
        if ~isempty(hc)
            hc.setReg( evalin('base', get(handles.txtReg, 'String')) );
            fprintf('Sent regulator\n');
        else
            fprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n');
        end
    else
        fprintf(['\nNo regulator "' lti_string '" in workspace.\n']);
    end
    
    pollAndUpdateStatus(handles);


% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
% hObject    handle to btnStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global hc;
    
    if ~isempty(hc)
        hc.start();
        fprintf('Sent start command\n');
    else
        fprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n');
    end
    
    pollAndUpdateStatus(handles, 30);

% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    global hc;

    if ~isempty(hc)
        hc.stop();
        fprintf('Sent stop command\n');
    else
        fprintf('\nNo active connection object found.\nCreate one with the "Connect" button\n');
    end
    
    pollAndUpdateStatus(handles);
    
