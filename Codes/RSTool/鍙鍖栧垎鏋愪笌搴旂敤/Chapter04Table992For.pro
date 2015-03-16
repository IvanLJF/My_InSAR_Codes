; Chapter04Table992For.pro

PRO Chapter04Table992For
i = 1
WHILE 1 DO  BEGIN
    IF i GT 9 THEN GOTO, MyLabel
¡¡¡¡FOR j = 1, i DO BEGIN
¡¡¡¡¡¡¡¡PRINT, j, '*', i, '=', i*j, FORMAT='(4X, I1, 1X, A1, 1X, I1, 1X, A1, 1X, I2, $)'
¡¡¡¡ENDFOR
¡¡¡¡PRINT
    i++
ENDWHILE
MyLabel: PRINT, '¾Å¾Å³Ë·¨±íÊä³ö½áÊø£¡'
END
