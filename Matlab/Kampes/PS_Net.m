function PS_Net(infile, numlines, r0, rN, c0, cN)
% 这个函数利用振幅利差指数来获取PS点，并用所有探测到的PS点构建一个自由网。弧段编码矩阵也随此产生。
%%function PS_Net(infile, numlines, r0, rN, c0, cN);
%
% This function is used to extract PS points with amplitude dispersion index,
% and form a  freely-connected network with all the detected permannent scatters (PS).
% The coding matrix for all arcs is also generated.
%
% Input:
%        infile------------file name storing the matrix of amplitude dispersion index (ADI)
%        numlines------total number of rows of the ADI matrix
%        r0, rN----------starting and ending rows of interest (cropped) in the ADI matrix
%        c0, cN---------starting and ending columns of interest (cropped) in the ADI matrix
%
% Output:
%        PSCoorN.dat-----output file of coordinates of all PS points with same directory as infile
%                                    matrix size == num by 2 (num is the total number of all PS points)
%        PSArcsN.dat-----output file of all-arc information with same directory as infile
%                                   matrix size == k by 2 (K is the total number of all arcs)
%
%  e.g.,        PS_Net('F:\Phoniex\PS_Points\test\Mat_ADIs.dat', 3200, 751, 1500, 2051, 3400);
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   June. 30, 2006: Created, Guoxiang LIU
%
% See also PS_DETECT, DISP_TRI

t0=cputime;     % the starting time of the operation

% finding out PS candidates
ADIs=freadbk(infile, numlines, 'float32', r0, rN, c0, cN);    % read in ADI data with cropping
Amp_mean=freadbk('F:\Phoniex\PS_Points\Mat_Mean_Amp.dat', numlines, 'float32', r0, rN, c0, cN);  % read in the mean amplitude matrix
am=mean2(Amp_mean);     % caculate the mean of the mean amplitude matrix
astd=std2(Amp_mean);       % caculate the std of the mean amplitude matrix
%ADIs=freadbk(infile, numlines, 'float32');    % reading ADI data with cropping
disp(' ');
disp('% Finding out all PS candidates ......');
[Row, Col]=find(ADIs<=0.28 & Amp_mean>=am+2*astd);    %+2*astd));                   % try the more rigorous threshold

% remove the points located in a big noise area; special processing for the
% study area [751, 1500, 2051, 3400], which is separated by a line. Its
% equation is (y-750)/(x-650)=(150-750)/(1350-650)
x=[650:1:1350];                   % column         
y=-x*6/7+650*6/7+750;      % compute row-by-row coordinates along the separation line 
for i=1:length(Row)            % loop on all PS candidates
    if Col(i)>650
        II=find(x==Col(i));
        if Row(i)>y(II)
            Row(i)=-100;
            Col(i)=-100;
        end
    end
end          
II=find(Row>0);
Row=Row(II);        % get rid of noise points
Col=Col(II);            % .....
XY_PS=[Col+c0-1, Row+r0-1];                 % get coodinates of all PS pixels, a K-by-2 matrix
                                                                   % note that the pixel coordinates are converted into the frame of 
                                                                   % the original entire ADI matrix so that the subsequent phase extraction will not be confused. 
XY_PS=unique(XY_PS, 'rows');                % remove possible duplications
num_PS=length(XY_PS(:,1));
clear ADIs Amp_mean Row Col II Row Col x y am astd;
disp(['% Total number of all PS points == ', num2str(num_PS)]);
[pathstr, name] = fileparts(infile);
str='PSCoorN.dat';
fwritebk(XY_PS, [pathstr, '\', str], 'uint16');        % saving PS coordinates
disp(['% Saving coordinates of all PS points into ', pathstr, '\', str, ', OK!']);

% forming freely-connected network with all PS points
disp(' ');
disp('% Generating freely-connected network with PS points ......');
X=XY_PS(:, 1);
Y=XY_PS(:, 2);
clear XY_PS;
str='PSArcsN.dat';                                                      % filename storing arcs
fid=fopen([pathstr, '\', str], 'ab');  
num_Arcs=0;                                                              % initialize the total number of arcs
for i=1:num_PS
    PN=[i+1:num_PS]';                                                   % get numbers of points
    XYPS1=[X(i)*ones(length(PN), 1), Y(i)*ones(length(PN), 1)];       % coordinate of starting point
    XYPS2=[X(i+1:num_PS), Y(i+1:num_PS)];            % coordinate of ending point
    ArcDist=(sum((XYPS1-XYPS2).^2, 2).^0.5)*20;      % caculate Euclidean distance, 1-pixel unit == 20 m
    II=find(ArcDist<=1000);                                            % look for short arcs with distance less than 1000 m
    PNI=PN(II);                                                               % get valid points that can be connected with the ith point  
    PN0=ones(size(PNI))*i;                                           % starting point for each arc
    PN0I=[PN0, PNI];                                                     % starting-ending points for all arcs 
    fwrite(fid, PN0I', 'uint16');
    num_Arcs=num_Arcs+length(PNI);
    clear XYPS1 XYPS2 PN ArcDist II  PNI PN0  PN0I;
end
fclose(fid);
disp(['% Total number of arcs with geometrical distance less than 1 km == ', num2str(num_Arcs)]);
disp(['% Saving all final arcs less than 1 km into ', pathstr, '\', str, ', OK!']);
clear X Y;

disp(' ');
disp('% Success in generating freely-connected network and extracting arc information!');

disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');

    
 