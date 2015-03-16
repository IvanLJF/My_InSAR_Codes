% 使用k490和ctot计算出的zeu对比分析
% 指定文件路径
clear;
clc;
chlorfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_CHL_chlor_a_9km';
kdfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_KD490_Kd_490_9km';
parfile= 'D:\myfiles\Yatou_paper\Data\200309\S20032442003273.L3m_MO_PAR_par_9km';
sstfile= 'D:\myfiles\Yatou_paper\Data\200309\A20032442003273.L3m_MO_SST_9';
% chlorfile= 'D:\myfiles\Yatou_paper\Data\chl\S20000322000060.L3m_MO_CHL_chlor_a_9km';
% kdfile= 'D:\myfiles\Yatou_paper\Data\kd490\S20000322000060.L3m_MO_KD490_Kd_490_9km';
% parfile= 'D:\myfiles\Yatou_paper\Data\par\S20000322000060.L3m_MO_PAR_par_9km';
% sstfile= 'D:\myfiles\Yatou_paper\Data\sst\T20000322000060.L3m_MO_SST_9';
result_path= 'D:\myfiles\Yatou_paper\result';
%--------------------------------------------------------
% 读取数据
range=[598,812,3566,3696];%[598,812,3566,3696];%裁剪的区域。
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
chl= double(chl); chl(chl==-32767)=nan;
kd= load_hdf_chinasea(kdfile, range(1),range(2),range(3),range(4));
kd= double(kd); kd(kd==-32767)=nan;
PAR= load_hdf_chinasea(parfile, range(1),range(2),range(3),range(4));
PAR= double(PAR); PAR(PAR==-32767)=nan;
%处理sst数据
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= sst(range(1):range(2),range(3):range(4));% 读取SST的数据。
sst= double(sst); sst(sst==65535)=nan;
% disp(file_info.Attributes(54).Name);
% disp(file_info.Attributes(54).Value);%改正公式
slope=double(file_info.Attributes(55).Value);%改正公式中的参数
intercept=double(file_info.Attributes(56).Value);%改正公式中的参数
sst= slope*sst+intercept;%具体转换公式参见file_info.Attributes(54).Value.

%------------------------计算--------------------------------
% vgpmresult= cal_opp_chinasea(chlorfile, kdfile, parfile, sstfile, result_path);

% new_chl= 4.04672*log((chl+10.02913)/9.62471);
% 
% difference= chl-new_chl;
% Zeu_first= difference;
%计算真光层深度。两种方法：K490和Ctot
Zeu_k490= 3.512./kd;

Ctot=40.2*chl.^0.507;
Ctot(chl<1.0)=38.0*chl(chl<1.0).^0.425;
Zeu_Ctot=568.2*(Ctot.^(-0.746));
Zeu_Ctot(Ctot< 9.9)=200*(Ctot(Ctot< 9.9).^(-0.293));
%------------------------图框的注释--------------------------------
[pathstr, chlname, ext, versn]= fileparts(chlorfile);
start_time= double(str2double(chlname(2:8)));%起始时间
end_time= double(str2double(chlname(9:15)));%终止时间
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%纬度的总范围
lons_range= X(range(3):range(4));%经度的总范围

%---------------------------------提取数据-------------------
% chl_copy=chl;
% chl_copy(chl==-32767)=nan;
% new_chl(chl==-32767)=nan;
% x=[122.800,122.633,127.300,125.500,126.133];
% y=[31.633,31.000,28.433,29.250,31.433];
% x_pixel=round((x-lons_range(1))/0.0833333);
% y_pixel=size(lats_range,2)-round((y-lats_range(end))/0.0833333);
% % datas= new_chl(x_pixel,y_pixel);
% datas=0;
% for k=1:size(x,2) 
%     datas= [datas, new_chl(y_pixel(k),x_pixel(k))];
% end
% datas=datas(2:end);
% result= [x',y',datas']
% % subset= new_chl(min(min(x_pixel)):max(max(x_pixel)),...
% %                 min(min(y_pixel))-50:max(max(y_pixel)));            
% subset= new_chl(y_pixel(1)-20:y_pixel(1)+20,x_pixel(1)-20:x_pixel(1)+20);
% figure(2)          ;
% h=imagesc(subset);
% set(h, 'alphadata', ~isnan(subset));
% pause;
%--------------------------------------------------------
scale=600/max(max(size(chl)));%拉伸比例
figure( 'Position',[50,50,scale*size(Zeu_k490,2),scale*size(Zeu_k490,1)]);
    h=imagesc(Zeu_k490);
    set(h, 'alphadata', ~isnan(Zeu_k490));
%     caxis(data_range);
    data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Zeu(Use K490) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(Zeu_k490,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(Zeu_k490,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(Zeu_k490,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(Zeu_k490,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\Zeu-使用K490.bmp');
    saveas(gcf, outname);
%     close all;
    
scale=600/max(max(size(chl)));%拉伸比例
figure( 'Position',[50,50,scale*size(Zeu_Ctot,2),scale*size(Zeu_Ctot,1)]);
    h=imagesc(Zeu_Ctot);
    set(h, 'alphadata', ~isnan(Zeu_Ctot));
    caxis(data_range);
%     data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('Zeu(Use Ctot) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(Zeu_Ctot,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(Zeu_Ctot,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(Zeu_Ctot,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(Zeu_Ctot,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    outname= strcat(result_path,'\Zeu-使用Ctot.bmp');
    saveas(gcf, outname);
%     close all;

pause;
close all;