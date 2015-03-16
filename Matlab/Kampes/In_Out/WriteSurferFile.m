% Function WriteSurferFile(data, str)
%
% Purpose: Write a Matlab matrix into a  binary file of Surfer 7 grid data 
%          Note that the binary file is Surfer (*.grd), and only Surfer
%          7 grid is supported.
% Input parameter: 
%                  str: a character string of file name
%                  data: a Matlab matrix
%                  xLL: x coordinate at the left-lower corner
%                  yLL: y coordinate at the left-lower corner
%                  xSize: cell size in x-dimension
%                  ySize: cell size in y-dimension
% 
% Original author: GX LIU, 2006-5-8, UTA

function WriteSurferFile(str, data, xLL, yLL, xSize, ySize)

ID_Header=1112691524;
ID_Grid=1145655879;
ID_data_section=1096040772;
Length_Header_Byte=72;

[nRow, nCol]=size(data);      % get the size of matrix
zMin=min(min(data));            % get minimum 
zMax=max(max(data));         % and maximum value in the matrix
Rotation=0;
BlankValue=1.70141e+038;
II=isnan(data);                       % find out NaN
JJ=find(II==1);
data(JJ)=BlankValue;            % replace NaN by 1.70141e+038
Length_Data_Byte=nRow*nCol*8;    %  Length in bytes of the data section (nRow x nCol x 8 bytes per double)

% Open file
str=deblank(str); % Remove trailing blanks from string "str"
fid=fopen(str, 'wb');
if fid==-1 
   error('File cannot be opened')
end

% Writing the file header of Surfer Gridding data
fwrite(fid, ID_Header, 'uint32');             % long;  Tag: Id for Header section
fwrite(fid, 4, 'uint32');                            % long;  Tag: Size of Header section
fwrite(fid, 1, 'uint32');                            % long;  Header Section: Version

% Writing basic information: grid size, coordinates at the left-lower corner
fwrite(fid, ID_Grid, 'uint32');                                   % long;  Tag: ID indicating a grid section
fwrite(fid, Length_Header_Byte, 'uint32');        % long;  Tag: Length in bytes of the grid section

fwrite(fid, nRow, 'uint32');                       % long; Grid Section: nRow
fwrite(fid, nCol, 'uint32');                         % long; Grid Section: nCol

fwrite(fid, xLL, 'float64');                          % double; Grid Section: xLL
fwrite(fid, yLL, 'float64');                      % double; Grid Section: yLL

fwrite(fid, xSize, 'float64');                     % double; Grid Section: xSize
fwrite(fid, ySize, 'float64');                     % double; Grid Section: ySize 

fwrite(fid, zMin, 'float64');                       % double; Grid Section: zMin
fwrite(fid, zMax, 'float64');                      % double; Grid Section: zMax 

fwrite(fid, Rotation, 'float64');                 % double; Grid Section: Rotation
fwrite(fid, BlankValue, 'float64');             % double; Grid Section: BlankValue
 
fwrite(fid, ID_data_section, 'uint32');       % long; Tag: ID indicating a data section
fwrite(fid, Length_Data_Byte, 'uint32');   % long; Tag: Length in bytes of the data section 

% saving a matrix into Surfer 7 grid data
data=flipud(data);                                    % consider the different data arrangement between Surfer and Matlab
data=data';
fwrite(fid, data, 'float64');  % due to in order of column in Matlab
fclose(fid);