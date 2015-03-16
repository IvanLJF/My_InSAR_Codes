function opp= oppls(chl, sst, dl, PAR)
chl(chl == -32767)=1000;      % change the NaN data to the value of 1000; nan.^0.1 makes a complex
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

opp=0.66125.*double(Popt).*double(PAR)./(double(PAR)+4.1).*double(chl).*double(Zeu).*double(dl);