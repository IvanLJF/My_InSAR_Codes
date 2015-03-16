PRO TLI_SORTOUT_FINAL, plistfile,time_series_linearfile, nonlinearfile,lamda, final_resultfile= final_resultfile

  npt= TLI_PNUMBER(plistfile)
  time_series_linear= TLI_READDATA(time_series_linearfile, samples=npt, format= 'DOUBLE')
  res_phase_tl= TLI_READDATA(nonlinearfile, samples= npt, format= 'DOUBLE')
  
  final_result= time_series_linear
  final_result[*, 3:*]= time_series_linear[*, 3:*]+res_phase_tl[*, 3:*]*lamda/(4*!PI)*1000 ; Change m/yr to mm/yr
  
  OPENW, lun, final_resultfile,/GET_LUN
  WRITEU, lun, final_result
  FREE_LUN, lun
  
;  coors=[[379,1088],[381,1103],[503,949]]
;  FOR i=0, N_ELEMENTS(coors)/2-1 DO BEGIN
;    coor=coors[*, i]
;    ind= WHERE(time_series_linear[*,0] EQ coor[0] AND time_series_linear[*,1] EQ coor[1])
;    Print, ind
;    l= time_series_linear[ind, 3:*]
;    ts= final_result[ind, 3:*]
;    nl= res_phase_tl[ind, 3:*]
;    Print, nl
;    WINDOW,/FREE & Plot, nl
;    ;  nl_def=res_phase_tl[ind, 3:*]*lamda/(4*!PI)*1000
;    ;  plot, ts & OPLOT, nl_def & OPLOT, l
;    Print, i
;  ENDFOR
  
  
  
  IF KEYWORD_SET(txt) THEN BEGIN
    OPENW, lun, resulfile+'.txt',/GET_LUN
    Printf, lun, final_result
    FREE_LUN, lun
  ENDIF
  
END