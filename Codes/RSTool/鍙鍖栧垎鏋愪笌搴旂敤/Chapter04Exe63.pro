; Chapter04Exe63.pro
PRO Chapter04Exe63
　　M = 3
　　WHILE M LT 10 DO BEGIN
　　　　N = 2
　　　　WHILE N LE M - 1 DO BEGIN
　　　　　　IF M MOD N EQ 0 THEN BEGIN
　　　　　　　　BREAK
　　　　　　ENDIF
　　　　　　IF N EQ M - 1 THEN BEGIN
　　　　　　　　PRINT, M
　　　　　　ENDIF
　　　　　　N = N + 1
　　　　ENDWHILE
　　　　M = M + 1
　　ENDWHILE
END
