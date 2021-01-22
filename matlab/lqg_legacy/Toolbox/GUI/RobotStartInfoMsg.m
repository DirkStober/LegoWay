function varargout = RobotStartInfoMsg(varargin)
% ROBOTSTARTINFOMSG MATLAB code for RobotStartInfoMsg.fig
%      ROBOTSTARTINFOMSG, by itself, creates a new ROBOTSTARTINFOMSG or raises the existing
%      singleton*.
%
%      H = ROBOTSTARTINFOMSG returns the handle to a new ROBOTSTARTINFOMSG or the handle to
%      the existing singleton*.
%
%      ROBOTSTARTINFOMSG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROBOTSTARTINFOMSG.M with the given input arguments.
%
%      ROBOTSTARTINFOMSG('Property','Value',...) creates a new ROBOTSTARTINFOMSG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RobotStartInfoMsg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RobotStartInfoMsg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RobotStartInfoMsg

% Last Modified by GUIDE v2.5 06-May-2013 21:24:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RobotStartInfoMsg_OpeningFcn, ...
                   'gui_OutputFcn',  @RobotStartInfoMsg_OutputFcn, ...
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


% --- Executes just before RobotStartInfoMsg is made visible.
function RobotStartInfoMsg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RobotStartInfoMsg (see VARARGIN)

% Choose default command line output for RobotStartInfoMsg
handles.output = hObject;

if length(varargin) >= 2 && ~isempty(varargin{2})
    set(handles.lblReadme, 'String', varargin{2});
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RobotStartInfoMsg wait for user response (see UIRESUME)
uiwait(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = RobotStartInfoMsg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    varargout{1} = get(handles.chkDontDisplayAgain,'Value');
    delete(hObject);


% --- Executes on button press in chkDontDisplayAgain.
function chkDontDisplayAgain_Callback(hObject, eventdata, handles)
% hObject    handle to chkDontDisplayAgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%     checked = get(hObject,'Value');
%     if checked
%         global dontDisplayStartInfoMsgAgain;
%         dontDisplayStartInfoMsgAgain = true;
%     else
%         clear global dontDisplayStartInfoMsgAgain;
%     end


% --- Executes on button press in btnOk.
function btnOk_Callback(hObject, eventdata, handles)
% hObject    handle to btnOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    uiresume(gcbf);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    uiresume(hObject);
