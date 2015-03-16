%OPP calculated USING MIKE BEHRENFELD'S MODEL
function opp=vgpm(chl,sst,dl,PAR)

% if chl< 1.0
% Ctot=38.0*chl.^0.425;
% else
% Ctot=40.2*chl.^0.507;
% end
% 
% if Ctot< 9.9
% Zeu=200*(Ctot.^(-0.293));
% else 
% Zeu=568.2*(Ctot.^(-0.746));
% end
% 
% 
% if sst < -1.0
% Popt=1.13;
% elseif sst> 28.5
% Popt=4;
% else
% Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
%     1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
% end
Ctot=40.2*chl.^0.507;
Ctot(chl<1.0)=38.0*chl(chl<1.0).^0.425;
Zeu=568.2*(Ctot.^(-0.746));
Zeu(Ctot< 9.9)=200*(Ctot(Ctot< 9.9).^(-0.293));
Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
    1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
Popt(sst<-1.0)=1.13;
Popt(sst>28.5)=4;
opp=0.66125.*Popt.*PAR./(PAR+4.1).*chl.*Zeu.*dl;
