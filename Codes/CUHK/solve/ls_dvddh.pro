PRO LS_DVDDH

  COMPILE_OPT idl2

  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/sarlist_Linux'
    pdifffile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pdiff0'
    plistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/plist'
    itabfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/itab'
    arcsfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pbase'
    dvddhfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/dvddh'
    v_file='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/v'
    dh_file='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/dh'
  ENDIF ELSE BEGIN
    sarlistfile= 'D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\sarlist_Win'
    pdifffile='D:\myfiles\Software\TSX_PS_Tianjin\pdiff0'
    plistfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\plist'
    itabfile='D:\myfiles\Software\TSX_PS_Tianjin\itab'
    arcsfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\arcs'
    pbasefile='D:\myfiles\Software\TSX_PS_Tianjin\pbase'
    dvddhfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\dvddh'
    v_file='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\v'
    dh_file='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\dh'
  ENDELSE

  plistlines= TLI_PNUMBER(plistfile)
  arcs= TLI_READDATA(arcsfile, 3, format='FCOMPLEX')
  dvddh= TLI_READDATA(dvddhfile, 3, format='DOUBLE')
  plist= TLI_READDATA(plistfile, 1, format='FCOMPLEX')
  dims= (SIZE(arcs,/DIMENSIONS))[1]
  coefs= BYTARR(dims, dims)
  
  start_ind= REAL_PART(arcs[2, *])
  end_ind= IMAGINARY(arcs[2, *])
  
  ; 构建系数阵
  coefs[start_ind, INDGEN(dims)] = -1
  coefs[end_ind, INDGEN(dims)] = 1
  
  ; 平差
  ;coefs= IMSL_INV(TRANSPOSE(coefs)*coefs)*TRANSPOSE(coefs)
;  v= coefs##dvddh[0, *]
;  dh= coefs##dvddh[1, *]
  dv= dvddh[0, *]
  ddh= dvddh[1, *]
  v= LA_LEAST_SQUARES(coefs, dv)
  dh= LA_LEAST_SQUARES(coefs, ddh)
  
  
  OPENW, lun, v_file,/GET_LUN
  WRITEU, lun, v
  FREE_LUN, lun
  
  OPENW, lun, dh_file,/GET_LUN
  WRITEU, lun, dh
  FREE_LUN, lun
  
  
  
  

END