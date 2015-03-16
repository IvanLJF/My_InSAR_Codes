% 展示2003年9月的最小二乘模型结果
infile='D:\myfiles\Yatou_paper\result\data\S20032442003273-opp(LS).mat';
load(infile, 'opp_ls');

% 设置做图信息
range=[598,812,3566,3696];%[598,812,3566,3696];%裁剪的区域。

[pathstr, chlname, ext, versn]= fileparts(infile);
start_time= double(str2double(chlname(2:8)));%起始时间
end_time= double(str2double(chlname(9:15)));%终止时间
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%纬度的总范围
lons_range= X(range(3):range(4));%经度的总范围

% 做图
scale=600/max(max(size(opp_ls)));%拉伸比例
figure( 'Position',[50,50,scale*size(opp_ls,2),scale*size(opp_ls,1)]);
    h=imagesc(opp_ls);
    set(h, 'alphadata', ~isnan(opp_ls));
%     caxis(data_range);
    data_range= caxis;
    data_range(2)= 1000;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Opp(LS model) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_ls,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_ls,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_ls,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_ls,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
