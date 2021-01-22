function varargout = RobotConnect(varargin)
% ROBOTCONNECT MATLAB code for RobotConnect.fig
%      ROBOTCONNECT, by itself, creates a new ROBOTCONNECT or raises the existing
%      singleton*.
%
%      H = ROBOTCONNECT returns the handle to a new ROBOTCONNECT or the handle to
%      the existing singleton*.
%
%      ROBOTCONNECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROBOTCONNECT.M with the given input arguments.
%
%      ROBOTCONNECT('Property','Value',...) creates a new ROBOTCONNECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RobotConnect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RobotConnect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RobotConnect

% Last Modified by GUIDE v2.5 25-Apr-2013 22:46:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RobotConnect_OpeningFcn, ...
                   'gui_OutputFcn',  @RobotConnect_OutputFcn, ...
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


% --- Executes just before RobotConnect is made visible.
function RobotConnect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RobotConnect (see VARARGIN)

% Choose default command line output for RobotConnect
handles.output = hObject;
handles.status = [];

% Fill in default com port
try
    set(handles.txtComPort, 'String', get_setting('default_com_port'));
catch e
    set(handles.txtComPort, 'String', 'COM4');
end

handles.return_on_connect = false;
if length(varargin) >= 2 && cell2mat(varargin(2))
    handles.return_on_connect = true;
    set(handles.btnDisconnect, 'Visible', 'off');
    pos_dis = get(handles.btnDisconnect, 'Position');
    pos_con = get(handles.btnConnect, 'Position');
    pos_con(3) = pos_con(3) + pos_dis(3);
    set(handles.btnConnect, 'Position', pos_con);
end

% Update handles structure
guidata(hObject, handles);

handles.status = pollAndUpdateStatus(handles);

% UIWAIT makes RobotConnect wait for user response (see UIRESUME)
if handles.return_on_connect
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = RobotConnect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if handles.return_on_connect
    varargout{1} = handles.status;
    delete(hObject);
else
    varargout{1} = [];
end


% --- Executes on button press in btnConnect.
function btnConnect_Callback(hObject, eventdata, handles)
% hObject    handle to btnConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    set(handles.btnConnect,'enable','off');
    pause(0.05);
    timeout = 90; %seconds
    
    global hc;
    clear GLOBAL hc;
    
    global hc;
    hc = [];
    
    mh = [];
    try
        % Create a new HipsterComm object and connect
        hc = HipsterComm(get(handles.txtLogPath, 'String'), fullfile(get_setting('root_dir'), '..', 'Binaries/'));
        hc.connect(get(handles.txtComPort, 'String'));
        msg = sprintf('Successfully connected to robot\n\nPlease push the right arrow button ("RUN>") on\nthe Lego NXT brick to start the embedded control program.');
        mh = msgbox(msg, 'Connected', 'modal');
        set(mh,'CloseRequestFcn','');
        delete(findobj(mh, 'string', 'OK'));
        delete(findobj(mh, 'style', 'frame'));
        drawnow;
        
    catch e
        clear GLOBAL hc
        waitfor(msgbox('Connection attempt failed. Please try again.', 'Connection attempt failed', 'modal'));
        set(handles.btnConnect,'enable','on');
%         disp(e.message);
    end
    
    handles.status = pollAndUpdateStatus(handles, timeout);
    guidata(hObject, handles);
    
    if handles.return_on_connect && strcmp(handles.status.conn_state, 'connected')
        uiresume(gcbf);
    end
    
    % Delete msgbox
    delete(mh);
    
    
function status = pollAndUpdateStatus(handles, timeout)
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
    if ~isempty(status) && strcmp(status.conn_state, 'connected')
            set(handles.btnConnect, 'Enable', 'off');
            set(handles.btnDisconnect, 'Enable', 'on');  
    else
            set(handles.btnConnect, 'Enable', 'on');
            set(handles.btnDisconnect, 'Enable', 'off');
    end
    
    
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

    global hc;
    clear GLOBAL hc;
    
    %set(hObject, 'Enable', 'on');
    handles.status = pollAndUpdateStatus(handles);


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

    sel_dir = uigetdir(get(handles.txtLogPath, 'String'));
    if sel_dir ~= 0
        set(handles.txtLogPath, 'String', sel_dir);
    end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if handles.return_on_connect
    uiresume(hObject);
else
    delete(hObject);
end
