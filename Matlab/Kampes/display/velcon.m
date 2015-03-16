% generate simulated interferograms with the computed linear velocity field

% read in linear velocity image 
% V=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'y');   % in mm
V=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\ints86\XYV86.grd', 'y');   % in mm
V=fliplr(V);    % change back to the original radar coordinate system
%V=-V;  % define plus sign as uplift, and minus sign as subsidence
% II=isnan(V);    % get NaN pixels
% [R, C]=find(II==1);
% num_NaN=length(R);
% clear V_mask II

% cd F:\Phoniex\PS_Points\27by15KM\updated\velocity_ints
cd F:\Phoniex\PS_Points\27by15KM\updated\ints86\velintf

% Calculate radar incidence angle
% study area: [r0=751, rN=1500; c0=2051, cN=3400]
% center pixel coordinate=[1125, 2726]
% [thi, R, Bperp] = basecomp(1125, 2726, 19920710, 19930521);
                                    % I have checked with different interferometric pairs. I found that
                                    % thi has very little variation for
                                    % different paris. cos(thi)=0.9342
Lamda=5.6;    % in cm                                    
% Compute 1-year subsidence interferogram from velocity model
int=V*1*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_1yr.dat', 'float32');

% Compute 2-year subsidence interferogram from velocity model
int=V*2*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_2yr.dat', 'float32');

% Compute 3-year subsidence interferogram from velocity model
int=V*3*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_3yr.dat', 'float32');

% Compute 4-year subsidence interferogram from velocity model
int=V*4*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_4yr.dat', 'float32');

% Compute 1-year subsidence interferogram from velocity model
int=V*5*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_5yr.dat', 'float32');

% Compute 2-year subsidence interferogram from velocity model
int=V*6*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_6yr.dat', 'float32');

% Compute 3-year subsidence interferogram from velocity model
int=V*7*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_7yr.dat', 'float32');

% Compute 4-year subsidence interferogram from velocity model
int=V*8*0.1*4*pi/Lamda;    % velocity by time interval, and then convert to radians
fwritebk(int, 'IntPh_8yr.dat', 'float32');

