function [nPnts, JJ, atmeff, nlrdef]=svd_emd_test(infile, rows, cols)
% 注意到下述的处理过程是基于PS到PS构成的点图来实行的。第一：获取PS点解缠相位值的时间序列；
% 第二：通过SVD（奇异值分解）把绝对相位值转换为图像数据；
% 第三：通过EMD（经验模式分解）从非线性形变中分离大气的影响。
%  function [atmeff, nlrdef]=svd_emd_test(infile, rows, cols);
%
% Note the following processing is based on the schema of pixel by pixel.
%        First, extract the time series of the unwrapped-phase values at a given pixel,
%        Second, invert the absolute phase value corresponding to each
%                   imaging date by means of singular value decomposition (SVD),
%        Third, separate atmospheric effects from non-linear deformations by means
%                   of Empirical Mode Decomposition (EMD).
% 
% Input:
%        infile-----------------a input text file including filenames of num_intf differential interferograms, e.g.,
%                                    num_intf rows cols num_PS       // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                         // total number of all PS -- num_PS  
%                                    E:\PhoenixSAR\Dif_Int_MLI\        // directory of interferograms  
%                                   19920710_19930521.diff.int2.ph
%                                   19920710_19931008.diff.int2.ph
%                                   ...............
%                                   19991220_20001030.diff.int2.ph   
%        rows---------------the total number of the unwrapped-phase matrix
%        cols----------------the total number of the unwrapped-phase matrix
%
% Output 
%        nPnts--------------total number of valid pixels with non-NaN values
%        JJ------------------a nPnts-by-1 vector corresponding to the indices of pixels with non-NaN values
%        atmeff-------------a nPnts-by-num_imgs matrix storing atmospheric effects
%        nlrdef--------------a nPnts-by-num_imgs matrix storing non-linear deformations
%              
%  e.g., [nPnts, JJ, atmeff, nlrdef]=svd_emd_test('E:\PhoenixSAR\Dif_Int_MLI\117ints.all', 750, 1350);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 15, 2006: Created, Guoxiang LIU

t0=cputime;

% Imaging dates of fourty SAR images over Phoenix study area
msDates=[19920710    19920814    19920918    19921023    19930205    19930521    19930903    19931008    19931217  ...
                  19950514    19950827    19951105    19951106    19951210    19951211    19960218    19960219    19960428  ...
                  19960603    19960812    19960916    19961021    19961230    19970310    19970519    19971215    19980223  ...
                  19980330    19980504    19980608    19980713    19981130    19990315    19990524    19990628    19990802  ...
                  19991220    20000508    20000925    20001030]; 
num_imgs=length(msDates);  % get total number of SAR images
% The total number of ERS SAR images over Phoenix is 45. But there are other five SAR images
% which are not used and thus not included in the above list. They are: 19960114  19960115  19961125  19990104  20000717
 
% To save memory, the following trick is used.
V_mask=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'n');          
                     % Velocity matrix in mm/year (derived by Kriging
                     % interpoltation). This deformation velocity field had been already blanked with Surfer.
V_mask=fliplr(V_mask);   % flip horizontally
% generate a mask file needed by phase unwrapping
II=isnan(V_mask);
JJ=find(II==0);         % JJ correspond to the indices of pixels with non-NaN values,
                                % and will be used later on.
nPnts=length(JJ);   % total number of valid pixels
clear V_mask II;

% open text file including filenames of num_intf differential interferograms   
fid = fopen(infile, 'rt');
if (fid<0) error(ferror(fid)); end;
% read some basic information about image dimension and PS
num_intf=fscanf(fid, '%i', 1);    % num_tinf=total number of differential interferograms
temp=fscanf(fid, '%i', 3);          % skipping ...
temp=fscanf(fid, '\n%s', 1);      % skipping ...
Dirt='E:\PhoenixSAR\Dif_Int_MLI_LPF\';   % the directory for the unwrapped-phase maps
disp(' ');
disp(['% Total number of all the unwrapped residual-phase maps to be processed == ', num2str(num_intf)]);
disp(['    The file directory of storing all the unwrapped-phase maps == ', Dirt]);

% Allocate memory for several matrices
unw=zeros(nPnts, num_intf, 'single');         % a matrix storing unwrapped phases, size = nPnts X num_intf
absPhi=zeros(nPnts, num_imgs-1, 'single');           % a matrix storing inversed phase values at imaging dates for all valid pixles
dT=zeros(1, num_intf);                                % time intervals in years for all interferograms
B=zeros(num_intf, num_imgs-1);               % design matrix for SVD, it should be a sparse matrix with ones and most of zeros
dph=zeros(num_intf,1);                               % constant vector for SVD

for m=1:num_intf         % loop on all unwrapped-phase maps
    filenm=fscanf(fid, '\n%s', 1);
    master=filenm(1:8);              % get master name
    slave=filenm(10:17);             % get slave name
    fm=[master, '_', slave, '.diff.int2.unw'];
    str=[Dirt, fm];
    %unwph=freadbk(str, rows, 'float32');         % read in unwrapped data
    %unw(:,m)=single(unwph(JJ))-unwph(1);           % extract non-NaN elements and do calibration w.r.t the first element  ?????????????????
    
    % get the elements of the design matrix for SVD
    dT(m)=(datenum(slave, 'yyyymmdd')-datenum(master, 'yyyymmdd'))/365;    % time interval in years between master and slave image
    mN=find(msDates==str2num(master));       % No. of master image
    sN=find(msDates==str2num(slave));           % No. of slave image
%     if mN==1
%         B(m, sN-1)=1;
%     else
%         B(m, mN-1)=-1;
%         B(m, sN-1)=1;
%     end
B(m, mN:1:sN-1)=1;
    ttt=1;
end
clear unwph;
fclose(fid);

% calibrating unwrapped phase data
% see above ??????????????????????

% Invert the absolute phase values by SVD on pixel-by-pixel basis
% when there are several subsets of interferograms.
% [U,S,V] = svd(B);    % Do SVD on the design matrix B
% for i=1:num_intf
%     for j=1:num_imgs-1
%         if (i==j & S(i,j)>0.001)
%             S(i,j)=1/S(i,j);
%         end
%     end
% end
% for i=1:nPnts
%     absPhi(i,:)=(single((V*S'*U'*unw(i,:)')'))';
% end

% Invert the absolute phase values by LS when there are only one set of
% interferograms
N=B'*B;                % Normal matrix
for i=1:nPnts
     w=B'*unw(i,:)';   % coefficient matrix
     absPhi(i,:)=(single(N\w))';
     figure; plot(absPhi(i,:));
     close all;
end
clear unw;

% Separate atmospheric effects from non-linear deformations by EMD
atmeff=zeros(nPnts, num_imgs, 'single');           % a matrix storing atmospheric effects
nlrdef=zeros(nPnts, num_imgs, 'single');            % a matrix storing non-linear deformations
options.display = 0;
options.fix = 10;
options.maxmodes = 4;
for i=1:nPnts
    [imf,ort,nbits] = emd(absPh(i,:),options);
    % get atmospheric components
     atmeff(i,:)=single(imf(1,:)+imf(:,2));
    % get nonlinear deformation components
    nlrdef(i,:)=single(imf(3,:)+imf(:,4));
end

% save as atmeff and nlrdef into files

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');
