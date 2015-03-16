% Function GridData=ReadSurferFile(str, flag)
%
% Purpose: Read data from a binary file of gridding data
%          Note that the binary file is from Surfer (grd), and only Surfer
%          7 grid is supported.
% Input parameter: 
%                  str: a character string of file name
%                dplot: if plotting ? 'y' or 'n'
% Out put parameter:
%                 GridData: Data Matrix (real)
% 
function GridData=ReadSurferFile(str, doplot)

% Open file
% Original author: GX LIU, 2005-5-20

str=deblank(str); % Remove trailing blanks from string "str"
fid=fopen(str, 'rb');
if fid==-1 
   error('File cannot be opened');
end

% Reading the file header of Surfer Gridding data
ID_Header=fread(fid, 1, 'uint32');
Size_Header=fread(fid, 1, 'uint32');
Version=fread(fid, 1, 'uint32');
ID_Grid=fread(fid, 1, 'uint32');
Length_Header_Byte=fread(fid, 1, 'uint32');

% Reading basic information: grid size, coordinates at the left-lower corner
nRow=fread(fid, 1, 'uint32');
nCol=fread(fid, 1, 'uint32');

xLL=fread(fid, 1, 'float64');
yLL=fread(fid, 1, 'float64');

xSize=fread(fid, 1, 'float64');
ySize=fread(fid, 1, 'float64');

zMin=fread(fid, 1, 'float64');
zMax=fread(fid, 1, 'float64'); 

Rotation=fread(fid, 1, 'float64'); 
BlankValue=fread(fid, 1, 'float64'); 
ID_data_section=fread(fid, 1, 'uint32');
Length_Data_Byte=fread(fid, 1, 'uint32'); 

% Loading a matrix of gridding data
GridData=fread(fid, [nCol, nRow], 'float64');  % due to in order of column in Matlab
GridData=flipud(GridData');
fclose(fid);
II=find(GridData>1.70141e+030);   % Changed by GX LIU, 2009-7-1
GridData(II)=NaN;

 % plotting the grid data
   if strcmp(doplot,'y')==1
     figure;   
     set(gcf, 'Position', [ 240   242   654   532]);
     imagesc(GridData); axis image;
     colormap(jet);
     c=colorbar('vert');
 end