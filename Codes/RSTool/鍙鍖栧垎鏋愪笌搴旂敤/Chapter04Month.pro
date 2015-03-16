; Chapter04Month.pro
PRO Chapter04Month

READ, PROMPT="请输入月份（1 ,  ...  , 12）：", m
CASE  m  of
       1 :  PRINT, "January"
       2 :  PRINT, "February"
       3 :  PRINT, "March"
       4 :  PRINT, "April"
       5 :  PRINT, "May"
       6 :  PRINT, "June"
       7 :  PRINT, "July"
       8 :  PRINT, "August"
       9 :  PRINT, "September"
       10 :  PRINT, "October"
       11 :  PRINT, "November"
       12 :  PRINT, "December"
       ELSE : PRINT, "输入的月份无效!"

ENDCASE
END
