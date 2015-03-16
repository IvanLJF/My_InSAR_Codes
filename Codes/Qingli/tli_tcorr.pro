;-
;- Purpose:
;-     Calculate temporal coherence for a point
;
FUNCTION TLI_TCORR, inputarr
  
  COMPILE_OPT idl2
  e=TLI_E()
  
  ; Judge input params
  sz= SIZE(inputarr,/TYPE)
  Case sz OF ; Input data type 
    4: BEGIN ;Float
      phi= inputarr
    END
    5: BEGIN ; Double
      phi= inputarr
    END
    6: BEGIN  ; Complex
      phi= ATAN(inputarr,/ANGLE)
    END
    9: BEGIN  ; Dcomplex
      phi= ATAN(inputarr,/ANGLE)
    END
    ELSE: Message, 'Input file type error!!!'
  ENDCASE
  
  gm= ABS(MEAN(e^(COMPLEX(0, phi))))
  
;  Print, 'Temporal coherence is:', STRCOMPRESS(gm)
;  Print, 'Phase sdandard deviation is:', STDDEV(phi)
;  Print, 'Phase sdandard deviation calculated from gm is:', SQRT(-2*ALOG(gm))
  
  RETURN, ABS(gm)
END