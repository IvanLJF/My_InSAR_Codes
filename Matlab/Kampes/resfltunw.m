function resfltunw(infile1, r0, rN, c0, cN)
% 通过去除每个不同干涉图中的线性矢量和DEM误差计算残差相位。施行空间低通滤波（滤波窗口为1km*1km）
% 随后利用残差相位，使用Ghiglia和Pitt方法进行相位解馋。
%  function resfltunw(infile1);
% Computing residual phases by removing linear velocity and DEM error from each differential interferogram, 
% Conducting spatial low pass filtering (filter-window size == 1 km by 1km), 
% And doing phase unwrapping on the residual phases by the program of Ghiglia and Pritt (1998)
% Input:
%        infile1---------------a input text file including filenames of num_intf differential interferograms, e.g.,
%                                    num_intf rows cols num_PS       // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                         // total number of all PS -- num_PS  
%                                    E:\PhoenixSAR\Dif_Int_MLI\        // directory of interferograms  
%                                   19920710_19930521.diff.int2.ph
%                                   19920710_19931008.diff.int2.ph
%                                   ...............
%                                   19991220_20001030.diff.int2.ph   
%        r0, rN--------------starting and ending rows of interest (cropped) in the original interferogram
%        c0, cN-------------starting and ending columns of interest (cropped) in the original interferogram
% Output files
%        Residual-phase data:
%       19920710_19930521.diff.int2.lpf  19920710_19931008.diff.int2.lpf
%       ..................................................   19991220_20001030.diff.int2.lpf 
%        Unwrapped-phase data
%       19920710_19930521.diff.int2.unw  19920710_19931008.diff.int2.unw
%       .....................................................   19991220_20001030.diff.int2.unw 
%  e.g., resfltunw('E:\PhoenixSAR\Dif_Int_MLI\117ints.all', 751, 1500, 2051, 3400);
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 2, 2006: Created, Guoxiang LIU
%
% See also BCUNW RESPSUNW  PSLSUNW CONGRUENCE LSUNW_TEST 

t0=cputime;

% read in velocity field and DEM errors estimated by functions --- "dvddharcs" and "grserrls" 
% To consider mask area, the following trick is used.
V_mask=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'n');          
                     % Velocity matrix in mm/year (derived by Kriging
                     % interpoltation). This deformation velocity field had been already blanked with Surfer.
V_mask=fliplr(V_mask);   % flip horizontally

disp(' ');
disp('% Reading a velocity field ...');
V=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV_Full.grd', 'n');          % Velocity matrix in mm/year (derived by Kriging interpoltation)
V=fliplr(V);   % flip horizontally

disp('    Reading a elevation-error field ...');
dH=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XY_dH_Full.grd', 'n');    % Height-error matrix in m (derived by Kriging interpoltation)
dH=fliplr(dH);  % flip horizontally

% generate a mask file needed by phase unwrapping
mask=ones(size(V_mask));
II=isnan(V_mask);
JJ=find(II==1);         % JJ will be used later on
mask(JJ)=0;            % set to 0 when it is a NaN
maskfile='E:\PhoenixSAR\Dif_Int_MLI_LPF\mask.dat';
disp(['    Writing the mask flags for phase unwrapping into ', maskfile]);
fwritebk(mask, maskfile, 'uint8');
clear II V_mask mask 

% open text file including filenames of num_intf differential interferograms   
fid = fopen(infile1, 'rt');
if (fid<0) error(ferror(fid)); end;
% read some basic information about image dimension and PS
num_intf=fscanf(fid, '%i', 1);    % num_tinf=total number of differential interferograms
rows=fscanf(fid, '%i', 1);          % rows=total number of rows of the entire interferogram
cols=fscanf(fid, '%i', 1);           % cols=total number of columns of the entire interferogram                                   
num_PS=fscanf(fid, '%i', 1);    % num_PS=total number of all PS points               
Dirt=fscanf(fid, '\n%s', 1);        % file directory of interferograms
disp(' ');
disp(['% Total number of all differential interferograms to be processed == ', num2str(num_intf)]);
disp(['    The file directory of storing all differential interferograms == ', Dirt]);

disp(' ');
disp('% Please wait ...... Computing residual phases, filtering and unwrapping ......');

