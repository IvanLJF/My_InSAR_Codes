; Chapter01MainSum.pro
;--------------------------------------------------------------
@Chapter01IncludeNumber.inc
Sum1 = Chapter01FunctionSum(u, v)
Sum2 = Chapter01FunctionSum(w, x)
Sum = Chapter01FunctionSum(Sum1, Sum2)
PRINT, u , ' + ', v , ' + ', w , ' + ' , x , ' = ' , Sum
END
;--------------------------------------------------------------