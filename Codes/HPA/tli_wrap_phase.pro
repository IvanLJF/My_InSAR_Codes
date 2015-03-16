; Wrap phase
; 
; Written by:
;   T.LI @ ISEIS.
; History:
; 
FUNCTION TLI_WRAP_PHASE, arr
  r= COS(arr)
  i= SIN(arr)
  temp= COMPLEX(r, i)
  result= ATAN(temp,/PHASE)
  RETURN, result
END