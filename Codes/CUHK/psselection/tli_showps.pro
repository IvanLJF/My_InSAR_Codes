PRO TLI_SHOWPS

;;  ;- Generate a sarlist file.
;;  
;    path='D:\ISEIS\Data\sub_rslc\'
;    outfile= 'D:\ISEIS\Data\sub_rslc\sarlist.txt'
;    plistfile= 'D:\ISEIS\Data\sub_rslc\plist.dat'
;    suffix= '.rslc'
;    result= TLI_SARLIST(path, suffix, outfile=outfile)
;    PRINT, 'Sarlist file written successfully!'
;;  
;  ;- Find PSs.
;  
;    sarlist=outfile
;    samples= 1000
;    lines= 5000
;    fc=1
;    thr_da= 0.57
;    thr_amp= 20
;    result= TLI_PSSELECT(sarlist, samples, lines, $
;                 float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
;                 outfile=plistfile, thr_da=thr_da, thr_amp=thr_amp)
;    PRINT, 'PSs file written successfully'
;    
;  ;- Display result.
;    
;    plist= COMPLEXARR(TLI_PNUMBER(plistfile))
;    OPENR, lun, plistfile,/GET_LUN
;    READU, lun, plist
;    FREE_LUN, lun
;    
;    tempmaster=''
;    OPENR, lun, sarlist,/GET_LUN
;    READF, lun, tempmaster
;    FREE_LUN, lun
;    pwr= ABS(OPENSLC(tempmaster,columns=1000,lines=5000,data_type='FCOMPLEX'))
;    scale= 1
;    sz=SIZE(pwr,/DIMENSIONS)
;    pwr= CONGRID(pwr,sz[0]*scale, sz[1]*scale/5)
;  ;  pwr= ROTATE(pwr, 5)
;    ps_index_s= REAL_PART(plist)*scale
;    ps_index_l= IMAGINARY(plist)*scale
;    WINDOW, xpos=0, ypos=0, xsize=sz[0]*scale, ysize=sz[1]*scale/5,0
;;    TVSCL, linear2(pwr)
;    TV, pwr
;    PLOTS, ps_index_s, ps_index_l/5, psym=1, symsize=1, COLOR=200,/DEVICE






;;  ;- Generate a sarlist file.
;;  
    path='F:\Qingzang_envisat\MagNorm\MultiLook\'
    outfile= 'F:\Qingzang_envisat\MagNorm\MultiLook\sarlist'
    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
    suffix= '.img'
;    result= TLI_SARLIST(path, suffix, outfile=outfile)
    PRINT, '**************************************'
    PRINT, '* Sarlist file written successfully! *'
    PRINT, '**************************************'
;;  
;  ;- Find PSs.
;  
    sarlist='F:\TSX-HK\PSI_CUHK\sarlist.txt'
    samples= 2679
    lines= 1471
    float=1
    swap_endian=0
    outfile= 'F:\Qingzang_envisat\MagNorm\MultiLook\plist'
    thr_da= 0.25
    thr_amp= 1
;    result= TLI_PSSELECT(sarlist, samples, lines,$
;                  float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
;                  outfile=outfile, thr_da=thr_da, thr_amp=thr_amp)
    PRINT, '**************************************'
    PRINT, '*   PSs file written successfully    *'
    PRINT, '**************************************'
    
  ;- Display result.
  
    plist= COMPLEXARR(TLI_PNUMBER(plistfile))
    OPENR, lun, plistfile,/GET_LUN
    READU, lun, plist;点坐标文件
    FREE_LUN, lun
    
    tempmaster=''
    OPENR, lun, sarlist,/GET_LUN
    READF, lun, tempmaster
    FREE_LUN, lun
    
    pwr= COMPLEXARR(samples, lines)
    OPENR, lun, tempmaster
    READU, lun, pwr
    FREE_LUN, lun
    pwr= ALOG(ABS(pwr))
;    pwr= ABS(OPENSLC(tempmaster,columns=3500,lines=3500,data_type='SCOMPLEX',/swap_endian));底图
    scale= 0.5
    sz=SIZE(pwr,/DIMENSIONS)
    pwr= CONGRID(pwr,sz[0]*scale, sz[1]*scale)
  ;  pwr= ROTATE(pwr, 5)
    ps_index_s= REAL_PART(plist)*scale
    ps_index_l= IMAGINARY(plist)*scale
    WINDOW, xpos=0, ypos=0, xsize=sz[0]*scale, ysize=sz[1]*scale,0 
;    TVSCL, linear2(pwr)
    TVSCL, pwr
    wait, 3
    PLOTS, ps_index_s, ps_index_l, psym=1, symsize=1, COLOR=200,/DEVICE
END