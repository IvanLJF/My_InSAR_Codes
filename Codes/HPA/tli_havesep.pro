FUNCTION TLI_HAVESEP, str
  ;- Check if the str contains path_sep() or not.

  COMPILE_OPT idl2
  
  ON_ERROR, 2
  
  temp= STRMID(str, 0,1, /reverse_offset)
  IF temp EQ PATH_SEP() THEN BEGIN
    RETURN, 1
  ENDIF ELSE BEGIN
  
    RETURN, 0
  ENDELSE
  
END