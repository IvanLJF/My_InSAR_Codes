; Chapter04SumEven1000.pro
PRO Chapter04SumEven1000
sum = 0L
i = 1
WHILE  i LE 1000  DO  BEGIN
    IF   i MOD 2  THEN BEGIN
       i++
       CONTINUE
    ENDIF
    sum = sum + i
    i++
ENDWHILE
PRINT,  ' 2 + 4 + бн + 1000 = ',  sum
END