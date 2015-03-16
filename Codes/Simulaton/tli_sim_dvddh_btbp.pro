;
; Simulate the phase increment using the given dv, ddh, bt, bp.
;
PRO TLI_SIM_DVDDH_BTBP

  ; Pre-defined params.
  workpath='/mnt/data_tli/ForExperiment/Lemon_gg/TSX_PS_SH_OP/'
  dv_range=[0, 1]    & ndv= 1000
  ddh_range=[0, 100]  & nddh=1000
  IF 0 THEN BEGIN
    Tbase= 11D
    Bperp= 0.45D
  ENDIF ELSE BEGIN
    tbase=649D
    bperp=365.38D
  ENDELSE
  
  dv=dv_range[0]+FINDGEN(ndv)*(dv_range[1]-dv_range[0])/ndv
  ddh=ddh_range[0]+FINDGEN(nddh)*(ddh_range[1]-ddh_range[0])/nddh
  all_dvddh=INDEXARR(x=dv, y=ddh)
  
  
  resultpath=workpath+'Relative_def_params'
  resultpath=resultpath+PATH_SEP()
  basepath=resultpath+'base'   ; Generated using base_all.sh
  sarlistfile_GAMMA=workpath+'SLC_tab'
  itabfile=workpath+'itab'
  plistfile_GAMMA=workpath+'pt'
  pdifffile_GAMMA=workpath+'pdiff0'
  
  ; intermediate files.
  sarlistfile=resultpath+'sarlist'
  plistfile=resultpath+'plist'
  pbasefile=resultpath+'pbase'
  plafile=resultpath+'pla'
  logfile=resultpath+'log.txt'
  
  ; Read data
  npt=TLI_PNUMBER(plistfile)
  itab_str=TLI_READMYFILES(itabfile, type='itab')
  plist=TLI_READMYFILES(plistfile,type='plist')
  pbase=TLI_READDATA(pbasefile, samples=npt, format='DOUBLE')
  pla=TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  pdiff=TLI_READDATA(pdifffile_GAMMA, samples=npt, format='FCOMPLEX',/swap_endian)
  ;----------------------------------------------------------------------------------------
  ; Simulate the phase increments.
  pind=0
  def_params= TLI_DEF_PARAMS(sarlistfile, itabfile, pbase=pbase, pla=pla, pind=pind, finfo=finfo, plist=plist)
  
  ; Calculate the phase values.
  ref_r= def_params.ref_r
  
  wavelength= def_params.wavelength
  sinla= SIN(def_params.pla)
  K1= -4*(!PI)/(wavelength*ref_r*sinla)
  K2= -4*(!PI)/(wavelength*1000)
  coefs_v= K2*Tbase
  coefs_dh= K1[0]*Bperp
  result=coefs_v*REAL_PART(all_dvddh)+coefs_dh*IMAGINARY(all_dvddh)
  result=FLOAT(TLI_WRAP_PHASE(result))
  result=ROTATE(result, 7)
  
  resultfile=resultpath+'dvddh_vs_bpbt'+STRCOMPRESS(tbase,/REMOVE_ALL)+'_'+STRCOMPRESS(bperp,/REMOVE_ALL)
  TLI_WRITE, resultfile, result
  
  xsize=800 & ysize=800
  result=CONGRID(result, xsize, ysize)
  WINDOW,/free, xsize=xsize, ysize=ysize
  TVSCL, result
  
END