; Interpolate the deformation on the given date.
; First used for DAM
; Written by:
;   T.LI @ ISEIS, 20130518

; ts: time_series deformation, can be a vector or a npt*nintf array.
; dates: julday of each aquitision date.
; date: date to interpolate.
@tli_linear_solve_cuhk.pro
FUNCTION TLI_INTERP_DEF, ts_orig, dates_orig, date

  COMPILE_OPT idl2
  
  dates_ind= SORT(dates_orig)
  dates=dates_orig[dates_ind]
  ts=ts_orig[dates_ind, *]
  
  ; First judge the input params.
  
  n_intf= N_ELEMENTS(dates)
  ;  IF n_intf NE n_dates THEN Message, 'Input ts and dates must have the same dimensions.'
  IF N_ELEMENTS(date) NE 1 THEN Message, 'Date must be a scalar.'
  ;  temp=LINDGEN(N_ELEMENTS(dates))
  ;  temp_sort=SORT(dates)
  ;  IF (temp_sort-temp) NE 0 THEN Message
  ; Locate the date
  jul=date
  IF STRLEN(STRCOMPRESS(date,/REMOVE_ALL)) EQ 8 THEN BEGIN
    jul=DATE2JULDAT(date)
  ENDIF
  
  
  ind=WHERE(dates EQ jul)
  IF ind[0] NE -1 THEN RETURN, ts[ind,*]
  
  ind_left= WHERE(dates LT jul)
  ind_right= WHERE(dates GT jul)
  
  IF ind_left[0] EQ -1 THEN BEGIN
    result=ts[0, *]
    RETURN, result
  ENDIF
  IF ind_right[0] EQ -1 THEN BEGIN
    result=ts[n_intf-1, *]
    RETURN, result
  ENDIF
  
  ind_left=ind_left[N_ELEMENTS(ind_left)-1]
  ind_right=ind_right[0]
  v_l= ts[ind_left,*]
  v_r= ts[ind_right,*]
  
  result=v_l+(v_r-v_l)/(dates[ind_left]-dates[ind_right])*(jul-dates[ind_left])
  RETURN, result
END