; Chapter04SFunction.pro
PRO Chapter04SFunction
READ, PROMPT='«Î ‰»ÎX = ?', x
IF  x LE 0 THEN  BEGIN
    y = 5 * x ^ 2 + 9
ENDIF  ELSE  BEGIN
    y = 5 * x ^ 2 - 9
ENDELSE
    PRINT, 'y = ',  y
END
