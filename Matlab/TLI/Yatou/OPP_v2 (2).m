% OPP main procedure

clear;

y1=1998;
y2=2008;
m1=1;
m2=12;

for year=y1:y2
    for mon=m1:m2

dl=load(['K:/D_daylength/','Mon',num2str(mon),'ChinaDL.dat']);
chl=load(['K:\D_SeaWiFS\Mapped\Monthly\CHLO\CHLO_data\',num2str(year),num2str(mon),'ChinaCHLO.dat']); 
sst=load(['K:\D_AVHRR\SST_9KM\',num2str(year),num2str(mon),'SST9_China.dat']); 
PAR=load(['K:\D_SeaWiFS\Mapped\Monthly\PAR\PAR_data\',num2str(year),num2str(mon),'ChinaPAR.dat']); 

chl(isnan(chl))=1000;      % change the NaN data to the value of 1000; nan.^0.1 makes a complex
Ctot=40.2*chl.^0.507;
Ctot(chl< 1.0)=0;
Ctot1=38.0*chl.^0.425;
Ctot1(chl>=1.0)=0;
Ctot=Ctot+Ctot1;

Zeu=568.2*(Ctot.^(-0.746));
Zeu(Ctot< 9.9)=0;
Zeu1=200*(Ctot.^(-0.293));
Zeu1(Ctot>= 9.9)=0;
Zeu=Zeu+Zeu1;
Zeu(chl==1000)=nan;

Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
    1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
Popt(sst < -1.0)=1.13;
Popt(sst> 28.5)=4;

opp=0.66125.*Popt.*PAR./(PAR+4.1).*chl.*Zeu.*dl;

save (['K:\D_OPP\OPP_stded\',num2str(year),num2str(mon),'_OPP_cn.dat'], 'opp','-ascii'); 

lon_c=load('K:\D_SeaWiFS\Mapped\Annual\Lon_CC.dat');
lat_c=load('K:\D_SeaWiFS\Mapped\Annual\Lat_CC.dat');  
figure(1);
    pcolor(lon_c,lat_c,opp);
    colormap(cb_chl);
    set(gca,'linewidth',1); 
    set(gca,'layer','top'); 
    set(gca,'fontsize',8);
    shading flat; % remove the grid lines
    colormap(cb_chl);
    title('OPP, mg C m^-^2 day^-^1','fontsize',8);
    xlabel ('Longitude(E)','fontsize',8);
    ylabel ('Latitude(N)','fontsize',8);
    caxis([0 6000]);  
    colorbar;
Expt2png10_8(['K:\D_OPP\OPP_figs\','M_opp',num2str(year),num2str(mon)]);
end
end
  