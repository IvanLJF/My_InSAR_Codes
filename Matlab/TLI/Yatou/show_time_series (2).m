% 对所有月份的opp进行时间序列分析。
% 均值、总和等。
clear;
clc;
result_path= 'D:\myfiles\Yatou_paper\result';
result_files=dir(strcat(result_path,'\data\*.mat'));

total=0;
ave=0;
date='       ';

total_sst=0;
ave_sst=0;

total_chl=0;
ave_chl=0;

total_Zeu=0;
ave_Zeu=0;

total_PAR=0;
ave_PAR=0;
for i=1: size(result_files,1)
    result_file= strcat(result_path,'\data\',result_files(i).name);
    [pathstr, chlname, ext, versn]= fileparts(result_file);
    start_time= double(str2double(chlname(2:8)));%起始时间
    end_time= double(str2double(chlname(9:15)));%终止时间
    result=day2date(start_time);
    month_anno= result(2);
    if month_anno < 10 %不足10月，月份前面补0
        month_anno= strcat(num2str(0),num2str(month_anno));
    else
        month_anno= num2str(month_anno);
    end
    year_anno= result(1);
    
    load(result_file, 'opp_vgpm','sst','chl','Zeu','PAR');
    total= [total, sum(sum(opp_vgpm(~isnan(opp_vgpm))))];
    ave= [ave, mean(mean(opp_vgpm(~isnan(opp_vgpm))))];
    date= [date; strcat((month_anno),'/',num2str(year_anno))];
    
    total_sst= [total_sst, sum(sum(sst(~isnan(sst))))];
    ave_sst= [ave_sst, mean(mean(sst(~isnan(sst))))];
    
    total_chl= [total_chl, sum(sum(chl(~isnan(chl))))];
    ave_chl= [ave_chl, mean(mean(chl(~isnan(chl))))];
    
    total_Zeu= [total_Zeu, sum(sum(Zeu(~isnan(Zeu))))];
    ave_Zeu= [ave_Zeu, mean(mean(Zeu(~isnan(Zeu))))];
    
    total_PAR= [total_PAR, sum(sum(PAR(~isnan(PAR))))];
    ave_PAR= [ave_PAR, mean(mean(PAR(~isnan(PAR))))];
end
total= total(2:end);
ave= ave(2:end);
date= date(2:end,:);

total_sst= total_sst(2:end);
ave_sst=ave_sst(2:end);

total_chl= total_chl(2:end);
ave_chl= ave_chl(2:end);

total_Zeu= total_Zeu(2:end);
ave_Zeu= ave_Zeu(2:end);

total_PAR= total_PAR(2:end);
ave_PAR= ave_PAR(2:end);
% 把数据连起来
ind = find(isnan(ave));
ave(ind)= ave(ind-1);
ave(ind)= ave(ind-1);

ave_sst(ind)= ave_sst(ind-1);
ave_sst(ind)= ave_sst(ind-1);

ave_chl(ind)=ave_chl(ind-1);
ave_chl(ind)=ave_chl(ind-1);

ave_Zeu(ind)=ave_Zeu(ind-1);
ave_Zeu(ind)=ave_Zeu(ind-1);

ave_PAR(ind)=ave_PAR(ind-1);
ave_PAR(ind)=ave_PAR(ind-1);

% 做图并保存
%--------------------------------------------------------
% ave
figure(1);
plot(ave, '--rs', 'LineWidth',2, ...
                  'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', 'g', ...
                  'MarkerSize',3);

%     set(h, 'alphadata', ~isnan(opp_vgpm_orig));
    name= strcat('初级生产力平均值', '(mg·C·m^-^2·day^-^1)');
%     title(name,'fontsize',10);
    x_ticks=7;
    y_ticks=8;
    low_anno= min(min(ave));
    upper_anno= max(max(ave));
    x_step=size(ave,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=(upper_anno-low_anno)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(x_step:x_step:size(date,1));%设置x坐标轴显示刻度的位置。
    ytick_loc= (low_anno:y_step:upper_anno);%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {date(xtick_loc, :)});
    set(gca, 'YTickLabel', {ytick_loc})
    set(gcf, 'Color', [1 1 1]);
    xlabel ('时间','fontsize',10);
    ylabel (name,'fontsize',10);
%     grid on;
    % 保存图片
    outname= strcat(result_path,'\time_series_opp.bmp');
    saveas(gcf, outname);
%     close 1;
    
%--------------------------------------------------------
    % ave_sst
    figure(2);
    plot(ave_sst, '--rs', 'LineWidth',2, ...
                  'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', 'g', ...
                  'MarkerSize',3);

    name= strcat('海洋表面温度', '(°C)');
%     title(name,'fontsize',10);
    x_ticks=7;
    y_ticks=8;
    low_anno= min(min(ave_sst));
    upper_anno= max(max(ave_sst));
    x_step=size(ave_sst,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=(upper_anno-low_anno)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(x_step:x_step:size(date,1));%设置x坐标轴显示刻度的位置。
    ytick_loc= (low_anno:y_step:upper_anno);%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {date(xtick_loc, :)});
    set(gca, 'YTickLabel', {ytick_loc})
    set(gcf, 'Color', [1 1 1]);
    xlabel ('时间','fontsize',10);
    ylabel (name,'fontsize',10);  
%     grid on;
%     pause;
    % 保存图片
    outname= strcat(result_path,'\time_series_sst.bmp');
    saveas(gcf, outname);
%     close 2;
   %-------------------------------------------------------- 
    %ave_chl
    figure(3);
    plot(ave_chl, '--rs', 'LineWidth',2, ...
                  'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', 'g', ...
                  'MarkerSize',3);

%     set(h, 'alphadata', ~isnan(opp_vgpm_orig));
    name= strcat('叶绿素浓度', '(mg·m^-^3)');
%     title(name,'fontsize',10);
    x_ticks=7;
    y_ticks=8;
    low_anno= min(min(ave_chl));
    upper_anno= max(max(ave_chl));
    x_step=size(ave_chl,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=(upper_anno-low_anno)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(x_step:x_step:size(date,1));%设置x坐标轴显示刻度的位置。
    ytick_loc= (low_anno:y_step:upper_anno);%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {date(xtick_loc, :)});
    set(gca, 'YTickLabel', {ytick_loc})
    set(gcf, 'Color', [1 1 1]);
    xlabel ('时间','fontsize',10);
    ylabel (name,'fontsize',10);   
%     grid on;
%     pause;
    % 保存图片
    outname= strcat(result_path,'\time_series_chl.bmp');
    saveas(gcf, outname);
%     close 3;
%--------------------------------------------------------
    %ave_Zeu
    figure(4);
    plot(ave_Zeu, '--rs', 'LineWidth',2, ...
                  'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', 'g', ...
                  'MarkerSize',3);

name= strcat('真光层深度', '(m)');
%     title(name,'fontsize',10);
    x_ticks=7;
    y_ticks=8;
    low_anno= min(min(ave_Zeu));
    upper_anno= max(max(ave_Zeu));
    x_step=size(ave_Zeu,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=(upper_anno-low_anno)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(x_step:x_step:size(date,1));%设置x坐标轴显示刻度的位置。
    ytick_loc= (low_anno:y_step:upper_anno);%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {date(xtick_loc, :)});
    set(gca, 'YTickLabel', {ytick_loc})
    set(gcf, 'Color', [1 1 1]);
    xlabel ('时间','fontsize',10);
    ylabel (name,'fontsize',10);  
%     grid on;
%     pause;
    % 保存图片
    outname= strcat(result_path,'\time_series_Zeu.bmp');
    saveas(gcf, outname);
%     close 4;
%--------------------------------------------------------
 %ave_Zeu
    figure(5);
    plot(ave_PAR, '--rs', 'LineWidth',2, ...
                  'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', 'g', ...
                  'MarkerSize',3);

name= strcat('光合有效辐射', '(W·m^-^2·day^-^1)');
%     title(name,'fontsize',10);
    x_ticks=7;
    y_ticks=8;
    low_anno= min(min(ave_PAR));
    upper_anno= max(max(ave_PAR));
    x_step=size(ave_PAR,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=(upper_anno-low_anno)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(x_step:x_step:size(date,1));%设置x坐标轴显示刻度的位置。
    ytick_loc= (low_anno:y_step:upper_anno);%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {date(xtick_loc, :)});
    set(gca, 'YTickLabel', {ytick_loc})
    set(gcf, 'Color', [1 1 1]);
    xlabel ('时间','fontsize',10);
    ylabel (name,'fontsize',10);  
%     grid on;
%     pause;
    % 保存图片
    outname= strcat(result_path,'\time_series_PAR.bmp');
    saveas(gcf, outname);
%     close 4;

pause;
close all;
                  