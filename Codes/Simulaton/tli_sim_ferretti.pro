;-
;- Use the simulation method provided by Ferretti et. al.
;-
PRO TLI_SIM_FERRETTI

  workpath='/mnt/data_tli/ForExperiment/Lemon_gg'
  workpath=workpath+PATH_SEP()
  file=workpath+'Ferretti2001fig1'
  ; First simulate the figure plotted in the paper.
  phi_std_s= 0.05 ; STD Start
  phi_std_e= 0.8  ; STD End
  phi_interval=0.05 ; STD interval
  steps= (phi_std_e-phi_std_s)/phi_interval
  result=DBLARR(4, steps);[phi_std, DA_mean, DA_std]
  result[0,*]=phi_std_s+DINDGEN(steps)*phi_interval
  nintf=33
  DAs=DBLARR(5000)
;  phis=DBLARR(5000,nintf)
;  phis=DBLARR(5000)
  IF 0 THEN BEGIN
  FOR i=0, steps-1 DO BEGIN
  
    phi_std=phi_std_s+phi_interval*i
    ; Simulate Phase
    r_part=RANDOMN(seed, 5000D *nintf)*(phi_std)
    i_part=RANDOMN(seed, 5000D *nintf)*(phi_std)
;    r_part=RANDOMN(seed, 5000D *nintf)*SQRT(phi_std)
;    i_part=RANDOMN(seed, 5000D *nintf)*SQRT(phi_std)
    n=COMPLEX(r_part,i_part)
    z=1+n
    phi=ATAN(z,/PHASE)
    result[1,i]=STDDEV(phi)
    
;    print, i, steps-1, phi_std
    FOR j=0, 4999 DO BEGIN
    
      r_part=RANDOMN(seed, nintf)*(phi_std)
      i_part=RANDOMN(seed, nintf)*(phi_std)
;      r_part=RANDOMN(seed, nintf)*SQRT(phi_std)
;      i_part=RANDOMN(seed, nintf)*SQRT(phi_std)
      
      n=COMPLEX(r_part, i_part) ; Noise
      
      z=1+n
      
      amp= ABS(z)
      amp_mean=MEAN(amp)
      amp_std= STDDEV(amp)
      DA=amp_std/amp_mean
      DAs[j]=DA
    ENDFOR
    result[2:*,i]=[ MEAN(DAs), STDDEV(DAs)]
    print, i, steps-1, phi_std, result[1,i]
  ENDFOR
  OPENW, lun, file,/GET_LUN
  WRITEU, lun, result
  FREE_LUN, lun
  ENDIF
  result=TLI_READDATA(file, samples=4, format='DOUBLE') ;[x, std_phi, mean_da, std_da]
  DEVICE, DECOMPOSED=1
  !P.Background='FFFFFF'XL
  !P.COLOR='000000'XL
  x=result[0,*]
  std_phi=result[1,*]
  mean_da=result[2,*]
  std_da=result[3,*]
  
  WINDOW, xsize=800, ysize=640
  Plot, x, std_phi, xrange=[0,0.8], yrange=[0, 1], psym=2, symsize=0.3
  Oplot, x, std_phi
  OPlot, x, mean_da
  OPLOTERR, x, mean_da,std_da
  
  
END