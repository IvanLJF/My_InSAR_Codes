%OPP calculated USING MIKE BEHRENFELD'S MODEL
function opp=vgpm_no_modify(chl,sst,kd,dl,PAR)

Zeu= 3.512./kd;

if sst < -1.0
    Popt=1.13;
elseif sst> 28.5
    Popt=4.0;
else
    Popt=1.2956+2.749*0.1*sst+6.17*0.01*(sst).^2-2.05*0.01*(sst).^3+2.462*0.001*(sst).^4-...
        1.348*0.0001*(sst).^5+3.4132*0.000001*(sst).^6-3.27*0.00000001*(sst).^7;
    Popt= single(Popt);
end

opp=0.66125.*Popt.*PAR./(PAR+4.1).*chl.*Zeu.*dl;
