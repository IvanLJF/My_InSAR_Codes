;+-------------------------------------------------------------------------------------------------
;| array union
;+-------------------------------------------------------------------------------------------------
Function SetUnion, a, b
	;
	Compile_Opt StrictArr

    if N_Elements(a) eq 0 then Return, b    ;A union NULL = a
    if N_Elements(b) eq 0 then Return, a    ;B union NULL = b
    Return, Where(Histogram([a,b], OMin = omin)) + omin ; Return combined set
End
;+-------------------------------------------------------------------------------------------------
;| array intersection
;+-------------------------------------------------------------------------------------------------
Function SetIntersection, a, b
	;
	Compile_Opt StrictArr

	minab = Min(a, Max=maxa) > Min(b, Max=maxb) ;Only need intersection of ranges
	maxab = maxa < maxb
	;
	; If either set is empty, or their ranges don't intersect: result = NULL.
	if maxab lt minab or maxab lt 0 then Return, -1
	r = Where((Histogram(a, Min=minab, Max=maxab) ne 0) and  $
	         (Histogram(b, Min=minab, Max=maxab) ne 0), count)

	if count eq 0 then Return, -1 else Return, r + minab
End
;+-------------------------------------------------------------------------------------------------
;| array difference
;+-------------------------------------------------------------------------------------------------
Function SetDifference, a, b
	;
	Compile_Opt StrictArr
	;
	; = a and (not b) = elements in A but not in B
	mina = Min(a, Max=maxa)
	minb = Min(b, Max=maxb)
	if (minb gt maxa) or (maxb lt mina) then Return, a ;No intersection...
	r = Where((Histogram(a, Min=mina, Max=maxa) ne 0) and $
	         (Histogram(b, Min=mina, Max=maxa) eq 0), count)
	if count eq 0 Then RETURN, -1 else Return, r + mina
End
;+-------------------------------------------------------------------------------------------------
;| 数组取交集，并集，差集
;| 算法来源自IDL Goole讨论组
;| 作者：Huxz
;|       The Chinese University of Hong Kong, Institute of Space and Earth Information Science.
;|  	 http://www.iseis.cuhk.edu.hk
;|       http://hi.baidu.com/huxz
;| 示例：
;| a = [2,4,6,8]
;| b = [6,1,3,2]
;| FW_Array_UID(a, b, /intersection) = [ 2, 6] ; Common elements, 交集
;| FW_Array_UID(a, b, /union) = [ 1, 2, 3, 4, 6, 8]  ; Elements in either set, 并集
;| FW_Array_UID(a, b, /difference) = [ 4, 8]         ; Elements in A but not in B, 差集
;| FW_Array_UID(a,[3,5,7]) = -1      ; Null Set
;+-------------------------------------------------------------------------------------------------
Function FW_Array_UID, a, b, union=union, intersection=intersection, difference=difference
	;
	Compile_Opt StrictArr

	if Keyword_Set(union) then begin
		Return, SetUnion(a, b)
	endif

	if Keyword_Set(intersection) then begin
		Return, SetIntersection(a, b)
	endif

	if Keyword_Set(difference) then begin
		Return, SetDifference(a, b)
	endif
End
