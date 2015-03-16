PRO SARGUI_OPENBMP,EVENT
infile=dialog_pickfile(title='´ò¿ªBMPÓ°Ïñ',filter='*.bmp',/read)
if infile eq '' then return
bmp=read_bmp(infile)
temp=size(bmp)
columns=temp(1)
lines=temp(2)
window,xsize=columns,ysize=lines,title=infile,/free
tv,bmp
END