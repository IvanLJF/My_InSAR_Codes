; Chapter01ProcedureFunctionSum.pro
PRO Chapter01ProcedureFunctionSum
READ, PROMPT="«Î ‰»ÎX = ?", x
READ, PROMPT="«Î ‰»ÎY = ?", y
Sum = Chapter01FunctionSum(x, y)
PRINT, x , "  +  " , y , "  = ", Sum
END
