; ChapterTable991For.pro
PRO ChapterTable991For
FOR  i = 1, 9  DO  BEGIN
　　FOR j = 1, i DO BEGIN
　　　　PRINT, j, '*', i, '=', i*j, FORMAT='(4X, I1, 1X, A1, 1X, I1, 1X, A1, 1X, I2, $)'
　　ENDFOR
　　PRINT
ENDFOR
END
