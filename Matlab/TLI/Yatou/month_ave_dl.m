function result=month_ave_dl(year, month, lat)
% ??????????????
% year    :  ??
% month   :  ??
% lat     :  ??

% ????????????
if(mod(year,4)==0)
    if(mod(year,100)==0)
        if(mod(year,400)==0)
            jm=[0,31,29,31,30,31,30,31,31,30,31,30];
        else
        end
      jm=[31,28,31,30,31,30,31,31,30,31,30,31];
    else
    end
    jm=[31,29,31,30,31,30,31,31,30,31,30,31];
else
    jm=[31,28,31,30,31,30,31,31,30,31,30,31];
end

%?result???????????????
result=0;
for i=1:jm(month)
    dl= mydl(year, month, i, lat);
    result=result+dl/jm(month);   
end