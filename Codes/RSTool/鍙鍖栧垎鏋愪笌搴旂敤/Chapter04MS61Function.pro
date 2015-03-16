; Chapter04MS61Function.pro
PRO Chapter04MS61Function
READ, PROMPT="«Î ‰»ÎX = ?", x
SWITCH   1  of
       x LT 0 :  BEGIN
            y = 2 *  x + 1
            BREAK
                    END
       x LT 1:  BEGIN
            y = 3 *  x + 2
            BREAK
                   END
       x LT 2:  BEGIN
            y = 4 *  x +3
            BREAK
                   END
       x LT 3:  BEGIN
            y = 5 *  x + 4
            BREAK
                   END
        x LT 4:  BEGIN
            y = 6 *  x + 7
            BREAK
                   END
       ELSE:  BEGIN
            y = 8 * x * x + 1
                   END
ENDSWITCH
PRINT, "  f ( x ) = ",  y
END