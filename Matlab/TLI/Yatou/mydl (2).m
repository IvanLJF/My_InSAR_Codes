%for matlab
%Calculation of day light length.

function daylength=mydl(year,month,date,lat)
if(mod(year,4)==0)
if(mod(year,100)==0)
if(mod(year,400)==0)
jm=[0,31,29,31,30,31,30,31,31,30,31,30];
else
end
jm=[0,31,28,31,30,31,30,31,31,30,31,30];
else
end
jm=[0,31,29,31,30,31,30,31,31,30,31,30];
else
jm=[0,31,28,31,30,31,30,31,31,30,31,30];
end
for j=1:month
date=date+jm(j);
end
if(lat<0)
date=date-183;
else
end
if(date<=0)
date=date+366;
else
end
xjr=double(date)*2.*3.1415926/366;

delta=.32281-22.984*cos(xjr)-.3499*cos(2.*xjr)-.1398*cos(3.*xjr)+3.7878*sin(xjr)+.03205*sin(2.*xjr)+.07187*sin(3.*xjr);
xlatr= lat*3.1415926/180.;
cosah=-tan(xlatr)*tan(delta*3.1415926/180.);
if(abs(cosah)>=1.0)
if(delta*xlatr>0.)
daylength=24.0;
else
daylength=0.0;
end
else
daylength=24.*(acos(cosah))./3.1415926;
end