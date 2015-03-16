;+ 
; Name:
;    TLI_EXTRBASELINE
; Purpose:
;    Extract baselines and doppler centroid difference from params file.
; Calling Sequence:
;    Result = TLI_EXTRBASELINE(paramfile)
; Inputs:
;    paramfile
; Keyword Input Parameters:
;    None.
; Outputs:
;    Three columns X nlines.
;    -----Temporal Baseline-----Spatial Baseline-----Doppoler centroid difference-------
; Commendations:
;    None.
; Example:
;    paramfile= '/mnt/software/ISEIS/Data/Img/Result_ASAR_Full.txt'
;    result= TLI_EXTRBASELINE(paramfile)
; Modification History:
;    23/05/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;- 
FUNCTION TLI_EXTRBASELINE, paramfile

  IF ~N_PARAMS(paramfile) THEN Message, 'TLI_EXTRBASELINE: Usage, Error!'
  all_params= hh_getparest_interferogram_parameters(paramfile)
  ;Temporal Baseline---Spatial Baseline---Perp Baseline---Doppler Centroid
  result= all_params[[6,7,8,12],*]
  RETURN, DOUBLE(result)

END