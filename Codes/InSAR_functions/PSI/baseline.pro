FUNCTION BASELINE,INFILES
num=0
s=fix(size(infiles,/dimensions))
dim=s(0)
basel=dblarr((dim-1)*dim/2)


for i=0,dim-2 do begin
  for j=i+1,dim-1 do begin
    x=center_pos(infiles(i))
    y=center_pos(infiles(j))
    basel(num)=sqrt(total((x-y)^2))
    num=num+1
  endfor
endfor
return,basel
end