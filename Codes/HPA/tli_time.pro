;- Return this time
;- Organized as [YYYY MM DD HH MM SS]
FUNCTION TLI_TIME, input, str=str

  result= SYSTIME(/JULIAN)
  CALDAT, result, month, day, year, hour, minute,second
  result= LONG([year, month, day, hour, minute, second])
  
  IF KEYWORD_SET(str) THEN BEGIN
    RETURN, STRCOMPRESS(STRJOIN(result, '_'),/REMOVE_ALL)
  ENDIF ELSE BEGIN
    RETURN, result
  ENDELSE
END