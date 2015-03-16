; Chapter04MMul.pro
PRO  Chapter04MMul
yn = " "
REPEAT  BEGIN
    READ,  PROMPT = "请输入X = ?", x
    READ,  PROMPT = "请输入Y = ?", y
    PRINT,  x ,  " * " ,  y ,  " = " ,  x  *  y
    READ,  PROMPT = "继续计算吗？（Y or N）：",  yn
    yn = STRUPCASE(yn)
ENDREP  UNTIL  yn EQ "N"
END