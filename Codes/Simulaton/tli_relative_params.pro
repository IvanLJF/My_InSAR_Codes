@tli_def_params
@tli_phase_increment
PRO TLI_RELATIVE_PARAMS
  ; Three algorithms have to be used for comparision purpose.
  ; The first one is PSD.
  ; The second one is LS estimate.
  ; The third one is phase gradient based algorithm.

  ; Pre-defined params.
  workpath='/mnt/data_tli/ForExperiment/Lemon_gg/TSX_PS_SH_OP'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'Relative_def_params'
  resultpath=resultpath+PATH_SEP()
  basepath=resultpath+'base'   ; Generated using base_all.sh
  sarlistfile_GAMMA=workpath+'SLC_tab'
  itabfile=workpath+'itab'
  plistfile_GAMMA=workpath+'pt'
  pdifffile_GAMMA=workpath+'pdiff0'
  baselistfile=workpath+'base.list'
  ; intermediate files.
  sarlistfile=resultpath+'sarlist'
  plistfile=resultpath+'plist'
  pbasefile=resultpath+'pbase'
  plafile=resultpath+'pla'
  logfile=resultpath+'log.txt'
  simphasefile=resultpath+'simphase'
  ;  deg=50D ; noise level
  deg=20D
  ;  deg=10D
  ;  deg=0D
  
  
  FILE_COPY, workpath+'itab_backup', workpath+'itab',/overwrite
  ;------------------------------------------------------------------------------------------------------------------------
  ; File conversion
  TLI_GAMMA2MYFORMAT_PLIST, plistfile_GAMMA, plistfile
  TLI_GAMMA2MYFORMAT_SARLIST, sarlistfile_GAMMA, sarlistfile
  
  ;--------------------------------------------------------------------------------------------------------------------------
  ; Calculate the temporal and spatial baselines for each point.
  TLI_GAMMA_BP_LA_FUN, plistfile, itabfile, sarlistfile, basepath, pbasefile, plafile,gamma=gamma,force=force
  ;-----------------------------------------------------------------------------------------------------------------------
  ; Read data
  npt=TLI_PNUMBER(plistfile)
  itab_str=TLI_READMYFILES(itabfile, type='itab')
  plist=TLI_READMYFILES(plistfile,type='plist')
  pbase=TLI_READDATA(pbasefile, samples=npt, format='DOUBLE')
  pla=TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  pdiff=TLI_READDATA(pdifffile_GAMMA, samples=npt, format='FCOMPLEX',/swap_endian)
  def_params= TLI_DEF_PARAMS(sarlistfile, itabfile, pbase=pbase, pla=pla, pind=0, finfo=finfo, plist=plist)
  
  ;------------------------------------------------------------------------------------------------------------------------
  sim_flag=1
  ; First, simulate data series.
  IF FILE_TEST(simphasefile) THEN BEGIN
    phase_inc=TLI_READDATA(simphasefile, lines=1, format='double')
    IF phase_inc[0] EQ deg THEN sim_flag=0
    phase_inc=phase_inc[1:*]
  ENDIF
  
  IF sim_flag EQ 1 THEN BEGIN
    ; Specify some parameters.
    ; Assume that the relative subsidence rate and the relative DEM error are 1 mm/yr and 5 m, respectively.
    ; And the reference phase are diff phase of the first point.
    dv=10D
    ddh=30D
    
    ref_phi=ATAN(pdiff[0, *],/PHASE)
    
    ; Simulate the phase increments.
    phase_inc=TLI_PHASE_INCREMENT(def_params, dv, ddh,phi_hgt=phi_hgt, phi_v=phi_v, phi_w=phi_w)
    
    ; Calculate the correlation
    cal_phi=ref_phi+phase_inc
    c=CORRELATE(ref_phi, cal_phi)
    Print,'Correlation between reference phase and the adj. phase.', c
    
    cal_phi_w=TLI_WRAP_PHASE(cal_phi)
    c=correlate(ref_phi, cal_phi_w)
    Print, 'Correlation between ref. phase and the wrapped phase.', c
    
    IF 1 THEN BEGIN
      ; Add some noise to test the algorithm's robustness.
    
      TLI_LOG, logfile, 'Add '+STRCOMPRESS(deg,/REMOVE_ALL)+' degrees.'
      noise=RANDOMN(seed, N_ELEMENTS(phase_inc))
      noise=noise*DEGREE2RADIANS(deg)
      phase_inc=phase_inc+noise
    ENDIF
    TLI_WRITE, simphasefile, [deg, phase_inc]
  ENDIF
  
  ;---------------------------------------------------------------------------------------------------------------
  ; Select interferograms.
  dv_thresh=10D
  ddh_thresh=30D
  ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
    dv_thresh=dv_thresh, ddh_thresh=ddh_thresh)
  IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
  
  base=TLI_READTXT(baselistfile, /easy)
  temp=LONG(base[*, ind])
  TLI_WRITE, workpath+'base_0.list',temp,/txt
  temp=phase_inc[ind]
  temp=[TRANSPOSE(ind), TRANSPOSE(temp)]
  TLI_WRITE, workpath+'simphase_0.txt',temp,/txt
  
  ;-----------------------------------------------------------------------------------------------------
  ; Second, calculate the deformation params using simulated data series.
  dvddh=TLI_DVDDH(def_params,TRANSPOSE(TLI_WRAP_PHASE(phase_inc)),/ls_simple,ind=ind)
  TLI_LOG, logfile, 'The result of LS estimation (dv, ddh, coh):'+STRJOIN(dvddh, ':'),/prt
  
  nintf_all=FILE_LINES(itabfile)
  
  
  ;-------------------------------------------------------------------------------------------------------------------
  ; Loops
  goon=1
  counter=1
  WHILE goon DO BEGIN
    dv_thresh=dv_thresh-dvddh[0]
    ddh_thresh=ddh_thresh-dvddh[1]
    ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
      dv_thresh=dv_thresh, ddh_thresh=ddh_thresh)
    IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
    
    ;-----------------------------------------------------------------------------------------------------
    ; Second, calculate the deformation params using simulated data series.
    temp=TLI_PHASE_INCREMENT(def_params, dvddh[0], dvddh[1],phi_hgt=phi_hgt, phi_v=phi_v, phi_w=phi_w)
    phase_inc=phase_inc-temp
    
    base=TLI_READTXT(baselistfile, /easy)
    temp=LONG(base[*, ind])
    TLI_WRITE, workpath+'base_'+STRCOMPRESS(counter,/REMOVE_ALL)+'.list',temp,/txt    
    temp=phase_inc[ind]
    temp=[TRANSPOSE(ind), TRANSPOSE(temp)]
    TLI_WRITE, workpath+'simphase_'+STRCOMPRESS(counter,/REMOVE_ALL)+'.txt',temp,/txt
    
    phase_inc=TLI_WRAP_PHASE(phase_inc)
    dvddh=TLI_DVDDH(def_params,TRANSPOSE(TLI_WRAP_PHASE(phase_inc)),/ls_simple,ind=ind)
    TLI_LOG, logfile, 'The result of LS estimation (dv, ddh, coh):'+STRJOIN(dvddh, ':'),/prt
    
    dv_err=ABS(dv_thresh-dvddh[0])
    ddh_err=ABS(ddh_thresh-dvddh[1])
    
    IF dv_err LE 0.001 OR ddh_err LE 0.001 THEN BEGIN
      goon=0
      Print, 'Threshold convergence encountered.'
      CONTINUE
    ENDIF
    
    IF N_ELEMENTS(ind) EQ nintf_all THEN BEGIN
      goon=0
      Print, 'Interferogram number convergence encountered.'
      CONTINUE
    ENDIF
    counter=counter+1
  ENDWHILE
  
  
