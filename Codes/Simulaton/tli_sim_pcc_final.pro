;-
;- WTF!!!
;- The old version can not be found.
;- I have to rewite the codes.
;- 20130729
@tli_time
PRO TLI_SIM_PCC_FINAL
  workpath='/mnt/software/myfiles/Software/experiment/HPA/sim'
  IF !D.NAME EQ 'WIN' THEN BEGIN
    workpath=TLI_DIRW2L(workpath,/REVERSE)
  ENDIF
  workpath=workpath+PATH_SEP()
  file=workpath+'PCC_phase_stability'+TLI_TIME(/str)
  logfile=workpath+'log.txt'
  loglun=TLI_OPENLOG(logfile)
  PrintF, loglun, 'SIM PCC: Task starts at:'+TLI_TIME(/str)
  PrintF, loglun, ''
  nintf=40
  dphi_std_start=0.0
  dphi_std_end=1.3
  dphi_std_number=50
  dphi_std_int=(dphi_std_end-dphi_std_start)/(dphi_std_number-1)  ; interval
  n_sim=5000   ; Simulates for each dphi_std
  
  IF 0 THEN BEGIN
    ; First simulate the phase for the reference point.
    ref_std=!PI*0.8
    ref_phi=RANDOMN(seed,nintf)*ref_std
    ref_phi=TLI_WRAP_PHASE(ref_phi)
    PrintF, loglun, 'The master phase SD is ought to be:'+STRING(ref_std)
    PrintF, loglun, 'The master phase SD is:'+STRING(STDDEV(ref_phi))
    Print,  'The master phase SD is ought to be:'+STRING(ref_std)
    Print,  'The master phase SD is:'+STRING(STDDEV(ref_phi))
    
    ; Second simulate the phase increment.
    result=DBLARR(3, dphi_std_number)
    FOR i=0, dphi_std_number -1 DO BEGIN
      Print, i, '/', STRING(dphi_std_number-1)
      dphi_std_i=dphi_std_start+dphi_std_int*i
      corr_i=DBLARR(n_sim)
      FOR j=0, n_sim-1 DO BEGIN
        dphi=RANDOMN(seed,nintf)*dphi_std_i
        adj_phi=ref_phi+dphi
        adj_phi=TLI_WRAP_PHASE(adj_phi)
        corr=CORRELATE(ref_phi, adj_phi)
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
    
    temp=plot(x,y, yerror=y_err,$
      xrange=[-0.05, 1.4],yrange=[-0.1,1.1], $
      ;      psym=1,xtitle='SD of Phase Difference (rad)!C'+xnames[i],ytitle='PCC',$
      psym=1,ytitle='PCC',$  ;xtitle='!9s(Df)!C!3'+xnames[i],
      dimensions=[800, 500], position=[0.13, 0.19, 0.95, 0.95], $
      errorbar_capsize=0.06,noclip=0,font_size=18)
    temp.save, file+'.emf', BORDER=10, RESOLUTION=300,/TRANSPARENT
    Print,  'The master phase SD is ought to be:'+STRING(ref_std)
    Print,  'The master phase SD is:'+STRING(STDDEV(ref_phi))
    temp.close
  ENDIF
  
  ; Simulate the phase correlation at the 19th dphi_std=0.50408161
  ; First simulate the phase for the reference point.
  ref_std=!PI*0.4
  ref_phi=RANDOMN(seed,nintf)*ref_std
  ref_phi=TLI_WRAP_PHASE(ref_phi)
  PrintF, loglun, 'The master phase SD is ought to be:'+STRING(ref_std)
  PrintF, loglun, 'The master phase SD is:'+STRING(STDDEV(ref_phi))
  Print,  'The master phase SD is ought to be:'+STRING(ref_std)
  Print,  'The master phase SD is:'+STRING(STDDEV(ref_phi))
  ; Second simulate the phase for adj. point.
  dphi_std_i=dphi_std_start+19*dphi_std_int
  corr_i=DBLARR(n_sim)
  adj_phi_std=DBLARR(n_sim)
  FOR j=0, n_sim-1 DO BEGIN
    dphi=RANDOMN(seed,nintf)*dphi_std_i
    adj_phi=ref_phi+dphi
    adj_phi=TLI_WRAP_PHASE(adj_phi)
    adj_phi_std[j]=STDDEV(adj_phi)
    corr=CORRELATE(ref_phi, adj_phi)
    corr_i[j]=corr
  ENDFOR
  corr_i_mean=MEAN(corr_i)
  corr_i_std=STDDEV(corr_i)
  print, 'PCC:', corr_i_mean, corr_i_std
  result=TRANSPOSE([[adj_phi_std], [corr_i]])
  x=result[0, *]
  y=result[1, *]
;   temp=PLOT(t, XQ14,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;    symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
;    FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;    linestyle=0, sym_thick=0.3,xtitle='Acquisition date!C(a)',ytitle='Deformation (mm)',$
;    xticks=6, xmajor=5)

  data=TLI_READDATA(workpath+'ref05_mean079_std015',samples=2, format='DOUBLE')
  x=data[0,*]
  y=data[1, *]
;  temp=plot(x,y, yerror=y_err,$
;    ;      psym=1,xtitle='SD of Phase Difference (rad)!C'+xnames[i],ytitle='PCC',$
;    yrange=[0,1], xrange=xrange,dimensions=[800,500],position=position,$
;    symbol='o',sym_size=0.3,sym_color='red', sym_filled=1, sym_fill_color='red',$
;    FONT_SIZE=18, xstyle=1,$
;    linestyle=6, sym_thick=0.3,xtitle='SDs of Adj. Point (rad)',ytitle='PCC',$
;    xticks=6, xmajor=5)
    FREE_LUN,loglun
   temp=plot(ref_phi, $
    yrange=[-3.14,3.14], xrange=[1, 40],dimensions=[400,250],position=position,$
    symbol='o',sym_size=0.3,sym_color='red', sym_filled=1, sym_fill_color='red',$
    FONT_SIZE=18, xstyle=1,$
    linestyle=0, sym_thick=0.3,$
    xticks=0, xmajor=0, yticks=3, ymajor=3)
STOP
END