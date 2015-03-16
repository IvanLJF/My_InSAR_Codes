% show single image of the given area.
clear;
clc;
infile='D:\myfiles\Software\Yatou_Paper\Data\Chl\S20032442003273.L3m_MO_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003252.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003257.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003260.L3m_DAY_CHL_chlor_a_9km';
% infile='D:\myfiles\Software\Yatou_Paper\Data\Chl_dailay\S2003267.L3m_DAY_CHL_chlor_a_9km';

range=[598,812,3566,3696];%[598,812,3566,3696];% Range of China Sea.
data= load_hdf_chinasea(infile,range(1),range(2),range(3),range(4));

file_info= hdfinfo(infile);
sds_info=file_info.SDS;
sds_info= sds_info(1,1);
data= hdfread(sds_info);
data= double(data);
data(data==-32767)=nan;
data= data(range(1):range(2),range(3):range(4));% Get data of China sea.
data= single(data);
% disp(file_info.Attributes(54).Name);
% disp(file_info.Attributes(54).Value);%
% slope=double(file_info.Attributes(55).Value);%
% intercept=double(file_info.Attributes(56).Value);%
% sst= slope*sst+intercept;%file_info.Attributes(54).Value.
% sst= single(sst);

%------------------------Annotations--------------------------------
[pathstr, filename, ext, versn]= fileparts(infile);
img_time= double(str2double(filename(2:8)));%Date of the input file.

result=day2date(img_time);
date_anno= result(3);
month_anno= result(2);
year_anno= result(1);
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%lats range of the data
lons_range= X(range(3):range(4));%lons range of the data

%------------------------Plot image--------------------------------

scale=600/max(max(size(data)));
figure( 'Position',[50,50,scale*size(data,2),scale*size(data,1)]);
    h=imagesc(data);
    set(h, 'alphadata', ~isnan(data));
%     caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Date of the given data :',num2str(date_anno), '/', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(data,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(data,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(data,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(data,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))});
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
