function procesamiento
%NUMBERPLATEEXTRACTION extracts the characters from the input number plate image.

%Adquisici�n de la imagen
f=getappdata(0, 'imagenoriginal'); %Lee la imagen original del espacio de trabajo de la aplicaci�n.

f=imresize(f,[400 NaN]); %Redimensiona la imagen manteniendo las mismas proporciones.
%Conversi�n a escala de grises
g=rgb2gray(f); % Convirte la imagen de RGB (color) a grises.
g=medfilt2(g,[3 3]); %Aplica un filtro para remover ruido.
figure, subplot(4,2,1), imshow(g);
title('Conversi�n a grises');

%%%------------

%Gradiente morfol�gico es la diferencia entre dilataci�n y erosi�n de una imagen
%�til para detecci�n de bordes y segmentaci�n.

se=strel('disk',1); % crea un elemento de estructuraci�n en forma de disco plano, donde R especifica el radio. 
% R debe ser un n�mero entero no negativo.
% Structural element (disk of radius 1) for morphological processing.
gi=imdilate(g,se); % dilata la imagen en escala de grises "g", devolviendo la imagen dilatada gi.
% El argumento se es un objeto de elemento estructurado, devuelto por la funci�n Strel.
% Dilating the gray image with the structural element.

ge=imerode(g,se); % erosiona la imagen en escala de grises "g", devolviendo la imagen erosionada ge.
% El argumento se es un objeto de elemento estructurado, devuelto por la funci�n Strel.
% Eroding the gray image with structural element.

gdiff=imsubtract(gi,ge); % resta cada elemento de la matriz ge en el correspondiente elemento de la matriz gi
% y devuelve la diferencia en el elemento correspondiente de la matriz gdiff. 
% Morphological Gradient for edges enhancement.

gdiff=mat2gray(gdiff); % convierte la matriz gdiff en imagen. La matriz de entrada puede ser l�gica o num�rica.
% La imagen de salida es double y se sobreescribe en la misma variable gdiff. 
% Converting the class to DOUBLE.
subplot(4,2,2), imshow(gdiff);
title('Detecci�n de bordes');

%%%------------

gdiff=conv2(gdiff,[1 1;1 1]); % calcula la convoluci�n bidimensional de matrices gdiff y [1 1;1 1]
% para aclarar los bordes.
% Convolution of the double image for brightening the edges.
subplot(4,2,3), imshow(gdiff);
title('Aclaraci�n de bordes');

%%%------------

gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1); % Ajusta los valores de intensidad de la imagen,
% donde 0.1 (gamma) especifica la forma de la curva que describe la
% relaci�n entre los valores de gdiff (entrada) y gdiff (salida)
% Intensity scaling between the range 0 to 1.

B=logical(gdiff); % convierte una entrada num�rica (gdiff) en una matriz de valores l�gicos (B).
% Conversion of the class from double to BINARY.
subplot(4,2,4), imshow(B);
title('Ajuste intensidad y binarizaci�n');

%%%------------

er=imerode(B,strel('line',50,0));% erosiona la imagen B, devolviendo la imagen erosionada er.
% El segundo argumento es un objeto de elemento estructurado, devuelto por la funci�n Strel
% en donde se crea un elemento de estructuraci�n lineal plana. 50 es la
% longitud de la l�nea y 0 es el �ngulo de inclinaci�n de la l�nea,
% formando una l�nea horizontal
out1=imsubtract(B,er); 
subplot(4,2,5), imshow(out1);
title('Eliminaci�n bordes de placa'); % elimina lineas horizontales que posiblemente sean los bordes
% de la placa.

%%%------------

% Rellenando todas las regiones de la imagen
% Filling all the regions of the image.
F=imfill(out1,'holes'); %rellena regiones de la imagen, en este mediante 'holes' se especifica
% que rellene agujeros de la imagen binaria out1.
subplot(4,2,6), imshow(F);
title('Relleno regiones');

%%%------------

% Thinning the image to ensure character isolation.
H=bwmorph(F,'thin',1); % aplica la operaci�n morfol�gica 'thin' en la imagen binaria F 1 vez.
% la operaci�n thin adelgaza la imagen para asegurar el aislamiento de caracteres
subplot(4,2,7), imshow(H);
title('Adelgazamiento de imagen');

%%%------------

H=imerode(H,strel('line',3,90)); % erosiona la imagen con un elemento estructural devuelto por strel

% Selecting all the regions that are of pixel area more than 100.
final=bwareaopen(H,100); % remueve de la imagen binaria H todas las regiones con menos de 100 pixeles.
subplot(4,2,8), imshow(final);
title('Eliminaci�n peque�as regiones');

setappdata(0, 'imagenfinal', final); %Guarda la imagen en el espacio de trabajo de la aplicaci�n



end