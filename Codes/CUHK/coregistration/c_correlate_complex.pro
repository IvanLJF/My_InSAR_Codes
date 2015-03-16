;-
;- Purpose:
;-    Calculate cross-correlation between a small patch and a large patch
;- Calling Sequence:
;-    result= C_CORRELATE_COMPLEX(small, large)
;- Inputs:
;-    small: Kernel
;-    large: Data to be filtered.
;- Optional Input Parameters:
;-    None.
;- Keyword Input Parameters:
;-    None
;- Outputs:
;-    Correlation between small and large
;- Commendations:
;-    Make sure small is really a small one.
;- Example:
;-    large= COMPLEX([INDGEN(10,10)],[INDGEN(10,10)])
;-    small= COMPLEX([[10,11,12],[20,21,22],[30,31,32]],[[10,11,12],[20,21,22],[30,31,32]])
;-    result= C_CORRELATE_COMPLEX(small, large)
;- Modification History:
;-    13/02/2012: Written by T. Li @ InSAR Team in CUHK

FUNCTION C_CORRELATE_COMPLEX, small, large
  
  COMPILE_OPT idl2
  IF N_PARAMS() NE 2 THEN result= DIALOG_MESSAGE('Usage:'+STRING(13b)+'     result=C_CORRELATE_COMPLEX(small, large)')

  ON_ERROR, 2

;  large= COMPLEX([INDGEN(10,10)],[INDGEN(10,10)])
;  small= COMPLEX([[10,11,12],[20,21,22],[30,31,32]],[[10,11,12],[20,21,22],[30,31,32]])
  szlarge= SIZE(large,/DIMENSIONS)
  szsmall= SIZE(small,/DIMENSIONS)

  IF szsmall[0] GT szlarge[0] OR szsmall[1] GT szlarge[1] THEN BEGIN
    result= DIALOG_MESSAGE('Please let the small patch be the kernel.')
    RETURN, 0
  ENDIF ELSE BEGIN

    szwinss= FLOOR(szsmall[0]/2)
    szwinsl= FLOOR(szsmall[1]/2)
    szwinls= FLOOR(szlarge[0]/2)
    szwinll= FLOOR(szlarge[1]/2)
    result= FLTARR(szlarge); Temp arr to store c_correlation.
    FOR i= szwinss, szlarge[0]-szwinss-1 DO BEGIN

      FOR j= szwinsl, szlarge[1]-szwinsl-1 DO BEGIN
        large_sub= large[(i-szwinss): (i+ szwinss), (j-szwinsl):(j+szwinsl)]

;        result(i,j)= (TOTAL(large_sub*CONJ(small))/(TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2)))^0.5
        numerator= large_sub* CONJ(small)
        numerator= ABS(TOTAL(numerator))
        denomilator= (TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2))^0.5
        result[i,j]= numerator/denomilator
      ENDFOR
    ENDFOR
  ENDELSE
  RETURN, result

END