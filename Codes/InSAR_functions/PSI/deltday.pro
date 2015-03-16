FUNCTION DELTDAY,LDAY,BDAY
;-此函数用以获取两成像时刻的时间间隔
year1=floor(lday/10000)
year2=floor(bday/10000)
month1=floor(lday/100)-year1*100
month2=floor(bday/100)-year2*100
day1=lday-year1*10000-month1*100
day2=bday-year2*10000-month2*100

;判断两个日期哪个更小
if lday lt bday then begin
  lyear=year1
endif else begin
  lyear=year2
endelse

;求出两个日期分别同lyear/01/01的差
delt1=0 & delt2=0

if year1 gt lyear then begin
  for y=lyear,year1-1 do begin
    if y/4*4 eq y then begin
      delt1=delt1+366
    endif else begin
      delt1=delt1+365
    endelse
  endfor
endif  
;判断是否是闰年
if year1/4*4 eq year1 then begin
  m2=29
endif else begin
  m2=28
endelse
if month1 gt 1 then begin
  for m=1,month1-1 do begin
    case m of
      1: delt1=delt1+31
      3: delt1=delt1+31
      4: delt1=delt1+30
      5: delt1=delt1+31
      6: delt1=delt1+30
      7: delt1=delt1+31
      8: delt1=delt1+31
      9: delt1=delt1+30
      10: delt1=delt1+31
      11: delt1=delt1+30
      else: delt1=delt1+m2
    endcase
  endfor
endif
delt1=delt1+day1
if year2 gt lyear then begin
  for y=lyear,year2-1 do begin
    if y/4*4 eq y then begin
      delt2=delt2+366
    endif else begin
      delt2=delt2+365
    endelse
  endfor
endif  
  
;判断是否是闰年
if year2/4*4 eq year2 then begin
  m2=29
endif else begin
  m2=28
endelse
if month2 gt 1 then begin
  for m=1,month2-1 do begin
    case m of
      1: delt2=delt2+31
      3: delt2=delt2+31
      4: delt2=delt2+30
      5: delt2=delt2+31
      6: delt2=delt2+30
      7: delt2=delt2+31
      8: delt2=delt2+31
      9: delt2=delt2+30
      10: delt2=delt2+31
      11: delt2=delt2+30
      else: delt2=delt2+m2
    endcase
  endfor
endif
delt2=delt2+day2
return,delt2-delt1
end