for m=1:num_intf         % loop on all interferograms
    disp(' ');
    disp(['% Working on No.', num2str(m), ' differential interferogram ......']);
    filenm=fscanf(fid, '\n%s', 1);
    str=[Dirt, filenm];
    disp(['           Reading differential interferogram: ', str]);
    intph=freadbk(str, rows, 'float32', r0, rN, c0, cN);         % read a part of differential interferogram phase data
    [R, C]=size(intph);
    master=filenm(1:8);              % get master name
    slave=filenm(10:17);             % get slave name
    dT=(datenum(slave, 'yyyymmdd')-datenum(master, 'yyyymmdd'))/365;    % time interval in years between master and slave image
                                                                                                                          % 
    Lamda=56;   % ERS C-band radar wavelength in mm
    L1=4*pi/Lamda;                % Constant 1
    
    diskSize=12;                                   % filter window will be (diskSize*2+1) by (diskSize*2+1)
    H=fspecial('disk', diskSize);            % disk filter with window size of 49 by 49, equivalent to 500 m by 500 m 
                                                            % Note: other filters are 'average', 'gaussian', and 'sobel' etc., 
                                                            % but I feel that 'disk' is more suitable for filtering interferogram than others.  

    if m==1
        [x_col, y_row]=meshgrid(1:1:C, 1:1:R);
        X=reshape(x_col, prod(size(x_col)), 1)+c0-1;           % Note: convert to the original image coordinate system
        Y=reshape(y_row, prod(size(y_row)), 1)+r0-1;         % Note: convert to the original image coordinate system
        clear x_col y_row;
    end
    
    disp('           Computing interferometric parameters and subtracting phase trend');
    [thi, Rg, Bperp]=basecomp(Y, X, str2num(master), str2num(slave));   
      
    coef_v=L1*dT;                                           % Coefficient for range displacement, which is same for all pixels
    coef_dh=L1*1000*Bperp./(Rg.*sin(thi));     % Coefficient for height error, which is varying pixel by pixel
    coef_dh=reshape(coef_dh, R, C);
    
    phi=coef_v*V+coef_dh.*dH;              % Calculate the absolute phase due to linear velocity and DEM error
    Res=exp(j*intph).*conj(exp(j*phi));    % removing the deterministic parts related to linear deformation rates and DEM errors
        
    % Spatial low-pass filtering
    %windowSize=50;
    %h=ones(windowSize, windowSize)/(windowSize^2);    % 2D filter with a definite window size
    disp('           Filtering the residual phases with a low-pass filter called disk');
    FltRes=imfilter(Res, H);                  % Two-dimensional digital filtering
    FltRes(JJ)=NaN+NaN*j;                       % replacing the JJ-related elements with NaN+Nan*j
    % save the phase data (after low-pass filtering)
    Dirt1='E:\PhoenixSAR\Dif_Int_MLI_LPF\';
    iofile=[Dirt1, num2str(master), '_', num2str(slave), '.diff.int2.lpf'];
    fwritebk(FltRes, iofile, 'cpxfloat32');   % complex floating point, 32 bits, store pixel interleaved
    disp(['           Writing the filtered residual phases into ', iofile]);
    copyfile(iofile, 'FltRes.lpf');
       
    % Do phase unwrapping by Flynn's method (minimum discontinuity): mwd  
    % Note: unwrapping executables are in "D:\SBAS\PhaseUnw\"
    cd(Dirt1);      % change file directory
    outfile=[num2str(master), '_', num2str(slave), '.diff.int2.unw'];
    disp(['           Unwrapping the residual phases and writing into ', outfile]);
    %! D:\SBAS\PhaseUnw\mwd -input FltRes.lpf -format complex8 -output unw.dat -xsize 1350 -ysize  750 -mode min_var -bmask mask.dat -tsize 1 -thresh yes -debug yes -fat 1
    !D:\SBAS\PhaseUnw\gold -input FltRes.lpf -format complex8 -output unw.dat -xsize 1350 -ysize 750 -mask mask.dat
                                 % note: the unwrapped phases are written into the outfile as floating values
   copyfile('unw.dat', outfile);
   delete('FltRes.lpf');
   delete('unw.dat');
   %delete('unw.dat.qual');
end
fclose(fid);

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');

% Use Empirical Model Decomposition (EMD) to separate atmospheric effects
% from non-linear deformation rate

