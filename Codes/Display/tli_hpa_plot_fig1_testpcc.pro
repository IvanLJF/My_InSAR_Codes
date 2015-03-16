;
; Image in Fig.1 is plotted using this pro. 
; Test pearson correlation coeficience.
@tbase_all.pro
@tli_linear_solve_cuhk.pro
PRO TLI_HPA_PLOT_FIG1_TESTPCC

  usefile=1 ; Use true files to simulate phase
  
  
  workpath='D:\myfiles\Software\experiment\TSX_PS_Tianjin'
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'+PATH_SEP()
  
  sarlistfile=workpath+'SLC_tab_win'
  itabfile=workpath+'itab'
  plistfile=hpapath+'plist'
  vdhfile=hpapath+'vdh'
  pslcfile=hpapath+'pslc'
  pdifffile=workpath+'pdiff0'
  plafile= hpapath+'pla'
  pbasefile= hpapath+'pbase'
  
  finfo= TLI_LOAD_MPAR(sarlistfile, itabfile)
  nintf= FILE_LINES(itabfile)
  npt= TLI_PNUMBER(plistfile)
  
  ; Locate reference point
  center_coor= COMPLEX(LONG(finfo.range_samples/2), LONG(finfo.azimuth_lines/2))
  plist= TLI_READDATA(plistfile,samples=1,format='FCOMPLEX')
  dis= ABS(plist-center_coor)
  dis_ind= SORT(dis)
  refind= dis_ind[10] ;****************************************************************
  calind= dis_ind[33] ;****************************************************************
  ref_coor= plist[refind]
  cal_coor= plist[calind]
  ; Simulate phase in time series
  ; Extract v&dh
  vdh= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  temp=WHERE(vdh[0,*] EQ refind)
  IF temp EQ -1 THEN BEGIN
    Message, 'ERROR! This point is of low quality.'
    ref_v=0
    ref_dh=0
  ENDIF ELSE BEGIN
    ref_v= vdh[3,temp]
    ref_dh= vdh[4,temp]
  ENDELSE
  temp= WHERE(vdh[0,*] EQ calind)
  IF temp EQ -1 THEN BEGIN
    Message, 'ERROR! Please specify another points to be calculated.'
  ENDIF
  cal_v= vdh[3,temp]
  cal_dh= vdh[4,temp]
  
  dv= cal_v-ref_v   ;---------------------------------------
  ddh= cal_dh-ref_dh
  
  dv=-0.86
  ddh=1.19
  
  pdiff= TLI_READDATA(pdifffile, samples=npt,format='FCOMPLEX',/swap_endian)
  ref_slc= pdiff[refind, *]
  ref_phi= ATAN(ref_slc, /PHASE)*0.9  ; Reference points's phase*******************************
  
  
  ; Extract params on the points.
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed light
  ref_r= finfo.near_range_slc
  pla= TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  pbase= TLI_READDATA(pbasefile, samples=npt, format='DOUBLE')
  Tbase= TBASE_ALL(sarlistfile, itabfile)
  Bperp= pbase[refind, *]
  ; Check pla. Oh, I choose to believe in it.
  wavelength=c/finfo.radar_frequency
  sinla= SIN(pla[refind])
  K1= -4*(!PI)/(wavelength*ref_r*sinla)
  K2= -4*(!PI)/(wavelength*1000)
  ;          coefs_v=REPLICATE(K2, 1, nintf);
  coefs_v= K2*Tbase
  coefs_dh= K1*Bperp
  coefs=[coefs_v, coefs_dh]
  ;  coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
  ;  result= coefs_n##dphi_i ; dv ddh
  result=[dv, ddh]
  result= TRANSPOSE(result)
  
  phi_hgt=TRANSPOSE(coefs_dh)*ddh[0]
  Print, 'Correlation between height-related phase and ref. phase:'
  Print, CORRELATE(ref_phi, phi_hgt)
  phi_l=coefs_v*dv[0]
  Print, 'Correlation between def-related phase and ref. phase:'
  Print, CORRELATE(ref_phi, phi_l)
