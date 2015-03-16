;
; Convert the longtude between the two format:
;   float(longitude) -> [ddd, mm, ss]
; Parameter:
;   longitude  : Input longitude or latitude.
; Return:
;   Longitude or latitude in the converted format.
; Written by:
;   T.LI @ Home, 20140207.
;
FUNCTION TLI_LONGITUDE, longitude
  COMPILE_OPT idl2
  IF N_ELEMENTS(longitude) EQ 1 THEN BEGIN
    ddd=FLOOR(longitude)
    ddd_mod=longitude-ddd
    
    mm_all=ddd_mod*60D
    mm=FLOOR(mm_all)
    mm_mod=mm_all-mm
    
    ss_all=mm_mod*60D
    ss=FLOAT(ss_all)
    result=[ddd, mm, ss]
  ENDIF ELSE BEGIN
    IF N_ELEMENTS(longitude) NE 3 THEN Message, 'Error: Format of the longitude should be in [ddd, mm, ss]' 
    result=longitude[2]/3600D +longitude[1]/60D + longitude[0]
  ENDELSE
  RETURN,result
END