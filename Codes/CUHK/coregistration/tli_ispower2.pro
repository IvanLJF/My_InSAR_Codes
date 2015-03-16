;+ 
; Name:
;    TLI_ISPOWER2
; Purpose:
;    Judge if the given number is power of 2.
; Calling Sequence:
;    result= TLI_ISPOWER2(data)
; Inputs:
;    data    :  Any type of data.
; Keyword Input Parameters:
;    None
; Outputs:
;    result  :  0 : If data is not power of 2.
;               1 : If data is power of 2.
; Commendations:
;    None.
; Example:
;    data=5
;    result= TLI_ISPOWER(data)
; Modification History:
;    04/26/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK.
;- 
FUNCTION TLI_ISPOWER2, data
  COMPILE_OPT idl2
  data_c= LONG(data)
  IF (data_c - data) NE 0 THEN BEGIN
    RETURN, 0
  ENDIF
  log= ALOG(data_c)/ALOG(2)
  IF (log MOD 1) THEN BEGIN
    RETURN, 0
  ENDIF ELSE BEGIN
    RETURN, 1
  ENDELSE
END