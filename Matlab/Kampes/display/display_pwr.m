function display_pwr(str, numlines, bkformat,  r0, rN, c0, cN, exp);
% input:
%           str=filename for a SAR power image
%           numlines=total number of image lines
%           bkformat=data format like 'float32'
%            r0, rN, c0, cN=to crop this file while reading, between rows r0:rN, columns c0:cN
%           exp=display exponent (.35, 0.5=for amplitude)
% usage:
%           display_pwr('F:\Phoniex\results\f19951105_f19951106.pwr1', 2665, 'float32', 1, 2665, 1, 2456, 0.35)

% reading a matrix for SAR power image
data=freadbk(str, numlines, bkformat, r0, rN, c0, cN);
h=ones(5,5)/25;
data=imfilter(data, h);
data=fliplr(data.^exp);
data=mat2gray(data);
data=histeq(data);

figure; 
imshow(data); colormap(gray); axis image; colorbar;
