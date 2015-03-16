function [V, H, PHI, HHI, DifInt, IM, IS, TM, TS, dT, B] = Simulate(N)
% 这个函数用来计算包含有形变信息和高程误差信息的差分干涉图
%  [V, H, PHI, HHI, DifInt, IM, IS, TM, TS, dT, B] = Simulate(N);
% 
% This function is used to simulate differential interferograms including
% deformation and height-error information
% 
% V=Deformation rates for N by N pixels   N*N像素块的形变速率
% H=Height erros for N by N pixels   高程误差
%
% PHI=Deformation phases in absolute sense for N by N pixels
% HHI=Height-error phases in absolute sense for N by N pixels
% DifInt=Differential phases for deformations & heght errors (in wrapped form)
% 
% IM, IS=Indexes for master and slave images (all images are numbered by 1 to N according to time order)
% TM, TS=Imaging days for master and slave images (accounting from the first imaging date) 
% dT=Temporal baseline for all interferograms
% B=Spatial baseline for all interferograms
%
%  e.g.,  [V, PHI, HHI, DifInt, IM, IS, TM, TS, dT, B] = Simulate(N);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Nov 21 2005 : Created, Guoxiang LIU

thita=23;            % ERS radar loook angle in degree
Lamda=56e-3;  % ERS C-band radar wavelength=56 mm;
R0=850000;      % mid-range in meters

% Simulating a velocity field
%N=256;
beta=6;
%clear V;
V=300*fracsurf(N, beta);   % Generating a velocity surface with a fractal tool
                                                % Unit of velocity is cm/year
V=10*V/365;                       % Unit of velocity is mm/day 

% Simulating the height corrections
beta=10;
H=1000*fracsurf(N, beta);       % Unit in meters
disp('Minmum height erro:');
min(min(H))
disp('Maximum height erro:');
max(max(H))

% Imaging dates assumed
% 5/19/92  7/28/92  9/3/92    12/25/92
% 3/8/93    6/18/93  9/22/93  11/28/93
% 2/26/94  5/26/94  8/18/94  12/6/94
% 3/16/95  6/26/95  9/9/95    12/8/95
% 2/25/96  5/25/96  8/26/96  11/27/96
% 3/8/97    5/5/97    8/16/97  11/6/97

% Converting 24 imaging dates into 24 sequential days (the first imaging date as
% the 0th day)
T=[datenum('5/19/92')  datenum('7/28/92')  datenum('9/3/92')    datenum('12/25/92')  datenum('3/8/93')    datenum('6/18/93')  datenum('9/22/93')   datenum('11/28/93')...
      datenum('2/26/94')  datenum('5/26/94')  datenum('8/18/94')  datenum('12/6/94')    datenum('3/16/95')  datenum('6/26/95')  datenum('9/9/95')    datenum('12/8/95')...
      datenum('2/25/96')  datenum('5/25/96')  datenum('8/26/96')  datenum('11/27/96')  datenum('3/8/97')    datenum('5/5/97')    datenum('8/16/97')  datenum('11/6/97')];
      %datenum('3/17/98')  datenum('6/20/98')  datenum('8/18/98')
      %datenum('12/10/98')  datenum('2/22/99')  datenum('5/25/99')  datenum('9/8/99')    datenum('11/20/99')];
T=T-datenum('5/19/92');    

NN=24;   % Totoal number of SAR images 

% Numbering for master and slave images
IM=[2 3 4 6 7 8 8   11 12 13 13 14 15 15 15 16 16 16 16    20 20 21 22 22 23 23 23 24 24 24];   % Numbers for master images
IS=[1 2 1 4 5 5 7     9  10  9  11 13 10 12 14 10 11 13 15    17 18 20 17 21 18 20 22 19 20 23];   % Numbers for slave images
M=length(IM);      % Interferometric combinations: total interferograms are 26

 % Master image --- Imaging day=TM
% Slave image   --- Imaging day=TS
% Imaging dates for three subsets of interferometric combinations: 
% T(1)--T(8): 7 interferograms
% T(9)--T(16): 10 interferograms
% T(17)--T(24): 9 interferograms
  %TM=[T(2) T(3) T(4) T(6) T(7)  T(8) T(8)    T(11) T(12) T(13) T(13) T(15) T(15) T(16)  T(16)  T(16) T(16)    T(20) T(20) T(22) T(23) T(23) T(23) T(24) T(24) T(24)];
   %TS=[T(1) T(2) T(1) T(4) T(5)  T(5) T(7)    T(9)   T(10)  T(9)  T(11) T(10) T(12) T(10)  T(11)  T(13) T(15)    T(17) T(18) T(17) T(18) T(20) T(22) T(19) T(20) T(23)];
 TM=zeros(1, M);    TS=zeros(1, M);
 for i=1:M
     TM(i)=T(IM(i)); 
     TS(i)=T(IS(i));
 end
 % Time interval=IM-IS, i.e., temporal baseline
 dT=TM-TS;  
 
 % Spatial (perpendicular) baseline in meters
 % We can't given B in arbitrary way, because the perpendicular-
 % baseline lengths are correlated among the interferograms
 % First, we fixed a orbital point for each subset 
