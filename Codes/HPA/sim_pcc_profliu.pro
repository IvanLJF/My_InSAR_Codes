;- Simulate PCC using the ideas provided by prof. liu.
;-
;- Written by
;-  T.LI @ ISEIS
;-  20130731
; History:
;   Move tli_phase_increment to the folder ../Phase_Grd_Sub_Rate. A more easy way to calculate phase increment is created.
;   T.LI @ ISEIS, 20131224

PRO SIM_PCC_PROFLIU, wrap=wrap

  workpath='/mnt/software/myfiles/Software/experiment/HPA/sim'
  IF !D.NAME EQ 'WIN' THEN BEGIN
    workpath=TLI_DIRW2L(workpath,/REVERSE)
  ENDIF
  workpath=workpath+PATH_SEP()
  file=workpath+'PCC_phase_stability'+TLI_TIME(/str)
  logfile=workpath+'log.txt'
  
  TLI_LOG, logfile, '************************'
  TLI_LOG,logfile, 'SIM PCC: Task starts at:'+TLI_TIME(/str)
  TLI_LOG, logfile, ''
  nintf=40
  dphi_std_start=0.0
  dphi_std_end=1.0
  dphi_std_number=50
  dphi_std_int=(dphi_std_end-dphi_std_start)/(dphi_std_number-1)  ; interval
  n_sim=5000   ;Number of simulations for each dphi_std
  wrap=1
  IF KEYWORD_SET(wrap) THEN TLI_LOG, logfile, 'The phase will be wrapped.'
  
  pslcfile=workpath+'lel1pslc'
  plistfile=workpath+'plistupdate'
  pdifffile=workpath+'lel1pdiff'
  plafile=workpath+'plaupdate'
  pbasefile=workpath+'pbaseupdate'
  sarlistfile=workpath+'sarlist_WIN'
  itabfile=workpath+'itab'
  
  npt=TLI_PNUMBER(plistfile)
  nintf=FILE_LINES(itabfile)
  ; First extract the reference point phase.
  ; Use the index of 0
  ref_coef=0.7D
  ind=0
  ref_slc=TLI_EXTRACT_PTINFO(ind, pdifffile, samples=npt,format='FCOMPLEX')
  ref_phi=ATAN(ref_slc,/phase)*ref_coef
  TLI_LOG, logfile, 'The master phase is multiplied by:'+STRING(ref_coef)
  TLI_LOG, logfile, 'The master phase SD is:'+STRING(STDDEV(ref_phi))
  
  
  Print,  'The master phase SD is:'+STRING(STDDEV(ref_phi))
  
  ; Second simulate the phase for the adjacent point.
  dv=-3.5
  ddh=6.7
  pla=TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  pbase=TLI_READDATA(pbasefile, samples=npt, format='DOUBLE')
  phi_inc=TLI_PHASE_INCREMENT(sarlistfile, itabfile, ind, dv, ddh,pla, pbase)
  TLI_LOG, logfile, 'dv is:'+STRING(dv)
  TLI_LOG, logfile, 'ddh is:'+STRING(ddh)
  adj_phi=ref_phi+phi_inc
  adj_phi_max=MAX(adj_phi, min=adj_phi_min)
  Print, 'Max adj_phi:', adj_phi_max
  Print, 'Min adj_phi:', adj_phi_min
  
  ; Add noise for the reference point.
  IF 1 THEN BEGIN
    coef_noise=0.9
    ref_noise=RANDOMN(seed, nintf)*coef_noise
    ref_phi=ref_phi+ref_noise
    IF KEYWORD_SET(wrap) THEN ref_phi=TLI_WRAP_PHASE(ref_phi)
    TLI_LOG, logfile, 'The noise for the ref. point is multiplied by:'+STRING(coef_noise)
  ENDIF
  
  ; Add noise for the adjacent point. And calculate PCC.
  result=DBLARR(3, dphi_std_number)
  FOR i=0, dphi_std_number -1 DO BEGIN
    Print, i, '/', STRING(dphi_std_number-1)
    dphi_std_i=dphi_std_start+dphi_std_int*i
    corr_i=DBLARR(n_sim)
    FOR j=0, n_sim-1 DO BEGIN
      adj_noise=RANDOMN(seed,nintf)*dphi_std_i
      adj_phi_j=adj_phi+adj_noise
      IF KEYWORD_SET(wrap) THEN adj_phi_j=TLI_WRAP_PHASE(adj_phi_j)
      corr=CORRELATE(ref_phi, adj_phi_j)
      corr_i[j]=corr
    ENDFOR
    corr_i_mean=MEAN(corr_i)
    corr_i_std=STDDEV(corr_i)
    result[*, i]=[dphi_std_i, corr_i_mean, corr_i_std]
  ENDFOR
  TLI_WRITE, file, result
  
  ; Third plot the result
  ;  file=workpath+'PCC_phase_stability2013_7_29_2_25_21'
  results= TLI_READDATA(file, samples=3, format='DOUBLE')
  x= results[0, *]  ; Std(diff)
  y= results[1, *]
  y_err= results[2, *]
  
;  temp=plot(x,y, yerror=y_err,$
;    xrange=[-0.05, dphi_std_end+0.05],yrange=[0,1], $
;    ;      psym=1,xtitle='SD of Phase Difference (rad)!C'+xnames[i],ytitle='PCC',$
;    psym=1,ytitle='PCC',$  ;xtitle='!9s(Df)!C!3'+xnames[i],
;    dimensions=[800, 500], position=[0.13, 0.13, 0.95, 0.95], $
;    errorbar_capsize=0.06,noclip=0,font_size=22);, $
;  ;      title='Ref:'+STRMID(STRCOMPRESS(ref_coef,/REMOVE_ALL),0, 4)+$
;  ;      '; Ref n:'+STRMID(STRCOMPRESS(coef_noise,/REMOVE_ALL), 0,4))
;  temp.save, file+'.emf', BORDER=10, RESOLUTION=300,/TRANSPARENT
  Print,  'The master phase SD is:'+STRING(STDDEV(ref_phi))
;  wait, 1
;  temp.close
  
END