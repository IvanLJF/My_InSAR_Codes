% change and convert BMP images

% change directory
% cd F:\Phoniex\PS_Points\27by15KM\updated\velocity_ints
cd F:\Phoniex\PS_Points\27by15KM\updated\ints86\velintf

% read in velocity image to create a mask which corresponds to the pixels
% to be exchanged
V_mask=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'n');
II=isnan(V_mask);    % get NaN pixels
[R, C]=find(II==1);
num_NaN=length(R);
clear V_mask II

% read in the mean amplitude image
[amp, camp]=imread('mean_amp.bmp', 'bmp');
RGB_amp=ind2rgb(amp, camp);

% Process on amp_velocity image
[int, c]=imread('amp_linearvelocity.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity.bmp');

% Process on No.1 image
[int, c]=imread('amp_linearvelocity_Int_1_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_1_year.bmp');

% Process on No.2 image
[int, c]=imread('amp_linearvelocity_Int_2_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_2_year.bmp');

% Process on No.3 image
[int, c]=imread('amp_linearvelocity_Int_3_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_3_year.bmp');

% Process on No.4 image
[int, c]=imread('amp_linearvelocity_Int_4_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_4_year.bmp');

% Process on No.5 image
[int, c]=imread('amp_linearvelocity_Int_5_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_5_year.bmp');

% Process on No.6 image
[int, c]=imread('amp_linearvelocity_Int_6_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_6_year.bmp');

% Process on No.7 image
[int, c]=imread('amp_linearvelocity_Int_7_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_7_year.bmp');

% Process on No.8 image
[int, c]=imread('amp_linearvelocity_Int_8_year.bmp');
RGB_int=ind2rgb(int, c);
for i=1:num_NaN
     RGB_int(R(i),C(i),:)=RGB_amp(R(i),C(i),:);
end
[X,map] = rgb2ind(RGB_int,256);
imwrite(X, map, 'amp_linearvelocity_Int_8_year.bmp');




