function conversionGrises

%Adquisici�n de la imagen
f=getappdata(0, 'imagenoriginal'); %Lee la imagen original del espacio de trabajo de la aplicaci�n.
f=imresize(f,[400 NaN]); %Redimensiona la imagen manteniendo las mismas proporciones.
%Conversi�n a escala de grises
g=rgb2gray(f); % Convirte la imagen de RGB (color) a grises.
g=medfilt2(g,[3 3]); %Aplica un filtro para remover ruido.
setappdata(0, 'imagengrises', g); %Guarda la imagen en grises en el espacio de trabajo de la aplicaci�n
end