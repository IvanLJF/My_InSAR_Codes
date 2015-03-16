% OPP main procedure
clear;
dl=load('K:/D_daylength/Mon1ChinaDL.dat');
chl=load('K:\D_SeaWiFS\Mapped\Monthly\CHLO\CHLO_data\19981ChinaCHLO.dat'); 
sst=load('K:\D_AVHRR\SST_9KM\19981SST9_China.dat'); 
PAR=load('K:\D_SeaWiFS\Mapped\Monthly\PAR\PAR_data\19981ChinaPAR.dat'); 

opp=vgpm(chl, sst, dl, PAR);
opp(chl==nan)=nan;

lon_c=load('K:\D_SeaWiFS\Mapped\Annual\Lon_CC.dat');
lat_c=load('K:\D_SeaWiFS\Mapped\Annual\Lat_CC.dat');  
figure(1);
    pcolor(lon_c,lat_c,opp);
    colormap(cb_chl);
    set(gca,'layer','top'); 
    shading flat; % remove the grid lines
    colormap(cb_chl);
    xlabel ('Longitude(E)','fontsize',10);
    ylabel ('Latitude(N)','fontsize',10);
    %caxis([-3 40]);  
    colorbar;