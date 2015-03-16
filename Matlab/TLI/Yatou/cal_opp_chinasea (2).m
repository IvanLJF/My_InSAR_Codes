% ?????VGPM????OPP

% ??????
clear;
clc;
chlorfile='D:\myfiles\Software\Yatou_Paper\Data\S20000922000121.L3m_MO_CHL_chlor_a_9km';
kdfile= 'D:\myfiles\Software\Yatou_Paper\Data\S20000922000121.L3m_MO_KD490_Kd_490_9km';
parfile= 'D:\myfiles\Software\Yatou_Paper\Data\S20000922000121.L3m_MO_PAR_par_9km';
sstfile= 'D:\myfiles\Software\Yatou_Paper\Data\T20000922000121.L3m_MO_SST_9';

% ????
range=[598,812,3566,3696];%[667,707,3612,3652];%??????
chl= load_hdf_chinasea(chlorfile,range(1),range(2),range(3),range(4));
% sst= load_hdf_chinasea(sstfile, range(1),range(2),range(3),range(4));
file_info= hdfinfo(sstfile);
sst_sds_info=file_info.SDS;
sst_sds_info= sst_sds_info(1,1);
sst= hdfread(sst_sds_info);
sst= sst(range(1):range(2),range(3):range(4));% ??SST????
PAR= load_hdf_chinasea(parfile, range(1),range(2),range(3),range(4));

% ??????dl
% ???????????
X=[-180:0.0833333:180];
Y=fliplr([-90:0.0833333:90]);
lats_range= Y(range(1):range(2));%??????
lons_range= X(range(3):range(4));%??????
% ??????????
year=2000;
month=4;
dl=0;
for i=1:size(lats_range,2)
   dl_tmp= month_ave_dl(year,month,lats_range(i));% ??dl
   dl=[dl, dl_tmp];
end
dl= dl(2:end);
dl= dl' * ones(1,range(4)-range(3)+1);%????range??????

% ??VGPM????OPP
opp_vgpm= vgpm(chl,sst,dl,PAR);
% opp(isnan(chl))=nan;%?opp?????chl??nan????????nan?
opp_vgpm(chl == -32767)=nan;
% opp_vgpm(isnan(opp_vgpm))=max(max(opp_vgpm))*1.1;

%??
scale=2; % ????
figure( 'Position',[100,100,scale*size(opp_vgpm)]);
h=imagesc(opp_vgpm);
set(h, 'alphadata', ~isnan(opp_vgpm));
% set(gcf, 'Color', [1,1,1])
name= strcat('OPP(VGPM) of month:', num2str(month),'/', num2str(year), '(mg C m^-^2 day^-^1)');
title(name,'fontsize',8);
colorbar;
x_ticks=6;
y_ticks=6;
x_step=size(opp_vgpm,2)/x_ticks; %??x???????????????
y_step=size(opp_vgpm,1)/y_ticks; %??y???????????????
xtick_loc= round(1:x_step:size(opp_vgpm,2));%??x???????????
ytick_loc= round(1:y_step:size(opp_vgpm,1));%??y???????????
set(gca, 'XTick', xtick_loc);
set(gca, 'YTick', ytick_loc);
set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});% ??x???????????
set(gca, 'YTickLabel', {round(lats_range(ytick_loc))});% ??y???????????
xlabel ('Longitude(E)','fontsize',10);
ylabel ('Latitude(N)','fontsize',10);
% shading flat;
% colordata=colormap;
% colordata(end, :)=[1 1 1];
% colormap(colordata);

%??????????OPP
opp_ls= oppls(chl, sst, dl, PAR);

%??
figure( 'Position',[100,100,scale*size(opp_ls)]);
h=imagesc(opp_ls);
set(h, 'alphadata', ~isnan(opp_ls));
name= strcat('OPP(LS Model) of month:', num2str(month),'/', num2str(year), '(mg C m^-^2 day^-^1)');
title(name,'fontsize',8);
colorbar;
x_ticks=6;
y_ticks=6;
x_step=size(opp_ls,2)/x_ticks; %??x???????????????
y_step=size(opp_ls,1)/y_ticks; %??y???????????????
xtick_loc= round(1:x_step:size(opp_ls,2));%??x???????????
ytick_loc= round(1:y_step:size(opp_ls,1));%??y???????????
set(gca, 'XTick', xtick_loc)
set(gca, 'YTick', ytick_loc)
set(gca, 'XTickLabel', {round(lons_range(xtick_loc))});% ??x???????????
set(gca, 'YTickLabel', {round(lats_range(ytick_loc))});% ??y???????????
xlabel ('Longitude(E)','fontsize',10);
ylabel ('Latitude(N)','fontsize',10);

result=opp_vgpm-opp_ls;