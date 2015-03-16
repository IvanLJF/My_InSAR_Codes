; Chapter04GraphicsMain.pro
PRO  Chapter04GraphicsMain
　　　i = 1
　　　WHILE  i LE 15 DO BEGIN
　　　　　　TempString1 = STRJOIN(REPLICATE(' ', i,1))
　　　　　　TempString2 = TempString1 + Chapter04GraphicsStar()
　　　　　　PRINT, TempString2
　　　　　　i =i +1
　　　ENDWHILE
END