;
;  IF 1 THEN BEGIN
;
;    IF 0 THEN BEGIN ; STUN, Kampes
;      dvddh=TLI_DVDDH(def_params,TRANSPOSE(TLI_WRAP_PHASE(phase_inc)),/lamda)
;
;
;    ENDIF
;
;    IF 1 THEN BEGIN   ; LS estimation.
;      dvddh=TLI_DVDDH(def_params,TRANSPOSE(TLI_WRAP_PHASE(phase_inc)),/ls_simple,ind=ind)
;      TLI_LOG, logfile, 'The result of LS estimation (dv, ddh, coh):'+STRJOIN(dvddh, ':'),/prt
;      STOP
;    ENDIF
;    IF 0 THEN BEGIN   ; LS estimation.
;      dvddh=TLI_DVDDH(def_params,TRANSPOSE(TLI_WRAP_PHASE(phase_inc)),/ls_robust)
;      TLI_LOG, logfile, 'The result of LS robust estimation (dv, ddh, coh):'+STRJOIN(dvddh, ':'),/prt
;    ENDIF
;
;    IF 1 THEN BEGIN
;      dv_range=[-20,20];1
;      ddh_range=[-100,100];5
;      dv_iter=10
;      ddh_iter=10
;      dv_acc=0.001
;      ddh_acc=0.001
;      dvddh=TLI_DVDDH(def_params, TRANSPOSE(phase_inc), /psd, grd=grd, $
;        dv_range=dv_range, ddh_range=ddh_range, dv_iter=dv_iter, ddh_iter=ddh_iter, dv_acc=dv_acc, ddh_acc=ddh_acc)
;      TLI_LOG, logfile, 'The result of PSD estimation (dv, ddh, coh):'+STRJOIN(dvddh, ':')
;
;      TLI_LOG, logfile, ''
;      TLI_LOG, logfile, 'Params for PSD:'
;      TLI_LOG, logfile, 'dv_range:'+STRJOIN(STRING(dv_range))
;      TLI_LOG, logfile, 'ddh_range:'+STRJOIN(STRING(ddh_range))
;      TLI_LOG, logfile, 'dv_iter'+STRING(dv_iter)
;      TLI_LOG, logfile, 'dv_acc'+STRING(dv_acc)
;      TLI_LOG, logfile, 'ddh_acc'+STRING(ddh_acc)
;      TLI_LOG, logfile, 'Original result:'+STRING(dv)+STRING(ddh),/prt
;      TLI_LOG, logfile, 'Estimated result:'+STRJOIN(STRING(dvddh)),/prt
;      TLI_LOG, logfile, ''
;    ENDIF
END