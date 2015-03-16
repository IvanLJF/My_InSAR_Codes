;-
;- Simulate phase to indicate the correlation between pcc and phase_stability
;-
PRO TLI_SIM_PCC_RANDOM

  workpath='/mnt/software/myfiles/Software/experiment/HPA/sim'
  IF !D.NAME EQ 'WIN' THEN BEGIN
    workpath=TLI_DIRW2L(workpath,/REVERSE)
  ENDIF
  workpath=workpath+PATH_SEP()
  file=workpath+'PCC_phase_stability'
  logfile=workpath+'log.txt'
  OPENW, loglun, logfile,/GET_LUN
  
  ; First simulate the figure plotted in the paper.
  phi_std_s= 0.05 ; STD Start
  phi_std_e= 0.8  ; STD End
;  phi_interval=0.05 ; STD interval
  steps=5000
  IF NOT KEYWORD_SET(steps) THEN steps= (phi_std_e-phi_std_s)/phi_interval
  IF NOT KEYWORD_SET(phi_interval) THEN phi_interval= (phi_std_e-phi_std_s)/steps
  result=DBLARR(2, steps);[phi_std, PCC_mean, PCC_std]
  result[0,*]=phi_std_s+DINDGEN(steps)*phi_interval
  nintf=33
  
  
  n_std_ref=!PI*(0.05)
  r_part= RANDOMN(seed, nintf)*n_std_ref
  i_part= RANDOMN(seed, nintf)*n_std_ref
  n= COMPLEX(r_part,i_part)
  z= 1+n
  phi_ref= ATAN(n,/PHASE)
  Print, STDDEV(phi_ref)
  
  corrs=DBLARR(5000,steps)
  IF 1 THEN BEGIN
    FOR i=0, steps-1 DO BEGIN
      ;      Print, i, steps-1
      phi_std=phi_std_s+phi_interval*i
      ; Simulate Phase
      r_part=RANDOMN(seed, 5000D *nintf)*(phi_std)
      i_part=RANDOMN(seed, 5000D *nintf)*(phi_std)
      n=COMPLEX(r_part,i_part)
      z=1+n
      phi=ATAN(z,/PHASE)
      phi_std_i=STDDEV(phi)
      result[1,i]=phi_std_i
      
      print, i, steps-1, phi_std_i
      IF 0 THEN BEGIN ; Simulate the correlation
        FOR j=0, 4999 DO BEGIN
        
          r_part_n=RANDOMN(seed, nintf)*(phi_std)
          i_part_n=RANDOMN(seed, nintf)*(phi_std)
          n_n=COMPLEX(r_part_n, i_part_n) ; Noise
          z_n=1+n_n
          phi_n=ATAN(z_n,/PHASE) ; Noise
          phi_cal= TLI_WRAP_PHASE(phi_ref+phi_n)
          
          corr=CORRELATE(phi_ref, phi_cal)
          corrs[j,i]=corr
        ENDFOR
      ENDIF
    ENDFOR
;    OPENW, lun, file,/GET_LUN
;    WRITEU, lun, corrs
;    FREE_LUN, lun
  ENDIF
  corrs=TLI_READDATA(file, samples=5000, format='DOUBLE')
  DEVICE, DECOMPOSED=1
  !P.Background='FFFFFF'XL
  !P.COLOR='000000'XL
  x=result[0,*]
  std_phi=result[1,*]
  Plot, x, std_phi, xrange=[0,0.8], yrange=[-1, 1], psym=2, symsize=0.3
  Oplot, x, std_phi
  
  i=0
  FOR i=0, steps-1 DO BEGIN
;    x= (phi_std_s+phi_interval*i)*(DBLARR(5000)+1)
;    y= corrs[*, i]
;    OPlot, x, y
    y=corrs[*,i]
    v_plot= HISTOGRAM(y,binsize=0.01)
    STOP
  ENDFOR
  
  
  FREE_LUN, loglun
  
  
  STOP
END