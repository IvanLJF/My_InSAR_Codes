;-
;- Refine data using mean+-3*delta
;- Return the indices of the data within the range.
;- Written by T.Li @ SWJTU
;- ISEIS, CUHK, 20130318

FUNCTION TLI_REFINE_DATA,data,delta=delta,refined_data=refined_data

  IF NOT KEYWORD_SET(delta) THEN BEGIN
    delta=3
  ENDIF
  
  sz= SIZE(data,/type)
  Case sz of
    0: ; undefined
    1: ;Byte
    2: ;Int
    3: ;Long
    4: ; Float
    5: ; COUBLE
    ; 6: ;COMPLEX
    ELSE: BEGIN
      Message, 'Data type not supported.
    END
  ENDCASE
  
  m= MEAN(data)
  d= STDDEV(data)
  up= m+delta*d
  down= m-delta*d
  
  result= WHERE(data LT up AND data GT down)
  refined_data= data[result]
  RETURN, result
END