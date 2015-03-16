% View SAR amplitude image
% impixel; improfile

% readung in data
amp=freadbk('F:\Phoniex\PS_Points\27by15KM\updated\27by15km_Mean_Amp.dat', 750, 'float32');

% scaling and converting data
amp=amp.^0.7;
amp=mat2gray(amp);
amp=imadjust(amp);

% display data
%figure; imagesc(amp); axis image; colormap(gray);
imview(amp);
