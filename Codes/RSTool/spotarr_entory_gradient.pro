pro spotarr_entory_gradient
;- 求图像的信息熵、坡度
openr,lun,'C:\ITT\IDL71\examples\data\spotarr.txt',/get_lun
spotarr=indgen(376,264)
readf,lun,spotarr
n=float(376L*264L)
m=float(375L*263L)
max1=max(spotarr[*,*])
min1=min(spotarr[*,*])
s=0.0D
for i=min1,max1,1 do begin
a=where(spotarr[*,*] eq i,num)
p=num/n
s=s+p*(alog(p+0.000000001)/alog(2))
endfor
s=-s
;
G=0.0d
for j=0,260,1 do begin
for i=0,373,1 do begin
R=((spotarr[i,j]-spotarr[i+1,j])^2+(spotarr[i,j]-spotarr[i,j+1])^2)
R=float(R)/2
G+=((1.0/m)*sqrt(R))
endfor
endfor
print,"The entory of spotarr is:" ,s
print,"The gradient of spotarr:",G
end


pro fusion_combination_entropy
;- 求图像的联合熵
openr,lun,'C:\ITT\IDL71\examples\data\fusionarr.txt',/get_lun
fusionarr=indgen(376,264,3)
readf,lun,fusionarr
;
n=float(376L*264L)
sum=0.0d

for i=0,259,1 do begin
for j=0,371,1 do begin
a=where(fusionarr[*,*,0] eq fusionarr[j,i,0],num1)
p1=num1/n
;
b=where(fusionarr[*,*,1] eq fusionarr[j,i,1],num2)
p2=num2/n
;
c=where(fusionarr[*,*,2] eq fusionarr[j,i,2],num3)
p3=num3/n
p=p1*p2*p3
sum+=p*(alog(p+0.00000001)/alog(2))
;print,"p= " ,p
;print,"sum= ",sum
endfor
endfor
sum=-sum
print,"The combination of entory of fusionarr is: ",sum
end
