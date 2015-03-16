; Chapter04MSum.pro
PRO  Chapter04MSum
yn = " "
WHILE  1  DO  BEGIN
    READ,  PROMPT = "请输入X = ?", x
    READ,  PROMPT = "请输入Y = ?", y
    PRINT,  x ,  " + " ,  y ,  " = " ,  x + y
    READ,  PROMPT = "继续计算吗？（Y or N）：",  yn
    yn = STRUPCASE(yn)
    IF  yn EQ "Y"  THEN  BEGIN
       CONTINUE
    ENDIF  ELSE  BEGIN
       BREAK
    ENDELSE
ENDWHILE
END