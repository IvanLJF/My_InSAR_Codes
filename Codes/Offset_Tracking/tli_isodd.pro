;
; Judge if the input number is odd.
;
; Written by:
;   T.LI @ ISEIS, 20131223
;   
FUNCTION TLI_ISODD, input
  
  COMPILE_OPT idl2
  
  n=N_ELEMENTS(input)
  result=0
  FOR i=0, n-1 DO BEGIN
    IF (input[i] MOD 2) THEN BEGIN
      result=[result, 1]
    ENDIF ELSE BEGIN
      result=[result, 0]
    ENDELSE 
  ENDFOR
  
  RETURN,result[1:*]
END