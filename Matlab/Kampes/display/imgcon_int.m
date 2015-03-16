% change and convert BMP images

% change directory
cd E:\PhoenixSAR\Dif_Int_MLI_sm\extracted

% read in velocity image to create a mask which corresponds to the pixels
% to be exchanged
V_mask=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'n');
II=isnan(V_mask);    % get NaN pixels
[R, C]=find(II==1);
num_NaN=length(R);
clear V_mask II

% read in the mean amplitude image
[amp, camp]=imread('F:\Phoniex\PS_Points\27by15KM\updated\velocity_ints\mean_amp.bmp', 'bmp');
RGB_amp=ind2rgb(amp, camp);

% Process on No.1 image
[int, c]=imread('19951105_19961021.smph.1yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19951105_19961021.smph.1yr.bmp');

% Process on No.2 image
[int, c]=imread('19961230_19981130.smph.2yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19961230_19981130.smph.2yr.bmp');

% Process on No.3 image
[int, c]=imread('19960916_19990802.smph.3yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19960916_19990802.smph.3yr.bmp');

% Process on No.4 image
[int, c]=imread('19960219_20000508.smph.4yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19960219_20000508.smph.4yr.bmp');

% Process on No.5 image
[int, c]=imread('19920710_19970519.smph.5yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19920710_19970519.smph.5yr.bmp');

% Process on No.6 image
[int, c]=imread('19930903_19991220.smph.6yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19930903_19991220.smph.6yr.bmp');

% Process on No.7 image
[int, c]=imread('19930903_20001030.smph.7yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19930903_20001030.smph.7yr.bmp');

% Process on No.8 image
[int, c]=imread('19920918_20000925.smph.8yr.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, '19920918_20000925.smph.8yr.bmp');




