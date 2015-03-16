; Chapter04Graphics.pro
PRO  Chapter04Graphics
FOR  i = 1, 15  DO  BEGIN
    StringArray = REPLICATE("*",  i)
    MyString = STRJOIN(StringArray)
    PRINT, MyString
ENDFOR
END