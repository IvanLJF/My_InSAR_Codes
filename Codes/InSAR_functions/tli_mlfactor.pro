;
; Determine multi looking factors using input params
;
; Parameters:
;
; Keywords:
;   parfile       : Gamma par file
;   rps           : Range pixel spacing, unnecessary if parfile is specified.
;   aps           : Azimuth pixel spacing, unnecessary if parfile is specified.
;   inc_angle     : Incidence angle, unnecessary if parfile is specified.
;
; Written by:
;   T.LI @ Sasmac, 20121231
;
FUNCTION TLI_MLFACTOR, parfile=parfile, rps=rps, aps=aps, inc_angle=inc_angle
  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(parfile) THEN BEGIN
    IF KEYWORD_SET(rps)+KEYWORD_SET(aps)+KEYWORD_SET(inc_angle) NE 3 THEN BEGIN
      Message, ['ERROR! TLI_MLFACTOR', $
        'Please either give parfile or give [rps, aps, inc_angle]']
    ENDIF
  ENDIF ELSE BEGIN
    finfo=TLI_LOAD_SLC_PAR(parfile)
    rps=finfo.range_pixel_spacing
    aps=finfo.azimuth_pixel_spacing
    inc_angle=finfo.incidence_angle
  ENDELSE
  
  rps_grd=rps/SIN(DEGREE2RADIANS(inc_angle))
  
  ;-------------------------------------------------
  ; Test range ml factor as 1.0, 2.0
  ml_r=1.0
  
  ml_azi=rps_grd/aps
  
  ml_azi_int=ROUND(ml_azi)
  
  IF ABS(ml_azi-ml_azi_int) LE 0.1 THEN BEGIN
    RETURN, [LONG(ml_r), LONG(ml_azi_int)]
  ENDIF
  
  ml_r=2.0
  ml_azi=rps_grd*ml_r/aps
  
  ml_azi_int=ROUND(ml_azi)
  IF ABS(ml_azi-ml_azi_int) LE 0.1 THEN BEGIN
    RETURN, [LONG(ml_r), LONG(ml_azi_int)]
  ENDIF
  
  ;--------------------------------------------------
  ; For loops
  
  findit=0
  While NOT findit DO BEGIN
    ml_r=ml_r+1
    ml_azi=rps_grd*ml_r/aps
    
    ml_azi_int=ROUND(ml_azi)
    IF ABS(ml_azi-ml_azi_int) LE 0.1 THEN BEGIN
      RETURN, [LONG(ml_r), LONG(ml_azi_int)]
    ENDIF
    IF ml_r GT 10 THEN BEGIN
      Print,'Error! TLI_MLFACTOR: Failed to provide useful ml factors.'
      RETURN, [1,1]
    ENDIF  
  ENDWHILE
  Print, 'Warning! TLI_MLFACTOR: Might return unreliable ml factors.'
  
END