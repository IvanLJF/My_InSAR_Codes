;-
;- Purpose:
;-     Do spatially low pass filtering.

PRO TLI_SL_FILTER, plistfile, res_phasefile, res_phase_slfile= res_phase_slfile,$
    aps, rps, winsize
    
  ; Read params
  npt= TLI_PNUMBER(plistfile)
  res_phase= TLI_READDATA(res_phasefile, samples=npt, FORMAT='DOUBLE')
  res_phase_lp= res_phase
  nintf= (SIZE(res_phase, /DIMENSIONS))[1]-3
  Print, 'Number of interferograms:', STRCOMPRESS(nintf)
  
  ; Determine the points to be used.
  ind= WHERE(res_phase[*, 2] EQ 1) ; res_phase_lp[ind, 3:*]= low pass results
  npt_ind= N_ELEMENTS(ind)
  Print, 'Number of points:', STRCOMPRESS(npt_ind)
  plist= TLI_READDATA(plistfile, samples=1, FORMAT='FCOMPLEX')
  plist= plist[*, ind]
  plist_x= REAL_PART(plist) ; X coordinates of points.
  plist_y= IMAGINARY(plist) ; Y coordinates of points.
  res_phase= res_phase[ind, 3:*]
  
  ; Filtering
  win_fil= winsize/2
  FOR i=0D, npt_ind-1D DO BEGIN
  
    IF ~(i MOD 1000) THEN Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt_ind-1)
    ; Find nearby points.
    coorx_i= plist_x[i]
    coory_i= plist_y[i]
    
    ; Calculate distances
    dis= SQRT((plist_x-coorx_i)^2+(plist_y-coory_i)^2)
    nearby_ind= WHERE(dis LE win_fil)
    
    ; Filter
    res_phase_i= res_phase[nearby_ind, *] ; npt samples, nitab lines. **********************************************
    res_phase_i_lp= TOTAL(res_phase_i, 1)/(N_ELEMENTS(nearby_ind)) ; Mean
    
    
;    coors=[[379,1088],[381,1103],[503,949]]
;    FOR j=0, N_ELEMENTS(coors)/2-1 DO BEGIN
;      IF coorx_i EQ coors[0,j] AND coory_i EQ coors[1,j] THEN BEGIN
;        Print, res_phase_i_lp
;      ENDIF
;    ENDFOR
    
    
    ; True index of the point is ind[i]
    res_phase_lp[ind[i], 3:*]=res_phase_i_lp
    
  ENDFOR
  OPENW, lun, res_phase_slfile,/GET_LUN
  WRITEU, lun, res_phase_lp
  FREE_LUN, lun
  
END