function result= cal_opp_chinasea_ls(chl_file, kd_file, par_file, sst_file, result_path)

% 指定文件路径
chlorfile= chl_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_CHL_chlor_a_9km';
kdfile= kd_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_KD490_Kd_490_9km';
parfile= par_file;%'D:\myfiles\Yatou_paper\Data\S20000922000121.L3m_MO_PAR_par_9km';
sstfile= sst_file;%'D:\myfiles\Yatou_paper\Data\T20000922000121.L3m_MO_SST_9';
result_path=result_path;%'D:\myfiles\Yatou_paper\result'

% 读取数据
range=[598,812,3566,3696];%[598,812,3566,3696];%裁剪的区域。
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
kd= load_hdf_chinasea(kdfile, range(1),range(2),range(3),range(4));
PAR= load_hdf_chinasea(parfile, range(1),range(2),range(3),range(4));
%处理sst数据
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= sst(range(1):range(2),range(3):range(4));% 读取SST的数据。
sst= single(sst);
% disp(file_info.Attributes(54).Name);
% disp(file_info.Attributes(54).Value);%改正公式
slope=double(file_info.Attributes(55).Value);%改正公式中的参数
intercept=double(file_info.Attributes(56).Value);%改正公式中的参数
sst= slope*sst+intercept;%具体转换公式参见file_info.Attributes(54).Value.
sst= single(sst);

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
new_chl= 4.04672*log((chl+10.02913)/9.62471);
% opp_vgpm= vgpm(new_chl,sst,dl,PAR);
% % opp_vgpm(opp_vgpm<0)=nan;
% opp_vgpm(chl == -32767)=nan;
% %使用最小二乘模型计算OPP
opp_ls= oppls(new_chl, sst, dl, kd,PAR);
opp_ls(chl==-32767)=nan;
%---------------------------------------------------

% % LS模型的过程参数
    Zeu= kd/2.53;
    
    
    var_outname=strcat(result_path, '\data\', chlname,'-opp(LS).mat');
    save(var_outname,'opp_ls','sst','chl','Zeu');
    %load(var_outname, 'opp_vgpm_orig','opp_vgpm','opp_ls','opp_ls');

    %----------------------------------------------------------------------
    %最小二乘 做图
    figure( 'Position',[50,50,scale*size(opp_ls,2),scale*size(opp_ls,1)]);
    h=imagesc(opp_ls);
    set(h, 'alphadata', ~isnan(opp_ls));
    % set(gcf, 'Color', [1,1,1])
    name= strcat('OPP(LS Model) of month:', num2str(month_anno),'/',num2str(year_anno), '(mg C m^-^2 day^-^1)');
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
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    % 保存图片
    outname= strcat(result_path, '\bmps\',chlname,'-opp(ls).bmp');
    saveas(gcf, outname);

close all;