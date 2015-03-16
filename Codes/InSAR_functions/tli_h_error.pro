;
; Analyze height error with reference to orbital error.
;
; Written by :
;   T.LI @ Sasmac, 20141128.
;
PRO TLI_H_ERROR
  
  workpath='/mnt/data_tli/ForExperiment/int_tsx_tianjin/1000'+PATH_SEP()
  parfile=workpath+'20090407.rslc.par'
  finfo=TLI_LOAD_SLC_PAR(parfile)
  
  baseperpfile=workpath+'20090407-20090418.base.perp.txt'
  baseperp=TLI_READ_BASE_PERP(baseperpfile)
  
  bperp=MEAN(baseperp.bperp)
  la=MEAN(baseperp.look_angle)
  
  lamda=TLI_C()/finfo.radar_frequency
  
  r=finfo.near_range_slc
  
  k_dh=-4*(!PI)/lamda*bperp/(r*sin(DEGREE2RADIANS(la)))
  
  dphi=1.263
  
  dh=DOUBLE(dphi)/k_dh
  
  Print, 'dphi is:', dphi
  Print, 'dh should be:', dh
END