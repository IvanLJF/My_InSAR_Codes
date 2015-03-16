;
; Calculate RMSE for two compared data array.
;
; Written by:
;   T.LI @ SWJTU, 20140610
; 
FUNCTION TLI_RMSE, x, y=y
  
  IF NOT KEYWORD_SET(y) THEN BEGIN
    sz=SIZE(x,/dimensions)
    IF sz[0] NE 2 THEN Message, 'There should be and only be 2 columns in the input array.'
    result=SQRT(MEAN((x[1, *]-x[0, *])^2))
  ENDIF  ELSE BEGIN
    result=SQRT(MEAN((y-x)^2))
  ENDELSE
  RETURN, result
  
END