;    result[0]=1 ;*******************************************************************
;    result[1]=1 ;*******************************************************************
  
  ls_phi= coefs##result
  Print, STDDEV(TLI_WRAP_PHASE(ls_phi))
  
  cal_phi= ref_phi+ls_phi
  
  temp=WHERE(ABS(cal_phi) GE !PI )
  IF temp[0] NE -1 THEN BEGIN
    Print, '*** There are phase ambiguities on the arc. ***'
  ENDIF ELSE BEGIN
    Print, '*** There are no phase ambiguities on the arc. ***'
    
  ENDELSE
  
  corr= CORRELATE(ref_phi, cal_phi)
  Print, 'Correlation between the phase:', corr
  Print, 'dv,ddh:',result
  Print, 'Correlation between the height-related phase and temporal baseline:'
  ; Plot the phases
  tbase_ind= SORT(Tbase)
  t=tbase[tbase_ind]
  rphi= ref_phi[tbase_ind]
  cphi= cal_phi[tbase_ind]
  
  ; Try to create a phase jump.
  cphi_c=cphi
  cphi_abs= ABS(cphi)
  cphi_max=MAX(cphi_abs, temp)
  cphi_c[temp]=cphi_c[temp]+0.05*!PI  ; Add 0.05 PI to the reference point.
  cphi_c= TLI_WRAP_PHASE(cphi_c)
  Print, 'Temporal baseline is:', t[temp]
  Print, 'Correlation between the reference phase and phase-with-jump is:'
  Print, CORRELATE(rphi, cphi_c)

  
  t= Tbase[tbase_ind]
  Print, 'Correlation between the height-related phase and temporal baseline:'
  h_phase= ddh[0]*coefs_dh[tbase_ind]
  Print, correlate(t, h_phase)
  Print, correlate(t, cphi-rphi)
  IF 1 THEN BEGIN
    ; Plot the phases
    ;    tbase_ind= SORT(Tbase)
    ;    rphi= ref_phi[tbase_ind]
    ;    cphi= cal_phi[tbase_ind]
    ;    t= Tbase[tbase_ind]
  
  slavedate=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  slavejul=DATE2JULDAT(slavedate)
  dummy=LABEL_DATE( date_format='%M. %Y')
  t=slavejul[tbase_ind]
  font_size=10

  
  
    temp=Plot( t,rphi,position=[0.07, 0.59, 0.45, 0.97],Yrange=[-!PI,!PI],$
      xtitle='Acquisition date!C(a)',xmajor=5, ytitle='Phase (rad)', ymajor=3,yminor=3,DIMENSIONS=[1000,400],$
      FONT_SIZE=font_size, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      xticks=6 )
    temp=plot( t,cphi, position=[0.53, 0.59, 0.93, 0.97],/CURRENT,Yrange=[-!PI,!PI],$
      xtitle='Acquisition date!C(b)',xmajor=5,ytitle='Phase (rad)', ymajor=3,yminor=3, $
      FONT_SIZE=font_size, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      xticks=6 )
    ;    temp=plot( t, dv[0]*coefs_v[tbase_ind], position=[0.05, 0.05, 0.45, 0.45],/CURRENT,Yrange=[-!PI,!PI],xtitle='(c)',xmajor=5, ymajor=3,yminor=3, $
    ;      FONT_SIZE=10)
      
    temp=plot( t, ddh[0]*coefs_dh[tbase_ind], position=[0.07, 0.12, 0.45, 0.47],/CURRENT,Yrange=[-!PI,!PI],$
      xtitle='Acquisition date!C(c)',xmajor=5, ytitle='Phase (rad)',ymajor=3,yminor=3, $
      FONT_SIZE=font_size, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      xticks=6 )  ; Height-related phase
    temp=plot( t, cphi-rphi, position=[0.53, 0.12, 0.93, 0.47],/CURRENT,Yrange=[-!PI,!PI],$
      xtitle='Acquisition date!C(d)',xmajor=5,ytitle='Phase (rad)', ymajor=3,yminor=3, $
      FONT_SIZE=font_size, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      xticks=6 ) ; Phase difference
    temp.save, hpapath+'HPA_Fig.1.jpg',border=10,RESOLUTION=300,/TRANSPARENT
  ENDIF
  
  
;  ; Analyze the relationship between phase std and PCC. Using simulated phase
;  times=1000L ; 1000 pair of data will be simulated.
;  times_in=10L ; Inside loops
;    result= DBLARR(2, times*times_in)
;;  result= DBLARR(2, times)
;  count=0
;  For i=0, times-1 DO BEGIN
;  
;    std_interval= (!PI-0)*i/(times-1); Set STD of the noise
;;    std_interval=(!PI)
;        FOR j=0, times_in-1 DO BEGIN
;    phi_n= RANDOMN(seed,nintf) ; Noise to be added
;    phi_n= phi_n*(SQRT(std_interval))
;    
;    new_cal= cal_phi+phi_n
;    new_cal= TLI_WRAP_PHASE(new_cal)
;    
;    std_phi= SQRT(MEAN((new_cal-ref_phi)^2))
;    pcc= CORRELATE(new_cal, ref_phi)
;    
;    result[*, count]=[std_phi, pcc]
;    count=count+1
;      ENDFOR
;  ENDFOR
;  std_phi= result[0,*]
;  pcc=result[1, *]
;  temp= plot(std_phi, pcc, linestyle=6, sym_color='black', sym_size=0.5,symbol='o',$;xrange=[0, !pi],yrange=[-1,1],$
;             sym_filled=1, sym_fill_color='green')
  
  
END