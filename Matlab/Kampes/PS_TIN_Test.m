function PS_TIN_Test(infile, numlines, r0, rN, c0, cN)
% 这个函数利用振幅利差指数来获取PS点，并用所有探测到的PS点构建一个自由网。弧段编码矩阵也随此产生。
%%function PS_TIN_Test(infile, numlines);
%
% This function is used to extract PS points with amplitude dispersion index,
% and form a  triangular irregular network with all the detected permannent scatters (PS).
% The coding matrix for each triangular arc is also generated.
%
% Input:
%        infile------------file name storing the matrix of amplitude dispersion index (ADI)
%        numlines------total number of rows of the ADI matrix
%        r0, rN----------starting and ending rows of interest (cropped) in the ADI matrix
%        c0, cN---------starting and ending columns of interest (cropped) in the ADI matrix
%
% Output:
%        PSCoor.dat-----output file of coordinates of all PS points with same directory as infile
%                                 matrix size == num by 2 (num is the total number of all PS points)
%        PSTIN.dat-------output file of TIN information with same directory as infile
%                                 matrix size == L by 3 (L is the total number of all triangles)
%        PSArcs.dat-----output file of all-arc information with same directory as infile
%                                 matrix size == k by 2 (K is the total
%                                 number of all arcs in TIN)
%
%  e.g.,        PS_TIN_Test('F:\Phoniex\PS_Points\test\Mat_ADIs.dat', 3200, 751, 1500, 2051, 3400);
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   Mar. 8, 2006: Created, Guoxiang LIU
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
num=length(XY_PS(:,1));
clear ADIs Amp_mean Row Col;
disp(['% Total number of all PS points == ', num2str(num)]);
[pathstr, name] = fileparts(infile);
str='PSCoor.dat';
fwritebk(XY_PS, [pathstr, '\', str], 'uint16');        % saving PS coordinates
disp(['% Saving coordinates of all PS points into ', pathstr, '\', str, ', OK!']);

% forming TIN with all PS points
disp(' ');
disp('% Generating triangular irregular network with PS points ......');
TRI_PS=delaunay(XY_PS(:, 1)', XY_PS(:, 2)');
TRI_PS=uint32(TRI_PS);       % convet from double to uint for saving memory
[L, C]=size(TRI_PS);
disp(['% Total number of all triangles == ', num2str(L)]);
str='PSTIN.dat';
fwritebk(TRI_PS, [pathstr, '\', str], 'uint32');        % saving vertex information of all triangles
disp(['% Saving all TINs into ', pathstr, '\', str, ', OK!']);
%clear XY_PS;
%NN=L*3;                       % total number of all possible arcs
arc=zeros(L, 2, 'uint32');

disp(' ');
disp('% Generating three groups of arcs with TIN and removing arc duplication in each group ......');
% forming initial arcs, and removing duplication
% TRI_PS=sortrows(sort(TRI_PS, 2));  % sorting
num_arcs=zeros(1,3);
for i=1:3
    if i==1
        arc=[TRI_PS(:,1), TRI_PS(:,2)];
        str='arc12.dat';
    end
    if i==2
        arc=[TRI_PS(:,1), TRI_PS(:,3)];
        str='arc13.dat';
    end
    if i==3
        arc=[TRI_PS(:,2), TRI_PS(:,3)];
        str='arc23.dat';
    end
    [num_arcs(i), ARCs]=sortrmvl(arc);    % sorting arcs and removing arc duplication
                                                                  % num_arcs(i)---------total number of arcs 
                                                                  % ARC_PS-------------matrix of arcs 
    disp(['% Total number of arcs for ', str, ' == ', num2str(num_arcs(i))]);
    disp(['     Saving arcs into ', pathstr, '\', str]);
    fwritebk(ARCs, [pathstr, '\', str], 'uint32');
end
clear arc ARCs;
clear TRI_PS;

% further processing: combination and sorting of three groups of arcs with
% removal of arc duplication
disp(' ');
disp('% Combining three groups of arcs and removing arc duplication ......');
str=[pathstr, '\', 'arc12.dat'];
arc12=freadbk(str, num_arcs(1), 'uint32');
delete(str);
str=[pathstr, '\', 'arc13.dat'];
arc13=freadbk(str, num_arcs(2), 'uint32');
delete(str);
arc=uint32([arc12; arc13]); 
[L, C]=size(arc);
disp(['% Total number of arcs in raw groups == ', num2str(L)]);
clear arc12 arc13;
[k, ARCs]=sortrmvl(arc);    % sorting arcs and removing arc duplication
                                                 % k---------total number of arcs 
                                                 % ARC_PS-------------matrix of arcs 
disp(['% Total number of arcs for No.1 and 2 group == ', num2str(k)]);
str=[pathstr, '\', 'arc23.dat'];
arc23=freadbk(str, num_arcs(3), 'uint32');
delete(str);
arc=uint32([ARCs; arc23]);
[L, C]=size(arc);
disp(['% Total number of arcs in raw groups == ', num2str(L)]);
clear ARCs;
[k, ARCs]=sortrmvl(arc);         % sorting arcs and removing arc duplication
                                                 % k---------total number of arcs 
                                                 % ARC_PS-------------matrix of arcs 
disp(['% Total number of arcs for No.1, 2 and 3 group == ', num2str(k)]);

% delete the arcs with geometric length larger than 1 km
disp(' ');
disp('% Deleting arcs with length larger than 1 km ......');
X=XY_PS(:, 1);
Y=XY_PS(:, 2);
PN=ARCs;
clear ARCS;
XYPS1=[X(PN(:, 1)), Y(PN(:, 1))];                        % coordinate of starting point at arc
XYPS2=[X(PN(:, 2)), Y(PN(:, 2))];                        % coordinate of ending point at arc
ArcDist=(sum((XYPS1-XYPS2).^2, 2).^0.5)*20;      % caculate Euclidean distance, 1-pixel unit == 20 m
II=find(ArcDist<=1000);                                      % look for short arcs with distance less than 1000 m
ARCs=PN(II,:);                                   
str='PSArcs.dat';
disp(['% Total number of arcs after deleting those larger than 1 km == ', num2str(length(II))]);
fwritebk(ARCs, [pathstr, '\', str], 'uint32');
disp(['% Saving all final arcs less than 1 km and without arc duplication into ', pathstr, '\', str, ', OK!']);
clear XY_PS X Y XYPS1 XYPS2 ArcDist II PN ARCs;

disp(' ');
disp('% Success in generating TIN and arc information!');

disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');
% the total CPU time used for all computation and plotting
%clear all;

function [num, ARC_PS]=sortrmvl(arc);
% sorting the arcs and removing arc duplication
    arc=sort(uint32(arc), 2);              % sorting along row dimension
    arc=sortrows(uint32(arc), 2);      % sorting along the second-column ascending order
    arc=sortrows(uint32(arc), 1);      % sorting along the first-column ascending order
       
    % removing the duplicated arcs
    %II=diff([0, 0; arc],1,1);     % the 1st order difference along the row dimension,
            %II=temp(:,1)-temp(:,2);
            %clear temp;
    %JJ=find(II(:,1)~=0 | II(:,2)~=0);
    %ARC_PS=arc(JJ, :);         % get the all independent arcs
    %num=length(JJ);     % total number of all arcs in TIN
    ARC_PS=unique(arc, 'rows');     % removing the row-along repetitions 
    [num, c]=size(ARC_PS);           % total number of arcs
    clear arc c;  
      
    
 