; Chapter04MS6Function.pro
PRO Chapter04MS6Function
READ, PROMPT="«Î ‰»ÎX = ?", x
CASE  1  of
       x LT 0 :  BEGIN
            y = 2 *  x + 1
                    END
       x LT 1:  BEGIN
            y = 3 *  x + 2
                   END
       x LT 2:  BEGIN
            y = 4 *  x +3
                   END
       x LT 3:  BEGIN
            y = 5 *  x + 4
                   END
        x LT 4:  BEGIN
            y = 6 *  x + 7
                   END
       ELSE:  BEGIN
            y = 8 * x * x + 1
                   END
ENDCASE
PRINT, "  f ( x ) = ",  y
END