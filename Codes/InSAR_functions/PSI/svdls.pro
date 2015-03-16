;svdls.pro
pro svdls
;- SVD的最小二乘解缠，恢复时间序列
day=15
compu=day*(day-1)/2
num_PS=3211


res=fltarr(num_PS,compu)
rdate=fltarr(day,num_PS)
pathin='D:\IDL\xiqing\'
pathout='D:\IDL\result\'

;构建系数矩阵A
B=intarr(day,compu)

m=0
for i=0,day-2 do begin
for j=i+1,day-1 do begin
B(i,m)=1
B(j,m)=-1
m=m+1
endfor
endfor

A=svd(B)

C=fltarr(compu-day,compu);
PA=[A,C]
SA=SPRSIN(PA); 

x=fltarr(1,compu);


;读取解缠后的相位残差res
outfile=pathout+'res.unwrap.dat'
openr,lun,outfile,/get_lun
readu,lun,res
free_lun,lun

;计算各PS点上的相位时间序列rdate
for i=0,num_PS-1 do begin
 print,i
  ;观测常量的生成
  L=res(i,*)
  LL=reform(L,compu)
  ;最小二乘平差求解
  x=SPRSAX(SA,LL)
  rdate(*,i)=abs(x(0:day-1))
endfor

;保存rdate
outfile=pathout+'res.temporal.dat'
openw,lun,outfile,/get_lun
writeu,lun,rdate
free_lun,lun

print,'Ok! The svdls processing is completed!'
end