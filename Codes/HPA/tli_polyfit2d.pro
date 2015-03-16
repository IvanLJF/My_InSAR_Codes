; -
; - Script that:
; -   Interpolate of expolate data using a least square method

FUNCTION TLI_POLYFIT2D, x, y, z, interpx, interpy, degree=degree

  ; Judge input
  sz= SIZE(x, /DIMENSIONS)
  IF N_ELEMENTS(sz) NE 1 THEN BEGIN
    temp= WHERE(sz NE 1)
    IF N_ELEMENTS(temp) NE 1 THEN BEGIN
      Message, 'x, y, z should be vectors.'
    ENDIF
    x= REFORM(x)
    y= REFORM(y)
    z= REFORM(z)
  ENDIF
  
  IF ~KEYWORD_SET(degree) THEN degree =2
  
  ca0= REPLICATE(1, 1, SIZE(x,/N_ELEMENTS))
  ca1= TRANSPOSE(x)
  ca2= TRANSPOSE(y)
  ca3= TRANSPOSE(x*y)
  ca4= TRANSPOSE(x^2)
  ca5= TRANSPOSE(y^2);b=a0+a1*ca1+a2*ca2+a3*ca3+a4*ca4+a5*ca5
      
  Case Degree OF
    0: BEGIN
      coefs=DOUBLE([MEAN(z),0,0,0,0,0])
    END
    1: BEGIN
      a=[ca0,ca1,ca2,ca3]
      coefx= TRANSPOSE(LA_LEAST_SQUARES(a, z))
      sz=SIZE(coefx,/DIMENSIONS)
      IF sz[0] EQ 1 THEN BEGIN
      coefs= [TRANSPOSE(coefx),0,0]
      ENDIF ELSE BEGIN
        coefs=[coefx, 0, 0]
      ENDELSE
    END
    2: BEGIN
      a= [ca0,ca1,ca2,ca3,ca4,ca5]
      coefs= TRANSPOSE(LA_LEAST_SQUARES(a, z))
    END
    ELSE:
  ENDCASE
  
  result= coefs[0] $
        + coefs[1]*interpx  $
        + coefs[2]*interpy  $
        + coefs[3]*interpx*interpy  $
        + coefs[4]*interpx^2  $
        + coefs[5]*interpy^2 
  RETURN, result
END