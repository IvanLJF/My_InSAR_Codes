;
; Fit the given data. Use polynomial (most frequently used) or circular function (especially for Co-registration).
; The coefficients are estimated using LS estimation.
;
; The polyfit function are given in the form of: F=Sigma( a[i,j] * x^i * y^j) (i+j< max_deg = poly^2 )
; Do not support the large matrix. Sparse matrix methods can be used by applying Matlab instead of IDL for large matrix.
;
; Params:
;   x        : x coordinates.
;   y        : y coordinates.
;
; Keywords:
;   z        : z values. should be the same size as x and y.
;   inverse  : Fit the coefs (inverse=0) or calculate the z values (inverse=1).
;   coefs    : All the fitted coefs
;   order    : Order of the polynomial.
;   gauss    : Assume that the fit function is a gauss function (z=e^(-(x/c)^2), c is a constant).
;   fit_err  : The fit error of the z values.
;   fit_sig  : The overall error of the fit error.
;   coefs_err: Error of the result
;   status   : Status for the matrix inversion.
;
FUNCTION TLI_GAUSS, a, x, y

  ; Return the correspoding values using the input params.

  ;A[0] = A0 = constant term
  ;  A[1] = A1 = scale factor
  ;  A[2] = a = width of Gaussian in the X direction
  ;  A[3] = b = width of Gaussian in the Y direction
  ;  A[4] = h = center X location
  ;  A[5] = k = center Y location.
  ;  A[6] = T = Theta, the rotation of the ellipse from the X axis in radians, counter-clockwise.

  a0=a[0]
  a1=a[1]
  a_=a[2]
  b=a[3]
  h=a[4]
  k=a[5]
  t=a[6]
  
  xp=(x-h)*COS(t)-(y-k)*SIN(t)
  yp=(x-h)*SIN(t)+(y-k)*COS(t)
  
  u=(xp/a_)^2+(yp/b)^2
  
  e=TLI_E()
  result=a0+a1*e^(-u/2)
  
  RETURN, result
  
END

FUNCTION TLI_NCOEFS, order
  ; Return the number of the polynomial coefs of the given order.
  ncoefs=0
  FOR i=0, order DO FOR j=0, order DO BEGIN
    IF (i+j) GT order THEN CONTINUE
    ncoefs=ncoefs+1
  ENDFOR
  RETURN, ncoefs
END

FUNCTION TLI_MAXIMA, a, order=order,gauss=gauss
  ; Return the maxima point (x=x, y=y, maxz=maxz)
  Case order OF
    0: BEGIN
      result=[!VALUES.F_NAN, !values.F_NAN, a]
      RETURN, result
    END
    1: BEGIN
      result=[!values.F_NAN, !values.F_NAN, !values.F_NAN]
      RETURN, result
    END
    2: BEGIN
      maxima_x=(a[1]*a[4]-2*a[2]*a[3])/(4*a[2]*a[5]-a[4]^2)
      maxima_y=(a[3]*a[4]-2*a[1]*a[5])/(4*a[2]*a[5]-a[4]^2)
      maxima_z=a ## TRANSPOSE([1, maxima_y, maxima_y^2, maxima_x, maxima_x*maxima_y, maxima_y^2])
      result=[maxima_x, maxima_y, maxima_z]
      RETURN, result
    END
    3: BEGIN
      result=[!values.F_NAN, !values.F_NAN, !values.F_NAN]
      RETURN, result
    END
    ELSE: BEGIN
    
    END
    
  ENDCASE
  
END

