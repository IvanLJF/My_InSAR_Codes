;deflos.pro
pro deflos

day=15
num_PS=3211

nld=fltarr(day,num_PS)
dlos=fltarr(day,num_PS)
pathin='D:\InSARIDL\SARGUI\IMAGES\'
pathout='D:\InSARIDL\SARGUI\IMAGES\'

;读取每个PS点上的非线性形变分量
;-----------------------------
infile=pathout+'nldef.dat'
openr,lun,infile,/get_lun
readu,lun,nld
free_lun,lun

;读取每个PS点上的线性形变速率和成像时间
;-----------------------------
V=fltarr(num_PS);
infile=pathout+'V.txt'
openr,lun,infile,/get_lun
readf,lun,V
free_lun,lun

date=lonarr(day)

openr,lun,'D:\InSARIDL\SARGUI\IMAGES\sarlist.dat',/get_lun
readu,lun,date
free_lun,lun

for i=0,day-1 do begin
dd=deltday(date(i),date(0))
dlos[i,*]=V*dd/365+nld(i,*)
endfor
;是否做显示？
print,size(dlos)
;保存每个PS点上的非线性形变分量
;-----------------------------
outfile=pathout+'deflos.dat'
openw,lun,outfile,/get_lun
printf,lun,dlos
free_lun,lun

print,'Ok! The deflos processing is completed!'
end