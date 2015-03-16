; chapter02Image.pro

pro chapter02Image

filename = Filepath('abnorm.dat')
MyTempVar = BytArr(64,64)
OPENR, lun, filename, /GET_LUN
image = ASSOC(lun, MyTempVar)

for i= 0,15 do begin

    TvScl, image[i],i

endfor

end