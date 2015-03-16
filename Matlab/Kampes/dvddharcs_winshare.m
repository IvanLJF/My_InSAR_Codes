function [dv_ddh]=dvddharcs_winshare(num_intf, num_PS, num_Arcs, start_N, end_N)
% 通过获取模型一致性的最大值预测两个相邻PS点形变率的增长以及DEM误差。
%  function [dv_ddh]=dvddharcs_winshare(num_intf, num_PS, num_Arcs, start_N, end_N);
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
%        start_N-----------starting No. of arc   (used for sharing work in Unix)
%        end_N------------ending No. of arc    (used for sharing work in Unix)
%
% Output:
%        dv_ddh---------a num_Arsc-by-3 matrix, the first column is for the increments of range-displacement velocities 
%                               between neighbouring PS points, while the second column is for increments of height corrections 
%                               between neighbouring PS points. The third column corresponds to the model coherence of each arc. 
%
%  e.g.,  dvddh=dvddharcs_winshare(86, 14618, 1463306, 1, 10000);
%           dvddh=dvddharcs_winshare(86, 14618, 43561, 1, 18000);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   June. 30, 2006: Created, Guoxiang LIU

t1=cputime;
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
infile='F:\Phoniex\SB\Pair_Dates_SB_120m_4yrs.dat';                                                                                                          
disp('% Reading whole file: F:\Phoniex\SB\Pair_Dates_SB_120m_4yrs.dat');
msb=load(infile);
master=msb(:,1);             % get dates taking all master images 
slave=msb(:,2);                % get dates taking all slave images
dT=msb(:,3);                   % get temporal baseline for each interferogram 
clear msb;

% open three files: 1. PSCoor.dat; 2. PSArcs.dat;  3. Phase20169.dat
% first, open and read in PSCoorN.dat
infile='F:\Phoniex\PS_Points\test\PSCoorN.dat';
PSCoor=freadbk(infile, num_PS, 'uint16');          % read in coordinates of all PS points
PSCoor=uint16(PSCoor);
% second, read in PSArcsN.dat
infile='F:\Phoniex\PS_Points\test\PSArcsN.dat';      % total number of arcs == 4423
PSNO=freadbk(infile, num_Arcs, 'uint16');          % read in all arcs
% infile='F:\Phoniex\PS_Points\27by15KM\updated\PSArcs.dat';
% PSNO=freadbk(infile, num_Arcs, 'uint32');          % read in all arcs
PSNO=uint32(PSNO);
% finally,read in time series phase data at all PS points 
infile='F:\Phoniex\PS_Points\27by15KM\updated\Phase86.dat';   % for 86 interferograms
DIntf=freadbk(infile, num_intf, 'float32');               % read in phase data

% Compute interferometric parameters, thi, R, Bperp
thi=zeros(num_PS, num_intf);                      % radar look angle
R=zeros(num_PS, num_intf);                       % slant range
Bperp=zeros(num_PS, num_intf);                % perpendicular baseline
for i=1:num_intf    % loop on all interferograms
    [thi(:,i), R(:,i), Bperp(:,i)]=basecomp(double(PSCoor(:,2)), double(PSCoor(:,1)), master(i), slave(i));  % call function to compute parameters
end

% estimating dv and ddh along each arc (i.e., triangular side)
kk=start_N;      % share work with SAR server
ll=end_N;
dv_ddh=zeros(ll-kk+1, 3);

% The following part was moved here from "incsolut.m"  (June 30, 2006)
% Generating solution-space grids 
dv_low=-0.03;     % -0.1;          % mm/day; for velocity increment
dv_up=0.03;         % 0.1;
ddh_low=-15;        % in meters, for height-error increment
ddh_up=15;
dv_size=41;   %50;         % grid size for searching solution
ddh_size=21; %50;
dv_inc=(dv_up-dv_low)/(dv_size-1);              % get tiny velocity increment corresponding to each grid size
ddh_inc=(ddh_up-ddh_low)/(ddh_size-1);     % get tiny height-error increment corresponding to each grid size
dv_try=[dv_low:dv_inc:dv_up];                       % all possible veclocity increments at all grid points
ddh_try=[ddh_low:ddh_inc:ddh_up];              % all possible height-error increments at all grid points
[DV, DDH]=meshgrid(dv_try, ddh_try);            
Xdv=reshape(DV, prod(size(DV)), 1);
Xddh=reshape(DDH, prod(size(DDH)), 1);
clear dv_low dv_up ddh_low ddh_up dv_size ddh_size dv_try ddh_try DV DDH

t0=cputime;
for i=kk:ll    % loop on arcs
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
    [dv_ddh(i-kk+1,1), dv_ddh(i-kk+1,2),  dv_ddh(i-kk+1,3)]=incsolut(num_intf, [DIntf(:,II), DIntf(:,JJ)], thita, Rg, Bp, dT, dv_inc, ddh_inc, Xdv, Xddh);
    warning off
    if isint(i/100)
        disp(['Solved dV=', num2str(dv_ddh(i-kk+1,1)), '    Solved ddH=', num2str(dv_ddh(i-kk+1,2)), '    Model coherence=', num2str( dv_ddh(i-kk+1,3))]);
        %disp([num2str(dv_ddh(i-kk+1,1)), '  ', num2str(dv_ddh(i-kk+1,2)), '  ', num2str( dv_ddh(i-kk+1,3))]);
        disp(['% Total CPU time used for the 100-arc processing:  ', num2str(cputime-t0), ' seconds.']);
        t0=cputime;
    end
end

% writing dv_ddh into a binary file
[pathstr, name] = fileparts(infile);
str=['dvddh86_', num2str(kk), '_', num2str(ll), '.dat'];
fwritebk(dv_ddh, [pathstr, '/', str], 'float32');        % saving velocity increment and height error increment of each arc

disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t1), ' seconds.']);
disp('Success in solution!');
disp(' ');        
   
warning on

