; Chapter04TestON_ERROR.pro
PRO  Chapter04TestON_ERROR
　　Number = 0D
　　ValidFlag = 0
　　WHILE ValidFlag EQ 0 DO BEGIN
　　　　ON_IOERROR, ErrorLabel
　　　　READ, PROMPT=' 请输入一个数：' , Number
　　　　ValidFlag = 1
　　　　PRINT, '你输入的数据' , Number , '有效！'
　　　　ErrorLabel: IF  ~ ValidFlag THEN BEGIN
　　　　　　　　　　　PRINT, '你输入的数据无效！'
　　　　　　　　　ENDIF
　　ENDWHILE
END

