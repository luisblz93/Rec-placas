function varargout = interfaz(varargin)
% INTERFAZ MATLAB code for interfaz.fig
%      INTERFAZ, by itself, creates a new INTERFAZ or raises the existing
%      singleton*.
%
%      H = INTERFAZ returns the handle to a new INTERFAZ or the handle to
%      the existing singleton*.
%
%      INTERFAZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFAZ.M with the given input arguments.
%
%      INTERFAZ('Property','Value',...) creates a new INTERFAZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interfaz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interfaz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interfaz

% Last Modified by GUIDE v2.5 24-Nov-2014 21:05:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interfaz_OpeningFcn, ...
                   'gui_OutputFcn',  @interfaz_OutputFcn, ...
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


% --- Executes just before interfaz is made visible.
function interfaz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interfaz (see VARARGIN)
% Choose default command line output for interfaz
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interfaz wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interfaz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in btnIniciarWebCam.
function btnIniciarWebCam_Callback(hObject, eventdata, handles)
% hObject    handle to btnIniciarWebCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

video=videoinput('winvideo',1,'MJPG_1280x720'); %Establece el nombre del adaptador, el id del adaptador, y el formato
handles.video=video; %Guarda el video en handles para que se mantenga en la estructura del proyecto

vidRes = get(handles.video, 'VideoResolution');
nBands = get(handles.video, 'NumberOfBands');
set(handles.axes1,'Visible','off')
axes(handles.axes1) %Al poner esta función el preview siguiente hará que se situe dentro de axes1
hImage = image( zeros(vidRes(1), vidRes(2), nBands) );

preview(handles.video, hImage) %Muestra la webcam en axes1

guidata(hObject, handles);%Actualiza handles


% --- Executes on button press in btnCapturar.
function btnCapturar_Callback(hObject, eventdata, handles)
% hObject    handle to btnCapturar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.I_original = getsnapshot(handles.video);
imshow(handles.I_original);
imwrite(handles.I_original, 'original.jpg');

guidata(hObject, handles);

% --- Executes on button press in btnMostrarEjemplo.
function btnMostrarEjemplo_Callback(hObject, eventdata, handles)
% hObject    handle to btnMostrarEjemplo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.jpg','Selecciona una imagen a procesar','Imágenes ejemplos\');%Abre dialog box(ventana) para elegir la imagen de la placa.

if isequal(filename,0)%Continúa con el proceso sólo si no se canceló la selección.
else
    rutaimagen=fullfile(pathname, filename);%Almacena la ruta en una variable
    handles.I_original = imread(rutaimagen);%Lee la imagen de la ruta seleccionada
    axes(handles.axes1);
    imshow(handles.I_original);
    
end

guidata(hObject, handles);

% --- Executes on button press in btnProcesar.
function btnProcesar_Callback(hObject, eventdata, handles)
% hObject    handle to btnProcesar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(0, 'imagenoriginal', handles.I_original); %Guarda la imagen en el espacio de trabajo de la aplicación
%para que pueda ser obtenida en cualquier otra función, que se encuentre en
%otro archivo.

run reconocimiento/procesamiento();%Realiza el procesamiento de la imagen y finaliza con la imagen
% procesada y lista para la segmentación y reconocimiento.

guidata(hObject, handles);

% --- Executes on button press in btnReconocer.
function btnReconocer_Callback(hObject, eventdata, handles)
% hObject    handle to btnReconocer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run reconocimiento/reconocimiento();%Realiza el reconocimiento de la imagen y finaliza con el código de la placa
%ya reconocida y almacenada en el espacio de trabajo
handles.codigoplaca=getappdata(0, 'codigoplaca');%Recupera el código de la placa
set(handles.inputPlacaRec,'String',handles.codigoplaca)%Muestra el código de la placa

guidata(hObject, handles);

% --- Executes on button press in btnExportarTxt.
function btnExportarTxt_Callback(hObject, eventdata, handles)
% hObject    handle to btnExportarTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Las siguientes lineas almacenan el código de la placa en un
%archivo txt-----------------------------------------------------------

fid = fopen('placa_reconocida.txt', 'wt'); % This portion of code writes the number plate
fprintf(fid,'%s\n',handles.codigoplaca);      % to the text file, if executed a notepad file with the
fclose(fid);                      % name noPlate.txt will be open with the number plate written.
winopen('placa_reconocida.txt')

guidata(hObject, handles);

% --- Executes on button press in btnExportarExcel.
function btnExportarExcel_Callback(hObject, eventdata, handles)
% hObject    handle to btnExportarExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

placa=cellstr(handles.codigoplaca);%Convierte el arreglo de caracteres en arreglos de string (1 fila en 1 columna)
%Como solo hay una fila se convierte en una sola columna.
xlswrite('placa_reconocida',placa,1,'A1');%Almacena el código de la placa en un archivo excel
winopen('placa_reconocida.xls')%Abre el archivo excel

guidata(hObject, handles);


function inputPlacaRec_Callback(hObject, eventdata, handles)
% hObject    handle to inputPlacaRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputPlacaRec as text
%        str2double(get(hObject,'String')) returns contents of inputPlacaRec as a double


% --- Executes during object creation, after setting all properties.
function inputPlacaRec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputPlacaRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSalir.
function btnSalir_Callback(hObject, eventdata, handles)
% hObject    handle to btnSalir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf)



function inputText_Callback(hObject, eventdata, handles)
% hObject    handle to inputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputText as text
%        str2double(get(hObject,'String')) returns contents of inputText as a double


% --- Executes during object creation, after setting all properties.
function inputText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