YZ0=zeros(2,3);  % One column for the coordinates of a fixed orbital point (x assumed constant, i.e., x=-3615000 m)
YZ0(:,1)=[5500000, 2850000]';   % for subset 1, T(1)--T(8)
YZ0(:,2)=[5500000+1000, 2850000]';  % for subset 2, T(9)--T(16)
YZ0(:,3)=[5500000+2000, 2850000]';  % for subset 3, T(17)--T(24)
YZ=zeros(2, NN);  % Storing orbital positions for 24 SAR images
B=zeros(1,M); 
% Orbit positions for subset 1, T(1)--T(8)
dy=260*(rand(1, 8)-0.5);    % Generating random increments for y-coordinate with a uniform-distribution generator
dz=80*(rand(1, 8)-0.5);    % Generating random increments for z-coordinate with a uniform-distribution generator 
for i=1:8
  YZ(:, i)=YZ0(:,1)+[dy(1, i), dz(1, i)]';
end
% Orbit positions for subset 2, T(9)--T(16)
dy=290*(rand(1, 8)-0.5);    % Generating random increments for y-coordinate with a uniform-distribution generator
dz=70*(rand(1, 8)-0.5);    % Generating random increments for z-coordinate with a uniform-distribution generator 
for i=1:8
  YZ(:, i+8)=YZ0(:,2)+[dy(1, i), dz(1, i)]';
end
% Orbit positions for subset 3, T(17)--T(24)
dy=320*(rand(1, 8)-0.5);    % Generating random increments for y-coordinate with a uniform-distribution generator
dz=60*(rand(1, 8)-0.5);    % Generating random increments for z-coordinate with a uniform-distribution generator 
for i=1:8
  YZ(:, i+16)=YZ0(:, 3)+[dy(1, i), dz(1, i)]';
end
% Perpendicular baseline computation
for i=1:M
    ym=YZ(1, IM(i));    % Getting y-coordinate of orbit for master image
    zm=YZ(2, IM(i));    % Getting z-coordinate of orbit for master image       
    ys=YZ(1, IS(i));      % Getting y-coordinate of orbit for slave image
    zs=YZ(2, IS(i));      % Getting z-coordinate of orbit for slave image
    k=tan((thita+90)*pi/180);            %  Equation for the radar line-of-sight with look angle of 23 degrees:
                                  %  z=k*y+zm-ym*k
    temp=k*ys-zs+zm-ym*k;  
    B(i)=abs(temp)/sqrt(k^2+1);   % Baseline length in meters
    if temp>0                % Is the slave orbit position to the left side of the radar LOS?
        B(i)=-B(i);          % If temp<0, B is positive, and if temp>0, B is negtive.  
    end
end

% Final computation for displacement and height phases
 PHI=zeros(N, N, M);    % Displacement phases for each interferogram
 HHI=zeros(N, N, M);   % Height-error phases for each interferogram 
 DifInt=zeros(N, N, M); % Differential interferograms containing displacement and height-error information
 for i=1:M
     PHI(:,:,i)=4*pi*V*dT(i)/(Lamda*1000);       % Getting deformation interferogram with use of deformation rates
     HHI(:,:,i)=4*pi*H*B(i)/(Lamda*R0*sin(thita*pi/180));  % Getting height-error phases
     DifInt(:,:,i)=wrap(PHI(:,:,i)+HHI(:,:,i));  % +normrnd(0, 5*pi/180, 256, 256);  % Mixture of deformation and height-error phases
     figure; subplot(1,3,1); imagesc(DifInt(:,:,i)); colormap(ph); axis image; colorbar('horiz');
     subplot(1,3,2); imagesc(wrap(PHI(:,:,i))); colormap(ph); axis image; colorbar('horiz');
     subplot(1,3,3); imagesc(wrap(HHI(:,:,i))); colormap(ph); axis image; colorbar('horiz');
        %figure; subplot(1,2,1); imagesc(wrap(HHI(:,:,i))); colormap(ph); axis image; colorbar;
        %subplot(1,2,2); imagesc(HHI(:,:,i)); colormap(jet); axis image; colorbar;
 end
 
 figure; imagesc(H); colormap(jet); axis image; colorbar;
 figure; imagesc(V); colormap(ph); axis image; colorbar;
 
 clear Lamda temp i ym zm ys zs k dy dz beta;
 