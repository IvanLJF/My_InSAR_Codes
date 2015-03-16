; Chapter04TestSearchPath.pro
PRO  Chapter04TestSearchPath
　　MyPath = 'D:\IDL\JTIDL60'
　　MyExist = STRPOS( !Path, MyPath)
　　IF  MyExist NE -1  THEN  BEGIN
　　　　PRINT,  '目录在搜索路径中！'
　　　　PRINT,  !PATH
　　ENDIF  ELSE  BEGIN
　　　　PRINT,  '目录不在搜索路径中！'
　　　　yn = ' '
　　　　READ,  PROMPT = "添加目录吗？（Y or N）：",  yn
　　　　yn = STRUPCASE(yn)
　　　　IF  yn EQ "Y"  THEN  BEGIN
　　　　　　!PATH = !PATH + ';' + MyPath
　　　　　　PRINT, '目录已经添加到搜索路径中！'
　　　　　　PRINT,  !PATH
　　　　ENDIF  ELSE  BEGIN
　　　　　　PRINT, '目录没有添加到搜索路径中！'
　　　　ENDELSE
　　ENDELSE
END
