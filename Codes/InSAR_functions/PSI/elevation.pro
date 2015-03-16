;elevation.pro
pro elevation

width=500
height=500

high=fltarr(width,height);也可以创建其他数组，但是大小不能有错误


pa='D:\IDL\xiqing\'
re='D:\IDL\result\'

;------------------read image-------------------------
infile=pa+'sim_sar_rdc'
openr,lun,infile,/get_lun,/swap_endian
readu,lun,high
free_lun,lun

;loadct,12    ;调取色度条

elefile=re+'elevation.txt'
openw,lun,elefile,/get_lun
printf,lun,high
free_lun,lun

print,'ok'

;device,decomposed=0
;window,/free,xsize=720,ysize=700
;!p.background=1
;;temp=congrid(temp,200,140)   ;数据拉伸从原始范围拉伸到200*400
;xsft=50
;ysft=150;设置xy方向的偏移量
;tv,image,xsft,ysft;将图像显示出来。自动调整数据范围以适应显示器。
;
;
;
;cb = bindgen(255);创建数组，大小1*251，整数升序排列
;;cb = extrac(cb, 0,255);提取cb中的第0~200的数
;cb = cb#replicate(1b, 15)
;x0=630/2-122
;y0=ysft/2
;tv, cb, x0,y0
;
;   contour,temp,ystyle=1,xrange=[1,500],xstyle=1,levels=300,$
;         position=[xsft,ysft,500+xsft,500+ysft],/NOERASE,/DEVICE,font=0,$
;           xticklen=0.02,yticklen=0.02,$
;         xtickname=[100,200,300,400,500],$
;         ytickname=[0,100,200,300,400,499],$
;         title=x
;        CONTOUR, cb,yrange=[ 0,1], ystyle=1, xrange=[0,255], xstyle=1,level=300,$
;        position = [x0,y0,x0+255,y0+15], /NOERASE, /DEVICE, font=0,$
;        xticklen=0.2,yticklen=0.02,xticks = 5,xminor=4,yticks=1,$
;        xtickname = ['0','51','102','153','204','255'], $
;        ytickname = [' ',' ']
;       xyouts,1,2,'     Swjtu.     RS_Lab.    Zhang Rui',font=0
;device,decomposed=0
;n=1
;temp=tvrd(true=n)
end