clear;
clc;
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay_SeaWiFS\S2003250.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003252.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003257.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003260.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003267.L3m_DAY_CHL_chlor_a_9km';
% 
% range=[598,812,3566,3696];%[598,812,3566,3696];% Pixel range of China Sea.
% data= load_hdf_chinasea(infile,range(1),range(2),range(3),range(4));
% 
% file_info= hdfinfo(infile);
% sds_info=file_info.SDS;
% sds_info= sds_info(1,1);
% data= hdfread(sds_info);
% data= double(data);
% data(data==-32767)=nan;
% data= data(range(1):range(2),range(3):range(4));% Get data of China sea.
% data= single(data);
% 
% [row, col]= find(data >28);
% result=[0,0,0];
% for i=1: size(row,1);
%     result=[[result]; [row(i),col(i),data(row(i), col(i))]];
% %     disp(row(i),col(i),data(row(i), col(i)));
%     
% end
% result= result(2:end, : );
% disp(result);


input_data_path='D:\myfiles\Software\Yatou_Paper\Data\Chl';

% Test for a single chl. file.
chl_files='S20032442003273.L3m_MO_CHL_chlor_a_9km';
chlfile=strcat(input_data_path,'\',chl_files);
range=[598,812,3566,3696];
chl= load_hdf_chinasea(chlfile,range(1),range(2),range(3),range(4));%Load data of China Sea.
chl= 4.04672*log((chl+10.02913)/9.62471);
% --------------------------------------------------------------------
% This is the new version
    X=[-180:0.0833333:180];
    Y=fliplr([-90:0.0833333:90]);
    lats_range= Y(range(1):range(2));% Get lats range.
    lons_range= X(range(3):range(4));% Get lons range.
    lats= [31.63, 31.00, 28.43, 29.25, 31.43];% Lats of  given stations.
    lons=[122.800, 122.633, 127.300, 125.500, 126.133]; % Lons of  given stations.
    lats_pix= round((lats_range(1)-lats)/0.0833333)+1;% Y pixel coors of given stations.
    lons_pix= round((lons-lons_range(1))/0.0833333)+1;% X pixel coors of given stations.
    %chldata= chl(lats_pix, lons_pix);
    %matlab vectoral index is bullshit.
    chl_result=[0,0,0,0,0];
    for i=1:5;
        y=lats_pix(i);
        x=lons_pix(i);
        chl_result=[chl_result; [y,x, lats(i),lons(i),chl(y,x)]];
    end    
    chl_result= chl_result(2:end, : );
    disp('               y               x               lats              lons            chl');
    disp(chl_result);
    disp('x pixel of the new version:');
    disp(lons_pix);
    disp('y pixel of the new version:');
    disp(lats_pix);
% --------------------------------------------------------------------
% This is the old version
% file_info=hdfinfo(chlfile);
% sds_info= file_info.SDS;
% chl= hdfread(sds_info); %Load all of the chl data from file.
chl_copy=chl;
chl_copy(chl==-32767)=nan;
new_chl=chl_copy;
x=[122.800,122.633,127.300,125.500,126.133];
y=[31.633,31.000,28.433,29.250,31.433];
x_pixel=round((x-lons_range(1))/0.0833333)+1;
y_pixel=size(lats_range,2)-round((y-lats_range(end))/0.0833333);
% datas= new_chl(x_pixel,y_pixel);
datas=0;
for k=1:size(x,2)
    datas= [datas, new_chl(y_pixel(k),x_pixel(k))];
end
datas=datas(2:end);
result= [x_pixel', y_pixel',x',y',datas'];
disp(result);
disp('x pixel of the old version:');
    disp(x_pixel);
    disp('y pixel of the old version:');
    disp(y_pixel);