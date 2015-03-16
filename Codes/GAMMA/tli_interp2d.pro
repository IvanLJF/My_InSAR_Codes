;-
;- Interpolate data
;- x, y, z should be vectors
;-

FUNCTION TLI_INTERP2D, x, y, z, interpx, interpy, degree=degree
  
  ; Judge if x, y, z are vectors
  sz= SIZE(x,/DIMENSIONS)
  IF N_ELEMENTS(sz) NE 1 THEN BEGIN
    temp= WHERE(sz NE 1)
    IF N_ELEMENTS(temp) NE 1 THEN BEGIN
      Message, 'x should be a vector!'
    ENDIF
    x= REFORM(x)
    y= REFORM(y)
    z= REFORM(z)
  ENDIF
  
  IF ~KEYWORD_SET(degree) THEN degree=2
  
  x2= x^2
  y2= y^2
  xy= x*y
  
  Case degree OF
    1:  BEGIN
      
      
      
    END
    2: BEGIN
    
    
    END
    
    ELSE: BEGIN
      result= z*
    
    END
    
    
    
  
  ENDCASE
  
  
  

END