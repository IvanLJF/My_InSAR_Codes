;
; Return GAMMA installation path
;
FUNCTION TLI_GAMMA_PATH

  scr='echo $PATH'
  SPAWN, scr,result
  
  
  result=STRSPLIT(result, ':', /EXTRACT, count=count)
  IF N_ELEMENTS(result) EQ 1 THEN RETURN, ''
  FOR i=0, count-1 DO BEGIN
    temp=STRPOS(result[i], 'GAMMA_SOFTWARE')
    IF temp[0] NE -1 THEN BREAK 
  ENDFOR ; Get GAMMA path from systemp var.
  IF temp[0] EQ -1 THEN RETURN, ''
  
  gama=STRSPLIT(result[i],PATH_SEP(),/extract, count=count)
  
  FOR i=0, count-1 DO BEGIN
    temp=STRPOS(gama[i], 'GAMMA_SOFTWARE')
    IF temp[0] NE -1 THEN Break
  ENDFOR  ; Split path  
  
  result=PATH_SEP()+STRJOIN(gama[0:i], PATH_SEP())
  RETURN, result
END