; Chapter04MyFactorial.pro
FUNCTION  Chapter04MyFactorial,  n
y = 1LL
IF  n EQ 0  THEN BEGIN
    y = 1LL
ENDIF ELSE BEGIN
    FOR  i = 1, n  DO  BEGIN
       y = y * i
    ENDFOR
ENDELSE
RETURN,  y
END