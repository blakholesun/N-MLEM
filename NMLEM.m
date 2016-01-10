function varargout = NMLEM(varargin)
% NMLEM MATLAB code for NMLEM.fig
%      NMLEM, by itself, creates a new NMLEM or raises the existing
%      singleton*.
%
%      H = NMLEM returns the handle to a new NMLEM or the handle to
%      the existing singleton*.
%
%      NMLEM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NMLEM.M with the given input arguments.
%
%      NMLEM('Property','Value',...) creates a new NMLEM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NMLEM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NMLEM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NMLEM

% Last Modified by GUIDE v2.5 20-Aug-2015 14:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NMLEM_OpeningFcn, ...
    'gui_OutputFcn',  @NMLEM_OutputFcn, ...
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


% --- Executes just before NMLEM is made visible.
function NMLEM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NMLEM (see VARARGIN)

%load data
load('unfoldparams.mat');
handles.icruconv = icruconv;
handles.Bins = Bins;
handles.uniform = ones(52,1)./52;
handles.step = testin1;
handles.response = respmat;

%populate the time box
handles.time = 0.1;
handles.edit12.String = num2str(handles.time);

%populate the normalization
handles.normalization = 1.21;
handles.edit9.String = num2str(handles.normalization);

%populate the iteration cutoff
handles.iteration = 10000;
handles.edit10.String = num2str(handles.iteration);

%populate the meas/calc ratio
handles.ratio = 0.01;
handles.edit11.String = num2str(handles.ratio);

%populate charge and cout rate columns

for i = 1:8
    nameedit = strcat('edit',num2str(i));
    nameedit2 = strcat('edit',num2str(12+i));
    %namestatic = strcat('text',num2str(i+4));
    set(handles.(nameedit),'String', num2str(0))
    set(handles.(nameedit2),'String', num2str(0))
    %set(handles.(namestatic),'String', num2str(0))
end

handles.guess = zeros(52,1);
stairs(handles.Bins, handles.guess);
set(gca,'XScale', 'log');
set(gca,'XLim', [1e-10 100]);
set(gca,'XTick', [1e-10 1e-8 1e-6 1e-4 1e-2 1 100]);
set(gca,'YLim', [0 0.1]);
xlabel('Energy [Mev]');

% Choose default command line output for NMLEM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NMLEM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NMLEM_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.meas = zeros(1,8);
if ~isfield(handles, 'raw')
    msgbox('Please fill in all the data boxes.')
    return
end

for i = 1:8
    name = strcat('mod',num2str(i-1));
    if ~isfield(handles.raw, name)
        msgbox('Please finish filling in all the data boxes.')
        return
    else
        handles.meas(i) = handles.raw.(name);
    end
end

if handles.guess == zeros(52,1)
    msgbox('Please select a guess spectrum.')
    return
end

[handles.final.specout, ~, handles.final.s, handles.final.err, handles.final.sim_data, handles.final.finali] ...
    = MLEMTRON(handles.meas, handles.guess, handles.response, ...
    handles.Bins, handles.iteration, ...
    handles.normalization, handles.ratio);

choice = questdlg('Unfolding is now completed. You can save the image by clicking the save button on the figure. Would you like to generate a report?',...
    'Generate Report', 'Yes', 'No', 'Yes');
% Handle response
switch choice
    case 'Yes'
        print_report(handles);
    case 'No'
        guidata(hObject, handles);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
    case 'Uniform' % User selects uniform.
        handles.guess = handles.uniform;
    case 'Step' % User selects step.
        handles.guess = handles.step;
end
% Save the handles structure.
stairs(handles.Bins, handles.guess);
set(gca,'XScale', 'log');
set(gca,'XLim', [1e-10 100]);
set(gca,'XTick', [1e-10 1e-8 1e-6 1e-4 1e-2 1 100]);
xlabel('Energy [Mev]');
set(gca,'YLim', [0 0.1]);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit1.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit1.String = num2str(0);
    return
end

handles.raw.mod0 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit13.String =  num2str(handles.raw.mod0);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit2.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit2.String = num2str(0);
    return
end

handles.raw.mod1 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit14.String =  num2str(handles.raw.mod1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit3.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit3.String = num2str(0);
    return
end

handles.raw.mod2 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit15.String =  num2str(handles.raw.mod2);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit4.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit4.String = num2str(0);
    return
end

handles.raw.mod3 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit16.String =  num2str(handles.raw.mod3);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit5.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit5.String = num2str(0);
    return
end

handles.raw.mod4 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit17.String =  num2str(handles.raw.mod4);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit6.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit6.String = num2str(0);
    return
end

handles.raw.mod5 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit18.String =  num2str(handles.raw.mod5);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit7.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit7.String = num2str(0);
    return
end

handles.raw.mod6 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit19.String =  num2str(handles.raw.mod6);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit8.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit8.String = num2str(0);
    return
end

handles.raw.mod7 = round(text*10^(-9)/(7*10^(-15))/handles.time);
handles.edit20.String =  num2str(handles.raw.mod7);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
end

handles.normalization = text;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
end

handles.iteration = text;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
end

handles.ratio = text;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
end
handles.time = text;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit13.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit13.String = num2str(0);
    return
end

handles.raw.mod0 = text;
handles.edit1.String =  num2str(handles.raw.mod0*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit14.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit14.String = num2str(0);
    return
end

handles.raw.mod1 = text;
handles.edit2.String =  num2str(handles.raw.mod1*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit15.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit15.String = num2str(0);
    return
end

handles.raw.mod2 = text;
handles.edit3.String =  num2str(handles.raw.mod2*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit16.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit16.String = num2str(0);
    return
end

handles.raw.mod3 = text;
handles.edit4.String =  num2str(handles.raw.mod3*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit17.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit17.String = num2str(0);
    return
end

handles.raw.mod4 = text;
handles.edit5.String =  num2str(handles.raw.mod4*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit18.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit18.String = num2str(0);
    return
end

handles.raw.mod5 = text;
handles.edit6.String =  num2str(handles.raw.mod5*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit19.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit19.String = num2str(0);
    return
end

handles.raw.mod6 = text;
handles.edit7.String =  num2str(handles.raw.mod6*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double
text = str2double(get(hObject,'String'));
if isnan(text)
    msgbox('You entered text or did not include a value. Please enter a number.')
    handles.edit20.String = num2str(0);
    return
elseif handles.time == 0.1
    msgbox('Please enter the time of measurement in time section.')
    handles.edit20.String = num2str(0);
    return
end

handles.raw.mod7 = text;
handles.edit8.String =  num2str(handles.raw.mod7*(10^(-9)/(7*10^(-15))/handles.time)^-1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
