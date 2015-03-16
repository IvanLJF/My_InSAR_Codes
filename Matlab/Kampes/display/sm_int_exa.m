% generate simulated interferograms with the computed linear velocity field

% read in linear velocity image 
V=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'y');   % in mm
V=fliplr(V);    % change back to the original radar coordinate system
%V=-V;  % define plus sign as uplift, and minus sign as subsidence
II=isnan(V);    % get NaN pixels
JJ=find(II==1);
clear V II

cd E:\PhoenixSAR\Dif_Int_MLI_sm\extracted

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19951105_19961021.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19951105_19961021.smph.1yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19961230_19981130.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19961230_19981130.smph.2yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19960916_19990802.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19960916_19990802.smph.3yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19960219_20000508.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19960219_20000508.smph.4yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19920710_19970519.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19920710_19970519.smph.5yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19930903_19991220.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19930903_19991220.smph.6yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19930903_20001030.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19930903_20001030.smph.7yr', 'float32');

int=freadbk('E:\PhoenixSAR\Dif_Int_MLI_sm\19920918_20000925.diff.int2.sm.ph', 3200, 'float32', 751, 1500, 2051, 3400);
int(JJ)=NaN;
fwritebk(int, '19920918_20000925.smph.8yr', 'float32');

