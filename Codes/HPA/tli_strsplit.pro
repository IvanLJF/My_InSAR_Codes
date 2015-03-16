
FUNCTION TLI_STRSPLIT,strarr, pattern=pattern

  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(pattern) THEN pattern=' '
  nstr=N_ELEMENTS(strarr)
  n_blank=0
  pattern_c=pattern
  FOR i=0, nstr-1 DO BEGIN
    str=strarr[i]
    str=STRSPLIT(str,pattern_c, /EXTRACT)
    IF i EQ 0 THEN BEGIN
      samples=N_ELEMENTS(str)
      IF samples EQ 1 THEN BEGIN
        str=STRSPLIT(str, STRING(9B),/EXTRACT)
        IF N_ELEMENTS(str) EQ 1 THEN Message, 'ERROR: please specify the correct separator.'
        pattern_c=STRING(9B)
      ENDIF 
      result=str
    ENDIF ELSE BEGIN
      IF N_ELEMENTS(str) EQ 1 THEN BEGIN
        n_blank=n_blank+1
        CONTINUE
      ENDIF
      result=[[result],[str]]
    ENDELSE
  ENDFOR
  IF n_blank GT 0 THEN Print, 'There are'+STRCOMPRESS(n_blank)+' invalid lines in the input arrays."
    
  RETURN, result

END