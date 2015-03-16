function [dv_ddh]=dvddharcs_slow(num_intf, num_PS, num_Arcs);
%  function dvddharcs_slow(num_intf, num_PS, num_Arcs);
%
% Estimating increment of deformation rate and DEM error between 
% two neighbouring permanent scatterers (PS) by means of maximizing 
% model coherence value (see Ferretti et al., 2000, IEEE) 
% 
% Input:
%        num_intf-------total number of all interferograms
%        num_PS-------total number of all PS points
%        num_Arcs-----total number of all arcs in the triangular irregular network (TIN)
%                          Note: in addition, four input files are needed. They are 
%                                   (1) input file (like "Pair_Dates_SB_120m.dat") on information of interferometric combination, 
%                                         temporal and spatial baselines
%                                   (2) input file (like "PSArcs.dat") on information of all arcs in TIN
%                                   (3) input file (like "PSCoor.dat") on information of coordinates of all PS points
%                                   (4) input file (like "Mat_Phase1496.dat") on information of  time series phase data at all PS points
% Output:
%        dv_ddh----------------a num_Arsc-by-3 matrix, the first column is for the increments of range-displacement velocities 
%                                        between neighbouring PS points, while the second column is for increments of height corrections 
%                                        between neighbouring PS points. The third column corresponds to the model coherence of each arc. 
%
%  e.g.,  dvddh=dvddharcs(117, 151, 438);
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
% 19920710    19950827            1143                                  -85.30
%      ...                  ...                      ...                                       ... 
% 19991220    20001030              315                                   74.60
%
% This file is required to compute the thi, R, Bperp and dT
infile='F:\Phoniex\SB\Pair_Dates_SB_120m.dat';              % given the file name regarding temporal and spatial 
                                                                                             % baslines of all 117 interferograms
msb=load(infile);
master=msb(:,1);             % get dates taking all master images 
slave=msb(:,2);                % get dates taking all slave images
dT=msb(:,3);                     % get temporal baseline for each interferogram 
clear msb;

% open three files: 1. PSArcs.dat; 2. PSCoor.dat; 3. phase.dat
% first, open PSArcs.dat
infile='F:\Phoniex\PS_Points\test\PSArcs.dat';      % total number of arcs == 4423
fid1=fopen(infile, 'rb');
% second, open and read in PSCoor.dat
infile='F:\Phoniex\PS_Points\test\PSCoor.dat';   
PSCoor=freadbk(infile, num_PS, 'uint16');          % read in coordinates of all PS points
PSCoor=uint16(PSCoor);
% finally, for Phase347.dat -- time series phase data at all PS points 
infile='F:\Phoniex\PS_Points\test\Phase20169.dat';
warning off

% estimating dv and ddh along each arc (i.e., triangular side)
dv_ddh=zeros(num_Arcs, 3, 'single');
t0=cputime;
for i=1:num_Arcs    % loop on all arcs
      PSXY=fread(fid1, 2, 'uint32');     % read in numbers of two neighbouring PS points
      col1=PSCoor(PSXY(1),1);
      row1=PSCoor(PSXY(1),2);        % get pixel coordinate of PS1 of the i-th arc
      col2=PSCoor(PSXY(2),1);
      row2=PSCoor(PSXY(2),2);        % get pixel coordinate of PS2 of the i-th arc
      DIntf1=freadbk(infile, num_intf, 'float32', 1, num_intf, PSXY(1), PSXY(1));     % read in time series phase values at PS1
      DIntf2=freadbk(infile, num_intf, 'float32', 1, num_intf, PSXY(2), PSXY(2));     % read in time series phase values at PS2
      DIntf=[DIntf1, DIntf2];                  % form a num_intf-by-2 matrix of phase values at both PS1 and PS2        
      
      % calculating thi, R, Bperp (i.e., perpendicular baseline parameter)
      % and dT (temporal baseline)
      thi1=zeros(num_intf, 1);    % radar look angles for PS1
      thi2=zeros(num_intf, 1);    % radar look angles for PS2
      R1=zeros(num_intf, 1);       % slant ranges for PS1
      R2=zeros(num_intf, 1);       % slant ranges for PS2
      Bperp1=zeros(num_intf, 1);     % perpendicular baselines for PS1
      Bperp2=zeros(num_intf, 1);     % perpendicular baselines for PS2
      for j=1:num_intf
            [thi1(j), R1(j), Bperp1(j)]=basecomp(double(row1), double(col1), master(j), slave(j));    % call function to compute parameters
            [thi2(j), R2(j), Bperp2(j)]=basecomp(double(row2), double(col2), master(j), slave(j));    % call function to compute parameters
      end
      thi=(thi1+thi2)/2;     % averaging on thi
      R=(R1+R2)/2;      % avearging on R
      Bperp=(Bperp1+ Bperp2)/2;  % avearging on Bperp

      % Estimating increment of deformation rate and DEM error between
      % two neighbouring permanent scatterers (PS) by means of maximizing
      % model coherence value
      disp(' ');
      disp(['The ', num2str(i), '-th arc being processed ...']);
      [dv_ddh(i,1), dv_ddh(i,2),  dv_ddh(i,3)]=incsolut(num_intf, DIntf, thi, R, Bperp, dT);
      disp(['Solved dV=', num2str(dv_ddh(i,1)), '    Solved dH=', num2str(dv_ddh(i,2)), '    Model coherence=', num2str( dv_ddh(i,3))]);
end
disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);

% writing dv_ddh into a binary file
[pathstr, name] = fileparts(infile);
str='dvddh.dat';
fwritebk(dv_ddh, [pathstr, '\', str], 'float32');        % saving velocity increment and height error increment of each arc
fclose(fid1);

disp(' ');
disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);
disp('Success in solution!');
disp(' ');        

% plotting arcs
% figure; hold on;
% X=PSCoor(:, 1)';
% Y=PSCoor(:, 2)';
% ARC_PS=freadbk('F:\Phoniex\PS_Points\test\PSArcs.dat', num_Arcs, 'uint32');
% for i=1:num_Arcs
%     if dv_ddh(i,3)<0.5
%         plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'r-');
%     else
%         plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'b-');
%     end
% end
% if num_PS<=35
%     for i=1:num_PS
%         text(X(i, 1), Y(i, 2), num2str(i));
%     end
% end
% %set(gca, 'XLim', [0 65]);
% %set(gca, 'YLim', [0 65]);
% title('Plotted with Non-Repeated Arc Information');
% box on;
% hold off;
%     
warning on

