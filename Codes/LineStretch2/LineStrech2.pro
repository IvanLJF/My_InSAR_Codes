;+----------------------------------------------------------------------------------
;| 目的: 对数据进行百分之二的线性拉伸
;| 作者: Huxz
;| 日期: 2007-01
;+----------------------------------------------------------------------------------
Function LineStrech2, data, minv=minv, maxv=maxv, onlyMinMax=onlyMinMax

	Compile_Opt StrictArr

	CATCH, Error_status
    IF Error_status NE 0 THEN BEGIN
       CATCH, /CANCEL
       minv = Min(data, max=maxv, /nan)
       Return,  Bytscl(data, /nan)
    ENDIF

	dimens=Size(data,/dimensions)
    n_e = Long(dimens[0]*dimens[1])
    MinMaxCount=n_e*0.02 ; 98%的个数值

	if N_Elements(minv) eq 0 then begin
	    minvs = mg_n_smallest(data, MinMaxCount) ; 找到最小的98%的个数值
	    minv=max(data[minvs], /nan) ; 取其中最大的
	endif

	if N_Elements(maxv) eq 0 then begin
	    maxvs = mg_n_smallest(data, MinMaxCount, /largest) ; 找到最大的98%的个数值
	    maxv=min(data[maxvs], /nan) ; 取其中最小的
	endif
	; 仅输出百分2线性的拉伸范围
	if Keyword_Set(onlyMinMax) then begin
		Return, -1
	endif

    data = Bytscl(data, min=minv, max=maxv, top=255, /nan)

    Return, data

End