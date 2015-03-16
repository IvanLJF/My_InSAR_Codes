; Select spatially correlated points.
; T. LI @ ISEIS, 20130524.
PRO TLI_SCP

  COMPILE_OPT idl2
  workpath='D:\myfiles\Software\experiment\TSX_PS_HK_Airport'
  
  workpath=workpath+PATH_SEP()
  itabfile=workpath+'itab'
  sarlistfile=workpath+'SLC_tab_win'
  finfo=TLI_LOAD_MPAR(sarlistfile,itabfile)
  pscdafile=workpath+'PSC_DA'
  logfile=workpath+'Spatially_corr_points.log'
  loglun=TLI_OPENLOG(logfile)
  PrintF, loglun, 'Start at: '+STRJOIN(STRCOMPRESS(TLI_TIME()))
  
  ;----------------------------find points------------------
  ; Using DA
  DA=0.45
  thr_amp=1
  Result= TLI_PSSELECT( sarlistfile, finfo.samples, finfo.lines,$
    /sc,/swap_endian,outfile=pscdafile, thr_da=DA, thr_amp=thr_amp)
  npt=TLI_PNUMBER(pscdafile)
  PrintF, loglun, ''
  PrintF, loglun, 'Select PSC using (DA, amp):('+STRING(DA)+','+STRING(thr_amp)+')'
  PrintF, loglun, STRING(npt)
  ; Using PCC
  ; Extract the points with amp>
  
  ;---------------------------------------------------------
    
  ;------------------------Networking----------------------
    
  ;--------------------------------------------------------
    
  ;------------------------Linear-------------------------
    
  ;-------------------------------------------------------
    
  ;----------------------RegionGrowing---------------------
    
  ;----------------------------------------------------------
    
  ;----------------------Residuals---------------------------
    
  ;----------------------------------------------------------
    
  FREE_LUN, lun
END