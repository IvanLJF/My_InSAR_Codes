; Return e.
; e = 2.71828...
FUNCTION TLI_E
  temp= ALOG(2)
  e= 2^(1/temp)
  RETURN, e
END