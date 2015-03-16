; Chapter04Sum1000.pro
PRO Chapter04Sum1000
sum = 0L
i = 1
WHILE  i LE 1000  DO  BEGIN
    sum = sum + i
    i++
ENDWHILE
PRINT,  ' 1 + 2 + бн + 1000 = ',  sum
END