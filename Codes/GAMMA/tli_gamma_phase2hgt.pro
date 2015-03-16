PRO TLI_GAMMA_PHASE2HGT
  workpath='H:\ForExperiment\int_tsx_tianjin\1000_backup'
  workpath=workpath+PATH_SEP()
  
  baseperpfile=workpath+'20090407-20090418.base.perp.txt'
  masterpar=workpath+'20090407.rslc.par'
  
  phasefile=workpath+'20090407-20090418.flt.filt.unw'
  finfo=TLI_LOAD_SLC_PAR(masterpar)
  phase=TLI_READDATA(phasefile, samples=finfo.range_samples, format='float',/SWAP_ENDIAN)
  
  hgtfile=workpath+'20090407-20090418.hgt'
  hgt=TLI_READDATA(hgtfile, samples=finfo.range_samples, format='float',/SWAP_ENDIAN)
  
  ;  ref_coor=[500, 500]
  ;  adj_coor=[501, 500]
  coors_x=REBIN(FINDGEN(finfo.range_samples), finfo.range_samples, finfo.azimuth_lines)
  coors_y=REBIN(FINDGEN(finfo.azimuth_lines), finfo.range_samples, finfo.azimuth_lines)
  npt=finfo.range_samples*finfo.azimuth_lines
  rps=finfo.range_pixel_spacing
  
  wavelength=TLI_C()/finfo.radar_frequency
  ref_r=finfo.near_range_slc+rps*coors_x
  ref_r=REBIN(ref_r, finfo.range_samples, finfo.azimuth_lines)
  
  ; Get baseline information
  nlines= FILE_LINES(baseperpfile)
  OPENR, lun, baseperpfile,/GET_LUN  
  FOR j=0, 11 DO BEGIN
    temp=' '
    READF, lun, temp
  ENDFOR
  data= DBLARR(9, nlines-12-5)
  READF, lun, data
  FREE_LUN, lun
  x= data[0, *]
  y= data[1, *]
  la= data[5, *]
  bp= data[7, *] 
  coor_x_reform=REFORM(coors_x, npt, 1)
  coor_y_reform=REFORM(coors_y, npt, 1) 
  bp=TLI_POLYFIT2D(x, y, bp, coor_x_reform, coor_y_reform, degree=1)
  la=TLI_POLYFIT2D(x, y, la, coor_x_reform, coor_y_reform, degree=1)
  sinla=SIN(la)
  
  coefs_dh=-4*(!PI) / (wavelength *ref_r * sinla) *bp
  
  hgt_real=phase/coefs_dh
  
  STOP
  
END