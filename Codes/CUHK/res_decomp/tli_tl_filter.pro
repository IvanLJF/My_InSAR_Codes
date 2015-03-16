PRO TLI_TL_FILTER, plistfile, res_phasefile, low_f, high_f, res_phase_tlfile= res_phase_tlfile

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
  lp_filter= DIGITAL_FILTER(low_f, high_f, 50, 2)
  FOR i=0D, npt_ind-1D DO BEGIN
  
    IF ~(i MOD 1000) THEN Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt_ind-1)
    ; Extract this point's phase
    res_phase_i = TRANSPOSE(res_phase[i, *])
    
    ; Filtering
    res_phase_i_lp= CONVOL(res_phase_i, lp_filter,/edge_wrap)
    
    ; True index of the point is ind[i]
    res_phase_lp[ind[i], 3:*]=res_phase_i_lp
    
  ENDFOR
  
  OPENW, lun, res_phase_tlfile,/GET_LUN
  WRITEU, lun, res_phase_lp
  FREE_LUN, lun
  
END