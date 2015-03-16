% 2003年，1/4/7/10四个月份的OPP分布。
clear;
clc;
infile_file1= 'D:\myfiles\Yatou_paper\result\data\S20030012003031-opp(VGPM).mat';
infile_file4='D:\myfiles\Yatou_paper\result\data\S20031212003151-opp(VGPM).mat';
infile_file7='D:\myfiles\Yatou_paper\result\data\S20031822003212-opp(VGPM).mat';
infile_file10='D:\myfiles\Yatou_paper\result\data\S20032742003304-opp(VGPM).mat';
result_path='D:\myfiles\Yatou_paper\result';
load(infile_file1, 'opp_vgpm');
opp_spring= opp_vgpm;
load(infile_file4, 'opp_vgpm');
opp_summer= opp_vgpm;
load(infile_file7, 'opp_vgpm');
opp_autumn= opp_vgpm;
load(infile_file10, 'opp_vgpm');
opp_winter= opp_vgpm;
%设置做图信息
% [pathstr, chlname, ext, versn]= fileparts(chlorfile);
% start_time= double(str2double(chlname(2:8)));%起始时间
% end_time= double(str2double(chlname(9:15)));%终止时间
% result=day2date(start_time);
% month_anno= result(2);
% year_anno= result(1);
range=[598,812,3566,3696];
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%纬度的总范围
lons_range= X(range(3):range(4));%经度的总范围

%--------------------------------做图-----------------------
scale=600/max(max(size(opp_vgpm)));%拉伸比例
% 秋
figure( 'Position',[50,50,scale*size(opp_autumn,2),scale*size(opp_autumn,1)]);
    h=imagesc(opp_autumn);
    set(h, 'alphadata', ~isnan(opp_autumn));
%     caxis(data_range);
    data_range= caxis;
    data_range(2)= 4500;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 07/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_spring,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_spring,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_spring,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003年7月opp.bmp');
    saveas(gcf, outname);
% 春
figure( 'Position',[50,50,scale*size(opp_spring,2),scale*size(opp_spring,1)]);
    h=imagesc(opp_spring);
    set(h, 'alphadata', ~isnan(opp_spring));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 01/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_spring,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_spring,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_spring,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003年1月opp.bmp');
    saveas(gcf, outname);
% 夏
figure( 'Position',[50,50,scale*size(opp_summer,2),scale*size(opp_summer,1)]);
    h=imagesc(opp_summer);
    set(h, 'alphadata', ~isnan(opp_summer));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 04/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_spring,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_spring,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_spring,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003年5月opp.bmp');
    saveas(gcf, outname);

% 冬
figure( 'Position',[50,50,scale*size(opp_winter,2),scale*size(opp_winter,1)]);
    h=imagesc(opp_winter);
    set(h, 'alphadata', ~isnan(opp_winter));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp of month: 10/2003  ', '(mg C m^-^2 day^-^1)');
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_spring,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_spring,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_spring,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_spring,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\2003年10月opp.bmp');
    saveas(gcf, outname);
    pause;
    close all;