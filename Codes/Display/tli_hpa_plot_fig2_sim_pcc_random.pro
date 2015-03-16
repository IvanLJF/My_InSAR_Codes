; PCC simulation in HPA paper. Fig. 2
PRO tli_hpa_plot_fig2_sim_pcc_random
  workpath='D:\myfiles\Software\experiment\HPA\sim'
  workpath=workpath+PATH_SEP()
  file1722=workpath+'PCC_phase_stability2013_4_12_14_22_27'
  file1486=workpath+'PCC_phase_stability2013_4_16_21_22_25'
  file0670=workpath+'PCC_phase_stability2013_4_12_14_21_40'
  file0185=workpath+'PCC_phase_stability2013_4_12_14_20_29'
  files=[file1722, file1486, file0670, file0185]
  nfiles=N_ELEMENTS(files)
  Print, '"'+STRJOIN(FILE_BASENAME(files)+'.jpg','""')+'"'
  
  xnames=['(a)','(b)','(c)','(d)']
  FOR i=0, nfiles-1 DO BEGIN
    file=files[i]
    results= TLI_READDATA(file, samples=3, format='DOUBLE')
    x= results[0, *]  ; Std(diff)
    y= results[1, *]
    y_err= results[2, *]
    
    temp=plot(x,y, yerror=y_err,$
      xrange=[-0.05, 1.4],yrange=[-0.1,1.1], $
;      psym=1,xtitle='SD of Phase Difference (rad)!C'+xnames[i],ytitle='PCC',$
      psym=1,xtitle='!C!3'+xnames[i],ytitle='PCC',$  ;xtitle='!9s(Df)!C!3'+xnames[i],
      dimensions=[800, 500], position=[0.13, 0.19, 0.95, 0.95], $
      errorbar_capsize=0.06,noclip=0,font_size=18)
    temp.save, file+'.emf', BORDER=10, RESOLUTION=300,/TRANSPARENT
    temp.close
  ENDFOR
END