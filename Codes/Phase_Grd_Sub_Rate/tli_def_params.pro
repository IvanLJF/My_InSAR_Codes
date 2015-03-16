;
; Return the specified params with reference to the different point index.
;
; Params:
;   sarlistfile      : Sarlist file.
;   itabfile         : Itab file.
;
; Keywords:
;   pbase            : Array consists of perpendicular baselines for each point of each interferogram.
;   tbase            : Temporal baselines
;   pla              : Array consists of look angle for each point of each interferogram.
;
; Return:
;   Strucure containing
;     tbase          : Temporal baselines.
;     bperp          : Perpendicular baselines
;     pla            : Look angle of the reference point.
;     wavelength     : Wavelength of the sensor.
;     ref_r          : Slant range of the reference point.
;
; Written by:
;   T.LI @ISEIS, 20131224
;
FUNCTION TLI_DEF_PARAMS, sarlistfile, itabfile, pbase=pbase, tbase=tbase, pla=pla, pind=pind, finfo=finfo, plist=plist, ref_coor=ref_coor

  IF N_ELEMENTS(pind) AND KEYWORD_SET(plist) THEN BEGIN
    ref_coor=plist[pind]
  ENDIF ELSE BEGIN
    IF N_ELEMENTS(ref_coor) EQ 0 THEN Message, 'Error! TLI_DEF_PARAMS, plase specify the reference coordinate.'
    pind=0
  ENDELSE
  IF NOT KEYWORD_SET(tbase) THEN tbase=TBASE_ALL(sarlistfile, itabfile)
  IF NOT KEYWORD_SET(finfo) THEN finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  bperp=pbase[pind, *]
  pla_ind=pla[pind, *]
  e=TLI_E()
  c= 299792458D ; Speed light
  
  result=CREATE_STRUCT('tbase', tbase, $
    'bperp', bperp, $
    'pla', pla_ind[0], $
    'wavelength', c/finfo.radar_frequency, $
    'ref_r', finfo.near_range_slc+REAL_PART(ref_coor)*finfo.range_pixel_spacing    )
  RETURN, result
END