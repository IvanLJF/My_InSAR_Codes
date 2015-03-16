FUNCTION DEGREE2RADIANS, input, reverse=reverse
; Change degree to radians.
; If 'reverse' is set to -1, then change radians to degree.
  IF Keyword_set(reverse) THEN BEGIN
    result= input/(!PI)*180D
  ENDIF ELSE BEGIN
    result= input/180D *(!PI)
  ENDELSE
  RETURN, result
END