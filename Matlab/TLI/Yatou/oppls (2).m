% 最小二乘模型计算opp
% 其中，sd= Zeu/2.53，Zeu=kd
function opp_ls= oppls(chl, sst, dl,kd, PAR)
  coe=11.8722;
  Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
    1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
  Popt(sst < -1.0)=1.13;
  Popt(sst> 28.5)=4;
  Popt= single(Popt);
%   chl(chl == -32767)=1000; % change the NaN data to the value of 1000; nan.^0.1 makes a complex
  Zeu= kd;
  sd= Zeu/2.53;
  %计算X
  X= 0.3+(chl-1.5).*2.2./8.5;
  X(chl <=1.5)=0.3;
  X(chl >=2.5)=2.5;
  chleu=0.9899*(chl.^0.734);
  
  opp_ls= coe*(0.11-0.037*log10(PAR)).*Popt.*chleu.*sd.*PAR.*dl.*(chl./(chl+X));
  opp_ls(chl==-32767)=nan;
  opp_ls(PAR==-32767)=nan;