FUNCTION TLI_LSFIT, x, y, z=z, inverse=inverse, coefs_all=coefs_all, order=order, gauss=gauss, $
    fit_err=fit_err, fit_sig=fit_sig, coefs_err=coefs_err, status=status
    
  ; Check the input params
  IF TOTAL(ABS(SIZE(x,/DIMENSIONS)-SIZE(y,/DIMENSIONS))) NE 0 THEN Message, 'Error: TLI_LSFIT, input arrays should be in the same size.'
  IF N_ELEMENTS(order) EQ 0 AND N_ELEMENTS(gauss) EQ 0 THEN gauss=1
  IF NOT KEYWORD_SET(inverse) THEN BEGIN
    temp1=TLI_ISVECTOR(x, single_sample=xt)  ; Temporary x.
    temp2=TLI_ISVECTOR(y, single_sample=yt)  ; Temporary y.
    temp3=TLI_ISVECTOR(z, single_sample=zt)  ; Temporary z.
    IF temp1+temp2+temp3 NE 3 THEN Message, 'Error: TLI_LSFIT, input params should be vectors.'
  ENDIF ELSE BEGIN
    IF N_ELEMENTS(x) EQ 1 THEN BEGIN
      xt=x
      yt=y
    ENDIF ELSE BEGIN
      temp1=TLI_ISVECTOR(x, single_sample=xt)  ; Temporary x.
      temp2=TLI_ISVECTOR(y, single_sample=yt)  ; Temporary y.
    ENDELSE
  ENDELSE
  
  IF N_ELEMENTS(order) EQ 1 THEN BEGIN  ; Using polinomial fit .
  
    ; Observation for LS estimation: BA=L+del,
    ; where A=(B'PB)^(-1) * B'PL
    ; del= BA-L
    ; D(A)= - (B'PB)^(-1) * B'P * del
    FOR i=0, order DO FOR j=0, order DO BEGIN      ; Create the design matrix
      IF (i+j) GT order THEN CONTINUE
      
      IF i EQ 0 AND j EQ 0 THEN BEGIN
        b=DINDGEN(1, N_ELEMENTS(xt))+1D          ; Initialization
      ENDIF ELSE BEGIN
        b=[b, xt^i * yt^j]
      ENDELSE
    ENDFOR
    
    Case KEYWORD_SET(inverse) OF
    
      0: BEGIN                         ; Polyfit
      
        temp=INVERT((TRANSPOSE(b) ## b ), status)
        IF status NE 0 THEN BEGIN
          Print, 'ERROR: tli_lsfit, Singular array, no inversion exists.'
          RETURN, 0
        ENDIF
        
        mtx= temp ## TRANSPOSE(b) ; (B'PB)^(-1) * B'
        coefs_all=mtx ## zt                                   ; All the coefs.
        
        fit_err= b##coefs_all-zt                               ; Error of zt.
        coefs_err=-mtx##fit_err                                ; Error of the coefs
        
        fit_sig=SQRT(MEAN(fit_err^2))
        RETURN, b##coefs_all
      END
      
      1: BEGIN  ; Inverse the LS estimation.
        ; Check the consistency of the input params.
        IF N_ELEMENTS(coefs_all) NE TLI_NCOEFS(order) THEN Message, 'Error: TLI_LSFIT,'$
          +STRING(13b)+'the input coefs is not consistent with the given polynomial fit method.'
          
        z=b##(coefs_all)
        RETURN, z
        
      END
      ELSE:
    ENDCASE
  ENDIF
  
  IF KEYWORD_SET(gauss) THEN BEGIN
  
    Case KEYWORD_SET(inverse) OF
      0: BEGIN
        x_g=REFORM(xt, SQRT(N_ELEMENTS(xt)), SQRT(N_ELEMENTS(xt)))
        y_g=REFORM(yt, SQRT(N_ELEMENTS(yt)), SQRT(N_ELEMENTS(yt)))
        z_g=REFORM(zt, SQRT(N_ELEMENTS(zt)), SQRT(N_ELEMENTS(zt)))
        
        result= GAUSS2DFIT(z_g,coefs_all, x_g[*, 0], TRANSPOSE(y_g[0, *]))
        
        fit_err=result-zt
        fit_sig=SQRT(MEAN(ABS(fit_err)))
        status=1
        RETURN, result
      END
      1: BEGIN
        result=TLI_GAUSS(coefs_all, xt, yt)
        RETURN, result
      END
    ENDCASE
    
    
    
    
  ;  ; a[0]+a[1]x+a[2]y+a[3]x^2+a[4]y^2
  ;    e=TLI_E()
  ;    b=[DINDGEN(1, N_ELEMENTS(xt))+1, xt, yt, xt^2, yt^2]
  ;    Case KEYWORD_SET(inverse) OF
  ;      0: BEGIN  ; Fit
  ;
  ;        temp=INVERT((TRANSPOSE(b) ## b ), status)
  ;        IF status NE 0 THEN BEGIN
  ;          Print, 'ERROR: tli_lsfit, Singular array, no inversion exists.'
  ;          RETURN, 0
  ;        ENDIF
  ;
  ;        mtx= temp ## TRANSPOSE(b) ; (B'PB)^(-1) * B'
  ;
  ;        lnz=ALOG(zt)
  ;
  ;        coefs_all=mtx ## lnz                                   ; All the coefs.
  ;
  ;        fit_err= e^(b##coefs_all-lnz)                               ; Error of zt.
  ;        coefs_err=-mtx##fit_err                                ; Error of the coefs
  ;
  ;        fit_sig=SQRT(MEAN(fit_err^2))
  ;        RETURN, e^(b##coefs_all)
  ;      END
  ;      1: BEGIN
  ;        ; Check the consistency of the input params.
  ;        IF N_ELEMENTS(coefs_all) NE 5 THEN Message, 'Error: TLI_LSFIT,'$
  ;          +STRING(13b)+'the input coefs is not consistent with the given polynomial fit method.'
  ;
  ;        z=e^(b##(coefs_all))
  ;        RETURN, z
  ;      END
  ;
  ;    ENDCASE
    
  ENDIF
  
  
  
END