function phextr(infile1, infile2)
% 这个函数用来从所有的差分干涉图提取时间序列上的PS点相位数据
%  phextr(infile1, infile2);
% 
% This function is used to extract time series phase data of all permannent scatters (PS) 
% from all differential interferograms.
% 
% Input:
%        infile1----------a input text file including filenames of num_intf differential interferograms, e.g.,
%                              num_intf rows cols num_PS    // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                // total number of all PS -- num_PS  
%                              /d1/users/liu/Ph_Results/Dif_Int_MLI/phase/       // directory of interferograms  
%                             19920710_19930521.diff.int2.ph
%                             19920710_19931008.diff.int2.ph
%                             ...............
%                             19991220_20001030.diff.int2.ph 
%                              ............  
%       infile2----------an input binary file of coordinates of all PS points (total number is num_PS) 
%       
% Output:
%        F:\Phoniex\PS_Points\Phase.dat--------output file for differential phase values at all PSs 
%                                                                       (a num_PS-by-num_intf matrix)
%
%  e.g.,  phextr('E:\PhoenixSAR\Dif_Int_MLI\117ints.all', 'F:\Phoniex\PS_Points\PSCoor.dat');
%           phextr('E:\PhoenixSAR\Dif_Int_MLI\117ints.14618', 'F:\Phoniex\PS_Points\test\PSCoor.dat');
%           phextr('E:\PhoenixSAR\Dif_Int_MLI\86ints.all', 'F:\Phoniex\PS_Points\27by15KM\updated\PSCoor.dat'); 
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Mar. 8, 2006: Created, Guoxiang LIU
        
%  open text file including filenames of num_intf differential interferograms        
t0=cputime;
fid1 = fopen(infile1, 'rt');
if (fid1<0) error(ferror(fid1)); end;

% read some basic information about image dimension and PS
num_intf=fscanf(fid1, '%i', 1);    % num_tinf=total number of differential interferograms
rows=fscanf(fid1, '%i', 1);          % rows=total number of rows of interferogram
cols=fscanf(fid1, '%i', 1);           % cols=total number of columns of interferogram                                   
num_PS=fscanf(fid1, '%i', 1);    % num_PS=total number of all PS points                                   
Dirt=fscanf(fid1, '\n%s', 1);        % file directory of interferograms
disp(' ');
disp(['% Total number of all differential interferograms == ', num2str(num_intf)]);
disp(['% The file directory of storing all interferograms == ', Dirt]);
disp(['% Total number of rows of interferogram == ', num2str(rows)]);
disp(['% Total number of columns of interferogram == ', num2str(cols)]);
disp(['% Total number of all PS points == ', num2str(num_PS)]);
%fclose(fid1);

disp(' ');
disp('% Please wait ...... Time series phase data at each PS is extracting ......');
disp(' ');

fid2=fopen('F:\Phoniex\PS_Points\27by15KM\updated\Phase86.dat', 'wb');    % open file for output of time series phase data at all PS points
if (fid2<0) error(ferror(fid2)); end;

PSCoor=zeros(num_PS, 2, 'uint16');     % initialize a matrix to store coordinates of all PS points 
PSCoor=freadbk(infile2, num_PS, 'uint16');
                                            % read coordinates of all PS points
                                            % The 1st column in PSCoor is for range pixels, but the 2nd column is for azimuth pixel
[num_PS1, c]=size(PSCoor);
if (num_PS1~=num_PS) return; end;
loc=zeros(num_PS,1, 'uint32');                     % initialize a matrix to store pixel locations of all PS points
loc=(PSCoor(:,1)-1)*rows+PSCoor(:,2);       % calculate the column-along order of PS locations w.r.t. the interferogram dimension
clear PSCoor;
for j=1:num_intf         % loop on all interferograms
    disp(['% Working on No.', num2str(j), ' differential interferogram ......']);
    filenm=fscanf(fid1, '\n%s', 1);
    str=[Dirt, filenm];
    intph=zeros(rows, cols, 'single');          % initialize a matrix to store interferogram phase data 
    PSPh=zeros(num_PS, 1, 'single');       % initialize a matrix to store time series phase values of all PS points
    intph=freadbk(str, rows, 'float32');         % read entire interferogram phase data
    PSPh=intph(loc);                                    % extract phase values
    fwrite(fid2, PSPh', 'float32');                   % write phase data 
    clear intph PSPh;
end

% partition of PS points
% K=50000;                             % set the row-along block size
% RN=ceil(num_PS/K);                      % total number of along-row groups (partition of the entire PS coordinates)
% disp(' ');
% disp(['Total groups of PS points == ', num2str(RN)]);
% for i=1:RN                        % loop on all blocks of PS points
%     disp(['% Working on No.', num2str(i), ' group ......']);
%     if i<RN 
%           r0=K*(i-1)+1;
%           rN=K*i;
%     else
%            r0=K*(i-1)+1;
%            rN=num_PS;
%     end
%     PSCoor=freadbk(infile2, num_PS, 'uint32', r0, rN, 1, 2);
%                           % The 1st column in PSCoor is for range pixels, but the 2nd column is for azimuth pixel
%     n=rN-r0+1;    % get total number of PS points in this group
%     PSPh=zeros(n, num_intf);         % initialize a matrix to store time series phase values of this group of PS points
%     loc=zeros(n,1);                         % initialize a matrix to store pixel locations of this group of PS points
%     loc=(PSCoor(:,1)-1)*rows+PSCoor(:,2);    % calculate the column-along order of PS locations w.r.t. the interferogram dimension
%     
%     fid1= fopen(infile1, 'rt');
%     temp=fscanf(fid1, '%i', 4);
%     Dirt=fscanf(fid1, '\n%s', 1);                 
%     for j=1:num_intf                  % loop on all interferograms
%         filenm=fscanf(fid1, '\n%s', 1);
%         str=[Dirt, filenm];
%         intph=freadbk(str, rows, 'float32');    % read entire interferogram phase data
%         PSPh(:,j)=intph(loc);                              % extract phase values
%     end
%     fclose(fid1);
%     fwrite(fid2, PSPh', 'float32');                     % write phase data
%     clear PSPh;
% end    
fclose(fid1);
fclose(fid2);
disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);
disp('Success in phase extraction!');
disp(' ');        
 