FUNCTION TLI_CORR, small, large
  
  ON_ERROR, 2
  COMPILE_OPT idl2
  
;  large= COMPLEX([INDGEN(10,10)],[INDGEN(10,10)])
;  small= COMPLEX([[10,11,12],[20,21,22],[30,31,32]],[[10,11,12],[20,21,22],[30,31,32]])  
  szlarge= SIZE(large,/DIMENSIONS)
  szsmall= SIZE(small,/DIMENSIONS)
  
  IF szsmall[0] GT szlarge[0] OR szsmall[1] GT szlarge[1] THEN BEGIN
    result= DIALOG_MESSAGE('Please let the small patch be the kernel.')
    RETURN, -1
  ENDIF ELSE BEGIN
    
    szwinss= FLOOR(szsmall[0]/2)
    szwinsl= FLOOR(szsmall[1]/2)
    szwinls= FLOOR(szlarge[0]/2)
    szwinll= FLOOR(szlarge[1]/2)
    result= FLTARR(szlarge); Temp arr to store c_correlation.
    FOR i= szwinss, szlarge[0]-szwinss-1 DO BEGIN
      
      FOR j= szwinsl, szlarge[1]-szwinsl-1 DO BEGIN
        large_sub= large[(i-szwinss): (i+ szwinss), (j-szwinsl):(j+szwinsl)]
        large_m= MEAN(large_sub)
        small_m= MEAN(small)
        numerator= TOTAL((large_sub-large_m)*(small-small_m))
        denomilator= (TOTAL((large_sub- large_m)^2)*TOTAL((small- small_m)^2))^0.5
;        numerator= large_sub* CONJ(small)
;        numerator= ABS(TOTAL(numerator))
;        denomilator= (TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2))^0.5
        result[i,j]= numerator/denomilator
      ENDFOR
    ENDFOR
  ENDELSE 
  RETURN, result
END