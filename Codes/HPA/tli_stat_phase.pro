;-
;- Fig. 3
;- Statistic the phase dispersion of PSLC
;-

PRO TLI_STAT_PHASE

  workpath='D:\myfiles\Software\experiment\TSX_PS_Tianjin\HPA'
  workpath=workpath+PATH_SEP()
  
  pslcfile= workpath+'pslc'
  ptfile=workpath+'plistupdate'
  
  npt=TLI_PNUMBER(ptfile)
  pslc=TLI_READDATA(pslcfile, samples=npt, format='FCOMPLEX')
  phi=ATAN(pslc, /PHASE)
  phi_std=STDDEV(phi, dimension=2)
  m=MEAN(phi_std)
  d=STDDEV(phi_std)
  Print, 'Statistics of phi_std:'
  Print, 'Mean value:', m
  Print, 'Std. dev.:', d
  Print, 'Confidential level of 99.7%:', m-3*d, m+3*d
  his=HISTOGRAM(phi_std, binsize=0.03, locations=locations)
  temp=PLOT(locations, his, yrange=[0, 9000],xrange=[1.2, 2.4], PSYM=10,$
           XTITLE='Std. Deviation of Phase (rad)', YTITLE='Density', dimensions=[780, 500], position=[0.15, 0.15, 0.95, 0.95])
  temp.save, workpath+'stat_phase_std.jpg', border=10, resolution=300,/TRANSPARENT
;  temp.close
;  temp=plot(x,y, yerror=y_err,$
;    xrange=[-0.05, 1.4],yrange=[-0.1,1.1], $
;    psym=1,xtitle='Std. Deviation of Phase Difference',ytitle='PCC',$
;    dimensions=[800, 500], position=[0.1, 0.1, 0.95, 0.95], $
;    errorbar_capsize=0.06,noclip=0)
;  temp.save, file+'.bmp', BORDER=10, RESOLUTION=300,/TRANSPARENT
;  wait, 2
;  temp.close

  
END