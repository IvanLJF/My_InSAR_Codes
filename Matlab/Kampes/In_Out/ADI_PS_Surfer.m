% extracting PS points from the amplitude dispersion index (ADI) matrix
% and writing the coordinates of all permanent scatterer (PS) points into a textfile 

% read ADI data
unix_ADIs=freadbk('F:\Phoniex\PS_Points\SARimgs.ADI', 3200, 'float32');        
[rows, cols]=size(unix_ADIs);
% locate PS from ADI matrix
[R, C]=find(unix_ADIs<=0.25);      

% open a textfile to write all coordinates of PS points
fid=fopen('F:\Phoniex\PS_Points\Calibrated_PS_Locations.txt', 'wt');

% prepare a post file for Surfer 8.0
%fprintf(fid, '%d, %d\n', length(R), 1);
for i=1:length(R)
    fprintf(fid, '%d    %d\n', cols-C(i)+1, rows-R(i)+1);
end
fclose(fid);
