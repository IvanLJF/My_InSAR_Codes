function [dv_ddh]=dvddharcs_sec(num_intf, num_PS, num_Arcs)
% 通过获取模型一致性的最大值预测两个相邻PS点形变率的增长以及DEM误差。
%  function dvddharcs_sec(num_intf, num_PS, num_Arcs);
%
% Estimating increment of deformation rate and DEM error between 
% two neighbouring permanent scatterers (PS) by means of maximizing 
% model coherence value (see Ferretti et al., 2000, IEEE) 
% 
% Input:
%        num_intf-------total number of all interferograms
%        num_PS---------total number of all PS points
%        num_Arcs-------total number of all arcs in the triangular irregular network (TIN)
%                          Note: in addition, four input files are needed. They are 
%                                   (1) input file (like "Pair_Dates_SB_120m.dat") on information of interferometric combination, 
%                                         temporal and spatial baselines
%                                   (2) input file (like "PSCoor.dat") on information of coordinates of all PS points
%                                   (3) input file (like "PSArcs.dat") on information of all arcs in TIN
%                                   (4) input file (like "Mat_Phase20169.dat") on information of  time series phase data at all PS points
% Output:
%        dv_ddh---------a num_Arsc-by-3 matrix, the first column is for the increments of range-displacement velocities 
%                       between neighbouring PS points, while the second column is for increments of height corrections 
%                       between neighbouring PS points. The third column corresponds to the model coherence of each arc. 
%
%  e.g.,  dvddh=dvddharcs_sec(117, 151, 438);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 12, 2006: Created, Guoxiang LIU

t0=cputime;
% open input file about information of interferometric combination, temporal and spatial baselines
% As an example, the content of such file is shown as follows
%   MASTER     SLAVE    TIME BASELINE (days)    SPACE BASELINE (m)
% 19920710    19930521              315                                   23.60
% 19920710    19931008              455                                  -77.70
% 19920710    19950827             1143                                  -85.30
%      ...                  ...                      ...                                       ... 
% 19991220    20001030              315                                   74.60
%
% This file is required to compute the thi, R, Bperp and dT
infile='/d1/users/liu/matlabprg/files/Pair_Dates_SB_120m.dat';   % given the file name regarding temporal and spatial 
                                                                                                          % baslines of all 117 interferograms
%infile='F:\Phoniex\SB\Pair_Dates_SB_120m.dat';                                                                                                          
disp(['% Reading whole file: ', infile]);
msb=load(infile);
master=msb(:,1);             % get dates taking all master images 
slave=msb(:,2);                % get dates taking all slave images
dT=msb(:,3);                     % get temporal baseline for each interferogram 
clear msb;

% open three files: 1. PSCoor.dat; 2. PSArcs.dat;  3. Phase.dat
% first, open and read in PSCoor.dat
infile='/d1/users/liu/matlabprg/output/PSCoor.dat';   
%infile='F:\Phoniex\PS_Points\test\PSCoor.dat';
PSCoor=freadbk(infile, num_PS, 'uint16');          % read in coordinates of all PS points
PSCoor=uint16(PSCoor);
% second, read in PSArcs.dat
infile='/d1/users/liu/matlabprg/output/PSArcs.dat';      % total number of arcs == 4423
%infile='F:\Phoniex\PS_Points\test\PSArcs.dat';
PSNO=freadbk(infile, num_Arcs, 'uint32');          % read in all arcs
PSNO=uint32(PSNO);
% finally,read in Phase20169.dat -- time series phase data at all PS points 
infile='/d1/users/liu/matlabprg/output/Phase20169.dat';
%infile='F:\Phoniex\PS_Points\test\Phase20169.dat';
DIntf=freadbk(infile, num_intf, 'float32');               % read in phase data

% Compute interferometric parameters, thi, R, Bperp
thi=zeros(num_PS, num_intf);                      % radar look angle
R=zeros(num_PS, num_intf);                       % slant range
Bperp=zeros(num_PS, num_intf);                % perpendicular baseline
for i=1:num_intf    % loop on all interferograms
    [thi(:,i), R(:,i), Bperp(:,i)]=basecomp(double(PSCoor(:,2)), double(PSCoor(:,1)), master(i), slave(i));  % call function to compute parameters
end

% estimating dv and ddh along each arc (i.e., triangular side)
kk=28001;      % share work with SAR server
dv_ddh=zeros(num_Arcs-kk+1, 3);
t0=cputime;

for i=kk:num_Arcs    % loop on all arcs
     II=PSNO(i,1);       % get the number of the 1st PS point of the current ARC
    JJ=PSNO(i,2);     % get the number of the 2nd PS point of the current ARC
    thita=(thi(II,:)'+thi(JJ,:)')/2;     % averaging on thi
    Rg=(R(II,:)'+R(JJ,:)')/2;         % avearging on R
    Bp=(Bperp(II,:)'+ Bperp(JJ,:)')/2;  % avearging on Bperp
    % Estimating increment of deformation rate and DEM error between
    % two neighbouring permanent scatterers (PS) by means of maximizing
    % model coherence value
    warning off
    if isint(i/100)
        disp(' ');
        disp(['The ', num2str(i), '-th arc being processed ...']);
    end
    [dv_ddh(i-kk+1,1), dv_ddh(i-kk+1,2),  dv_ddh(i-kk+1,3)]=incsolut(num_intf, [DIntf(:,II), DIntf(:,JJ)], thita, Rg, Bp, dT);
    warning off
    if isint(i/100)
        disp(['Solved dV=', num2str(dv_ddh(i-kk+1,1)), '    Solved ddH=', num2str(dv_ddh(i-kk+1,2)), '    Model coherence=', num2str( dv_ddh(i-kk+1,3))]);
    end
end
disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);
disp('Success in solution!');

% writing dv_ddh into a binary file
[pathstr, name] = fileparts(infile);
str='dvddh_win.dat';
fwritebk(dv_ddh, [pathstr, '\', str], 'float32');        % saving velocity increment and height error increment of each arc

disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);
disp('Success in solution!');
disp(' ');        
   
warning on

