; Chapter04Table99.pro
PRO Chapter04Table99
    i = 1
    WHILE  i  LT 10  DO  BEGIN
       j = 1
       WHILE  j LE i  DO BEGIN
           PRINT, j, '*', i, '=' ,i * j, FORMAT = '(4X,I1,1X,A1,1X,I1,1X,A1,1X,I2,$)'
           j = j +1
       ENDWHILE
       PRINT, FORMAT = '(/)'
       i = i + 1
    ENDWHILE
END