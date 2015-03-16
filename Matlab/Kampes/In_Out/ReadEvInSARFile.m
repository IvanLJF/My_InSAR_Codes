% Function data=ReadEvInSARFile(str, m, n, flag)
%
% Purpose: Read data from a binary file with data dimension of m by n
%          Note that the binary file is from EvInSAR (MFF)
% Input parameter: 
%                  str: a character string of file name
%                  row: data row
%                  col: data column
%                dplot: if plotting ? 'y' or 'n'
% Out put parameter:
%                 Data: Data Matrix (real or complex)
% 
% Original author: GX LIU, 2002-5-6

function Data=ReadEvInSARFile(str, row, col, doplot)

% Open file
str=deblank(str); % Remove trailing blanks from string "str"
fid=fopen(str, 'rb');
if fid==-1 
   error('File cannot be opened')
end

len=length(str);
check_str=str(len-3:len);  % Get the extension of the file name

cpx='no';  % complex matrix flag

if strcmp(check_str,'.b00')==1
   Read_Format= 'uint8';
elseif strcmp(check_str,'.i00')==1
   Read_Format='uint16';
elseif strcmp(check_str,'.r00')==1
   Read_Format='float32';
elseif strcmp(check_str,'.raw')==1    % for Doris32
   Read_Format='float32';               % complex
   col=col*2;
   cpx='yes'
elseif strcmp(check_str,'.j00')==1     % Complex (int, 2 bytes)
   Read_Format='int16';
   col=col*2;
   cpx='yes'
elseif strcmp(check_str,'.x00')==1     % Complex (float, 4 bytes)
   Read_Format='float32';
   col=col*2;
   cpx='yes';
else
   Read_Format= 'uint8';
end

% Loading a matrix generated in EvInSAR
Data_RealImag=fread(fid, [col, row], Read_Format);  % due to in order of column in Mathlib
Data_RealImag=Data_RealImag';
fclose(fid);

%if strcmp(check_str,'.x00')==1 | strcmp(check_str,'.j00')==1
if strcmp(cpx,'yes')==1
   coldiv2=floor(col/2.0);
end

% Processing complex values, i.e., separating real part from imaginary part
%if strcmp(check_str,'.x00')==1 | strcmp(check_str,'.j00')==1   % Complex matrix case
if strcmp(cpx,'yes')==1   
   Data_Real=zeros(row, coldiv2);
   Data_Imag=zeros(row, coldiv2);

   Col_Ctl_Real=1:2:col-1;
   Col_Ctl_Imag=2:2:col;

   Data_Real=Data_RealImag(:,Col_Ctl_Real);   % Extracting real part;
   Data_Imag=Data_RealImag(:,Col_Ctl_Imag);   % Extracting imaginary part
   Data=complex(Data_Real, Data_Imag);   % creating complex matrix

   % plotting the interferogram phases
   if strcmp(doplot,'y')==1
     figure;   
     set(gcf, 'Position', [ 240   242   654   532]);

     Phi=angle(Data);
     imagesc(Phi, [-3.14 3.14]); axis image;
   
     phasemap = deos(256);
     colormap(phasemap);
     c=colorbar('vert');
     c=colorbar;
     set(get(c,'title'),'string','[rad]');
     set(c, 'Position', [0.9 0.28 0.038 0.45]);
     set(gca, 'Position', [0.05 0.1 0.85 0.85]);
   end

else    % real matrix cases
   %Data_Real=Data_RealImag;
   %Data_Imag=0;
   Data=Data_RealImag;
   % plotting the interferogram phases
   if strcmp(doplot,'y')==1
     figure; colormap(gray);
     %Data_Real1=histeq(Data_Real);  % histogram equalisaiton
     imagesc(Data); axis image;
     colorbar('horiz');
   end  
end
            
% reading image
% I=imread('g:\ErrorBudget\Images\SZArea_Amplitude.bmp');
% imshow(I);
