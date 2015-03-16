; Chapter04Algrithm.pro
PRO  Chapter04Algrithm
yn = " "
REPEAT  BEGIN
　　READ,  PROMPT = "请选择运算方式（1- 加, 2- 减, 3- 乘 ）：", n
　　IF  n EQ 1 ||  n EQ 2 ||  n EQ 3  THEN BEGIN
　　　　READ,  PROMPT = "请输入X = ?", x
　　　　READ,  PROMPT = "请输入Y = ?", y
　　　　CASE  n  OF
　　　　　　1: PRINT, x, '+', y, '=', Chapter04Plus(x, y)
　　　　　　2: PRINT, x, '-', y, '=', Chapter04Minus(x, y)
　　　　　　3: PRINT, x, '*', y, '=', Chapter04Product(x, y)
　　　　ENDCASE

　　ENDIF ELSE BEGIN
　　　　PRINT,  " 选择运算方式错误！"
　　ENDELSE
　　READ, PROMPT = "继续计算吗?（Y or N）：",  yn
　　yn = STRUPCASE(yn)
ENDREP  UNTIL  yn  NE  "Y"
END