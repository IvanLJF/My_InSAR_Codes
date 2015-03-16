; Chapter04MS5Function.pro
PRO   Chapter04MS5Function
READ, PROMPT="«Î ‰»ÎX = ?", x
IF  x LE 3  THEN  BEGIN
    IF  x LE -6  THEN  BEGIN
       y = 3 * x ^ 2 - x + 1
    ENDIF  ELSE  BEGIN
       IF  x LE -3  THEN  BEGIN
         y = 5 * x ^ 2 - 3 * x + 1
       ENDIF  ELSE  BEGIN
         y = 7 * x ^ 2
       ENDELSE
    ENDELSE
ENDIF  ELSE  BEGIN
    IF  x LE 6  THEN  BEGIN
       y = 5 * x ^ 2 + 3 * x + 1
    ENDIF  ELSE  BEGIN
       y = 3 * x ^ 2 + x + 1
    ENDELSE
ENDELSE
PRINT, "y = ",  y
END