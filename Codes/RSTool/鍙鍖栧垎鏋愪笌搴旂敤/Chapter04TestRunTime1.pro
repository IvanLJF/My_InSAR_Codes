; Chapter04TestRunTime1.pro
PRO Chapter04TestRunTime1
¡¡¡¡MyVariable = DIST(1000, 1000)
¡¡¡¡Sum = 0.0
¡¡¡¡StartTime = SYSTIME(/SECONDS)
¡¡¡¡FOR i = 0, 999 DO BEGIN
¡¡¡¡¡¡¡¡FOR j = 0, 999 DO BEGIN
¡¡¡¡¡¡¡¡¡¡¡¡Sum = Sum + MyVariable[i,j]
¡¡¡¡¡¡¡¡ENDFOR
¡¡¡¡ENDFOR
¡¡¡¡EndTime = SYSTIME(/SECONDS)
¡¡¡¡PRINT, 'Êý×éµÄºÍ£º', Sum
¡¡¡¡PRINT, 'Ê¹ÓÃÊ±¼ä£º' , EndTime - StartTime
END