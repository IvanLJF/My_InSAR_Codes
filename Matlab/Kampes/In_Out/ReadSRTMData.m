% Function to Reading SRTM3 Data (DEM file *.HGT) -- Digital Terrain Elevation Data (DTED) 
% This function only works over the version 7 of Matlab. 
%
% The DEM is provided as 16-bit signed integer data in a simple binary raster. There are no header
% or trailer bytes embedded in the file. The data are stored in row major order (all the data for row
% 1, followed by all the data for row 2, etc.).
%
% Byte order is Motorola ("big-endian") standard with the most significant byte first. Since they are
% signed integers elevations can range from -32767 to 32767 meters, encompassing the range of
% elevation to be found on the Earth.
%
% These data also contain occassional voids from a number of causes such as shadowing, phase
% unwrapping anomalies, or other radar-specific causes. Voids are flagged with the value -32768.
%
%  Summary of SRTM3 DEM data:
%  - Heights are in meters referenced to the WGS84 geoid.
%  - Data voids are assigned the value -32768.
%  - SRTM-3 files contain 1201 lines and 1201 samples.
%  - The rows at the north and south edges as well as the columns at the
%    east and west edges of each cell overlap and are identical to the
%    edge rows and columns in the adjacent cell.
%  - Stored row-by-row, with most North row first.
%
% Created by Guoxiang Liu
% Date: Jan. 3, 2006

% Reading the left-lower block (1X1-degree DEM)
fid=fopen('F:\SRTM DEM Information\Kunlun SRTM DEM\N35E090.hgt', 'r', 'ieee-be');
                                                            % 'ieee-be' is set for the variable -- MACHINEFORMAT
                                                            % The original DEM is prepared for some computers like SUN with big-endian byte ordering. 
                                                            % But for our PCs, we need to use 'ieee-be' to force FOPEN and FREAD to swap such byte ordering. 
                                                            % Otherwise, we will get totally wrong data. This specification is truely important !!!! 
                                                            % Such byte-swap function is invalid with Matlab 6.5, and only works with Matlab 7.
LL=fread(fid, [1201, 1201], 'int16', 'ieee-be');   
LL(find(LL==-32768))=0;                  % Replacing the data voids with 'NaN' to avoid the incorrect computation or display in Matlab
LL=LL';                                                   % Because FREAD reads elements to fill a M-by-N matrix in column order. 
fclose(fid);

% Reading the right-lower block (1X1-degree DEM)
fid=fopen('F:\SRTM DEM Information\Kunlun SRTM DEM\N35E091.hgt', 'r', 'ieee-be');
RL=fread(fid, [1201, 1201], 'int16', 'ieee-be');   
RL(find(RL==-32768))=0;                 
RL=RL';                                                   
fclose(fid);

% Reading the left-upper block (1X1-degree DEM)
fid=fopen('F:\SRTM DEM Information\Kunlun SRTM DEM\N36E090.hgt', 'r', 'ieee-be');
LU=fread(fid, [1201, 1201], 'int16', 'ieee-be');    
LU(find(LU==-32768))=0;                  
LU=LU';                                                   
fclose(fid);

% Reading the right-upper block (1X1-degree DEM)
fid=fopen('F:\SRTM DEM Information\Kunlun SRTM DEM\N36E091.hgt', 'r', 'ieee-be');
RU=fread(fid, [1201, 1201], 'int16', 'ieee-be');   
RU(find(RU==-32768))=0;                  
RU=RU';                                                 
fclose(fid);

% Stitching all four blocks (LL, RL, LU, RU) together
% The rows at the north and south edges as well as the columns at the east
% and west edges of each block overlap and are identical to the edge rows and columns in the
% adjacent block.
ALL=zeros(1201+1200, 1201+1200);
ALL=[LU, RU(:,2:1201); LL(2:1201,:), RL(2:1201, 2:1201)];

% Disply the stitched DEM
figure; imagesc(ALL); colormap(gray); axis image; colorbar;

% Statistics to ALL
disp(['Minimum Elevation=', num2str(min(min(ALL)))])
disp(['Maximum Elevation=', num2str(max(max(ALL)))])
%disp(['Mean of Elevations=', num2str(mean2(ALL))])
%disp(['Standard Deviation of Elevations=', num2str(std2(ALL))])


