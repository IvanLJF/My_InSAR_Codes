; Chapter01ProcedureFileSum.pro

;--------------------------------------------------------------
; Chapter01FunctionSum.pro
FUNCTION Chapter01FunctionSum, u, v
    w = u + v
    RETURN, w
END
;--------------------------------------------------------------
; Chapter01ProcedureFileSum.pro
PRO Chapter01ProcedureFileSum
    @Chapter01IncludeNumber.inc
    Sum1 = Chapter01FunctionSum(u, v)
    Sum2 = Chapter01FunctionSum(w, x)
    Sum = Chapter01FunctionSum(Sum1, Sum2)
    PRINT, u , ' + ', v , ' + ', w , ' + ' , x , ' = ' , Sum
END
;--------------------------------------------------------------