;
; Judge if the input number is an integer
;
; Parameters:
;   input     : The input integer
;
; Keywords:
;   t_code    : Type code. Please refer to SIZE(array,/TYPE)
;   t_name    : Type name. Please refer to SIZE(array,/TNAME)
;   convert   : Check if the input number can be converted to integer.
;               E.g., 10.0 can be regarded as integer if this keyword is set to 1.
; Written by:
;   T.LI @ ISEIS, 20131202
;
FUNCTION TLI_ISINTEGER, input, t_code=t_code, t_name=t_name,convert=convert

  IF N_ELEMENTS(input) NE 1 THEN Message, 'Error: TLI_ISINTEGER, input parameters must be a scalar.'
  t_code=SIZE(input,/TYPE)
  t_name=SIZE(input,/TNAME)
  
  CASE t_code OF
    1 : RETURN, 1
    2 : RETURN, 1
    3 : RETURN, 1
    12: RETURN, 1
    13: RETURN, 1
    14: RETURN, 1
    15: RETURN, 1
    ELSE: BEGIN
      IF KEYWORD_SET(convert) THEN BEGIN
        temp=LONG(input)
        IF input EQ temp THEN RETURN, 1
      ENDIF
      RETURN, 0
    ENDELSE
  ENDCASE
  
END