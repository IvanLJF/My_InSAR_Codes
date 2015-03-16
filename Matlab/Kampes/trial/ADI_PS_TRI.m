% extracting PS points from the amplitude dispersion index (ADI) matrix,
% and generating TIN 

% read ADI data
ADIs=freadbk('F:\Phoniex\PS_Points\SARimgs.ADI', 3200, 'float32');        

% read mean amplitude BMP image 
m_amp=imread('F:\Phoniex\PS_Points\Ph_Mean_Amp.bmp');   
                                                                                                       
ADIs=fliplr(ADIs);      % its rows should be left-right flipped 
                                 % to keep the same coordinate frame as m_amp

% crop from ADIs
ADI_patch=ADIs(800:1055, 250:505);
[R, C]=find(ADI_patch<=0.25);            % locate PS points with threshold of 0.25
tri=delaunay(C,R);

figure; 
imshow(m_amp(800:1055, 250:505));
hold on;
triplot(tri, C, R);