PRO TEST_ASSESS_INT_DEM_QUALITY

  ;--------------------------------------------------
  ; Int DEM of Shanghai Full Scene.
  IF 0 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/int_ERS_Shanghai/int_ERS_shanghai_precise_orb'
    workpath=workpath+PATH_SEP()
    
    mslcfile=workpath+'19960326.rslc'
    int_demfile=workpath+'19960325-19960326.hgt.utm'
    ref_demfile=workpath+'dem_seg'
    errfile=ref_demfile+'.err'
    
    ;    TLI_SLC_RANGE, mslcfile+'.par'
    ;
    ;    TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, errfile=errfile
    
    TLI_PLOT_INT_DEM, int_demfile
    TLI_PLOT_INT_DEM, ref_demfile
    TLI_PLOT_INT_DEM, errfile
  ENDIF
  
  ;--------------------------------------------------
  ; Int DEM of Shanghai without isolated lands.
  IF 0 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/int_ERS_Shanghai/int_ERS_shanghai_2000_10000'
    workpath=workpath+PATH_SEP()
    
    mslcfile=workpath+'19960325.rslc'
    int_demfile=workpath+'19960325-19960326.hgt.utm'
    ref_demfile=workpath+'dem_seg'
    errfile=ref_demfile+'.err'
    
    ;    TLI_SLC_RANGE, mslcfile+'.par'
    ;
    ;    TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, errfile=errfile
    ;
    ;    TLI_PLOT_INT_DEM, int_demfile
    ;    TLI_PLOT_INT_DEM, ref_demfile
    TLI_PLOT_INT_DEM, errfile
  ENDIF
  
  ;------------------------------------------------------
  ; Int DEM of Shanghai TSX images.  Interferometric results are bad... Can't be worse.
  IF 0 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/int_tsx_shanghai/without_water'
    workpath=workpath+PATH_SEP()
    
    mslcfile=workpath+'20100108.rslc'
    int_demfile=workpath+'20100108-20090119.hgt.utm'
    ref_demfile=workpath+'dem_seg'
    errfile=ref_demfile+'.err'
    
    TLI_SLC_RANGE, mslcfile+'.par'
    ;
    TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, errfile=errfile
    ;
    TLI_PLOT_INT_DEM, int_demfile
    TLI_PLOT_INT_DEM, ref_demfile
    TLI_PLOT_INT_DEM, errfile
  ENDIF
  
  
  ;-----------------------------------------------------------------
  ; Int DEM of Tianjin TSX images.
  IF 0 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/int_tsx_tianjin/20090429-20090510'
    workpath=workpath+PATH_SEP()
    
    mslcfile=workpath+'20090429.rslc'
    int_demfile=workpath+'20090429-20090510.hgt.utm'
    ref_demfile=workpath+'dem_seg'
    errfile=ref_demfile+'.err'
    
    TLI_SLC_RANGE, mslcfile+'.par'
    ;
    TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, errfile=errfile
    ;
    TLI_PLOT_INT_DEM, int_demfile
    TLI_PLOT_INT_DEM, ref_demfile
    TLI_PLOT_INT_DEM, errfile
    
  ENDIF
  
  ;------------------------------------------------------------------------------
  ; Int DEM of TanDEM
  IF 1 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/TanDEM'
    workpath=workpath+PATH_SEP()
    
    mslcfile=workpath+'201202281.rslc'
    int_demfile=workpath+'201202281-201202282.hgt.utm'
    ref_demfile=workpath+'dem_seg'
    errfile=ref_demfile+'.err'
    
    TLI_SLC_RANGE, mslcfile+'.par'
    ;
    TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, errfile=errfile
    ;
    TLI_PLOT_INT_DEM, int_demfile
    TLI_PLOT_INT_DEM, ref_demfile
    TLI_PLOT_INT_DEM, errfile
  ENDIF
  
END