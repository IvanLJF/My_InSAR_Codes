% 改正的chla和未改正的chla计算VGPM模型得出的OPP
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
%-----------------------计算opp-vgpm---------------------------------
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

% 计算光照时间dl
% 首先获取每个点的纬度。
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%纬度的总范围
lons_range= X(range(3):range(4));%经度的总范围
% 从文件名获取成像日期
[pathstr, chlname, ext, versn]= fileparts(chlorfile);
start_time= double(str2double(chlname(2:8)));%起始时间
end_time= double(str2double(chlname(9:15)));%终止时间
result=day2date(start_time);
month_anno= result(2);
year_anno= result(1);
dl=0;

for i=1:size(lats_range,2)
    dl_tmp=0;
    for j=1:(end_time-start_time+1)
        result= day2date(start_time+j);
        year_=result(1);
        month= result(2);
        date= result(3);
        dl_tmp= dl_tmp+mydl(year_,month,date,lats_range(i))/(end_time-start_time+1);% 计算日平均dl
    end
	dl=[dl, dl_tmp];
end
dl= dl(2:end);
dl= dl' * ones(1,range(4)-range(3)+1);%扩展到与range行列数一致。
scale=600/max(max(size(chl)));%拉伸比例
%-------------------------------------------------------------------------
% % 使用无改进的VGPM模型计算OPP
% opp_vgpm_orig= vgpm_no_improve(chl,sst,kd,dl,PAR);
% opp_vgpm_orig(opp_vgpm_orig<0)=nan;
% opp_vgpm_orig(chl == -32767)=nan;
% 使用VGPM模型计算OPP
new_chl= 4.04672*log((chl+10.02913)/9.62471);
% chl= new_chl;
opp_vgpm_noimprove= vgpm(chl,sst,dl,PAR);

opp_vgpm_improve= vgpm(new_chl, sst, dl, PAR);








%--------------------------------------------------------

    
%第二个数据
scale=600/max(max(size(opp_vgpm_improve)));%拉伸比例
figure( 'Position',[50,50,scale*size(opp_vgpm_improve,2),scale*size(opp_vgpm_improve,1)]);
    h=imagesc(opp_vgpm_improve);
    set(h, 'alphadata', ~isnan(opp_vgpm_improve));
%     caxis(data_range);
    data_range= caxis;
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(Improved Chlo.) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_vgpm_improve,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_vgpm_improve,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_vgpm_improve,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_vgpm_improve,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
%     close all;

% 第一个数据
scale=600/max(max(size(opp_vgpm_noimprove)));%拉伸比例
figure( 'Position',[50,50,scale*size(opp_vgpm_noimprove,2),scale*size(opp_vgpm_noimprove,1)]);
    h=imagesc(opp_vgpm_noimprove);
    set(h, 'alphadata', ~isnan(opp_vgpm_noimprove));
%     data_range= caxis;
%     data_range(2)= 5000;
    caxis(data_range);
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(Orig. Chlo.) of month  :', num2str(month_anno),'/', num2str(year_anno));
    title(name,'fontsize',8);
    colorbar;
    x_ticks=5;
    y_ticks=5;
    x_step=size(opp_vgpm_noimprove,2)/x_ticks;  %设置x坐标轴隔多少像素显示一个刻度。
    y_step=size(opp_vgpm_noimprove,1)/y_ticks;  %设置y坐标轴隔多少像素显示一个刻度。
    xtick_loc= round(1:x_step:size(opp_vgpm_noimprove,2));%设置x坐标轴显示刻度的位置。
    ytick_loc= round(1:y_step:size(opp_vgpm_noimprove,1));%设置y坐标轴显示刻度的位置。
    set(gca, 'XTick', xtick_loc);% 设置x坐标轴要显示的刻度值。
    set(gca, 'YTick', ytick_loc);% 设置y坐标轴要显示的刻度值。
    set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});
    set(gca, 'YTickLabel', {round(lats_range(ytick_loc))})
    set(gca, 'Color', 'white');
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
%     close all;