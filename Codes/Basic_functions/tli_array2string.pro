;
; Convert the given array 2 a string.
;
; Parameters:
;   array   : Input array.
;
; Keywords:
;   none.
;
; Written by:
;   T.LI @ Sasmac, 20140909.
;
FUNCTION TLI_ARRAY2STRING, array
  
  sz=SIZE(array,/DIMENSIONS)
  
  lines=sz[1]
  
  str=STRCOMPRESS(array,/REMOVE_ALL)
  
  str_new=STRARR(1, lines)
  
  FOR i=0, lines-1 DO BEGIN
    IF i NE lines-1 THEN BEGIN
      str_temp=STRJOIN(str[*, i], ' ')+STRING(13b)
    ENDIF ELSE BEGIN
      str_temp=STRJOIN(str[*, i], ' ')
    ENDELSE
    str_new[i]=str_temp
  ENDFOR
  
  str_new=TRANSPOSE(str_new)
  
  str_new=STRJOIN(str_new)
  
  RETURN, str_new

END