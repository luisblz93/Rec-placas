function reconocimiento

%Adquisición de la imagen
final=getappdata(0, 'imagenfinal'); %Lee la imagen final del procesamiento del espacio de trabajo de la aplicación.

% final=bwlabel(final); % Uncomment to make compitable with the previous versions of MATLAB®
% Two properties 'BoundingBox' and binary 'Image' corresponding to these
% Bounding boxes are acquired.
Iprops=regionprops(final,'BoundingBox','Image');
% Selecting all the bounding boxes in matrix of order numberofboxesX4;
NR=cat(1,Iprops.BoundingBox);

% Calling of controlling function.
r=controlling(NR); % Function 'controlling' outputs the array of indices of boxes required for extraction of characters.
if ~isempty(r) % If succesfully indices of desired boxes are achieved.
    I={Iprops.Image}; % Cell array of 'Image' (one of the properties of regionprops)
    noPlate=[]; % Initializing the variable of number plate string.
    for v=1:length(r)
        N=I{1,r(v)}; % Extracting the binary image corresponding to the indices in 'r'.
        letter=readLetter(N); % Reading the letter corresponding the binary image 'N'.
        while letter=='O' || letter=='0' % Since it wouldn't be easy to distinguish
            if v<=3                      % between '0' and 'O' during the extraction of character
                letter='O';              % in binary image. Using the characteristic of plates in Karachi
            else                         % that starting three characters are alphabets, this code will
                letter='0';              % easily decide whether it is '0' or 'O'. The condition for 'if'
            end                          % just need to be changed if the code is to be implemented with some other
            break;                       % cities plates. The condition should be changed accordingly.
        end
        noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
    end
    %Las siguientes lineas comentadas almacenan el código de la placa en un
    %archivo txt-----------------------------------------------------------
    %fid = fopen('noPlate.txt', 'wt'); % This portion of code writes the number plate
    %fprintf(fid,'%s\n',noPlate);      % to the text file, if executed a notepad file with the
    %fclose(fid);                      % name noPlate.txt will be open with the number plate written.
    %winopen('noPlate.txt')
    
    setappdata(0, 'codigoplaca', noPlate);%Almacena el código reconocido de la placa para que pueda
    %ser usado en la interfaz y mostrado en el input.
    
%     Uncomment the portion of code below if Database is  to be organized. Since my
%     project requires database so I have written this code. DB is the .mat
%     file containing the array of structure of all entries of database.
%     load DB
%     for x=1:length(DB)
%         recordplate=getfield(DB,{1,x},'PlateNumber');
%         if strcmp(noPlate,recordplate)
%             disp(DB(x));
%             disp('*-*-*-*-*-*-*');
%         end
%     end  
else % If fail to extract the indexes in 'r' this line of error will be displayed.
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end

end