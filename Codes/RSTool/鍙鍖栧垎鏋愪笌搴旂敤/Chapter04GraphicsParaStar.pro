; Chapter04GraphicsParaStar.pro
FUNCTION  Chapter04GraphicsParaStar, n
　　　TempString1 = STRJOIN(REPLICATE(' ', n,1))
　　　TempString2 = STRJOIN(REPLICATE('*', 16,1))
　　　RETURN, TempString1 + TempString2
END
