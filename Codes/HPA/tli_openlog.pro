;-
;- Open a logfile.
;- If the file exists, then append. Or else, open for write.
;-
FUNCTION TLI_OPENLOG, logfile

  IF FILE_TEST(logfile) THEN BEGIN
    OPENW,loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW,loglun, logfile,/GET_LUN
  ENDELSE
  RETURN, loglun
END