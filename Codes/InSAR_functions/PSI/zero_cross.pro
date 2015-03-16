; 程序名称:
;	ZERO_CROSS
;
; 程序目的:
;	计算时间序列过零值的数目
;
; 类别:
;	时间序列分析
;
; 调用方法:
;	Result = ZERO_CROSS( Data )
;
; 输入:
;	Data:  整型或浮点型向量
;
; 可设置参数:
;	SUBTRACT_MEAN:  设置此参数，在进行分析前全局均值将被从时间序列中减去
;
; 可选择的输出:
;	POS:  返回过零点前一个点的位置
;
; 输出:
;	结果:  返回过零点的数目
;
;
; PROCEDURE:
;	此函数循环比较被标记的临近点，从而探测出过零值
;
; 示例:
;	定义数据向量
;	  data = [-1,2,3,-1,2]
;	找出过两点的数量
;	  result = zero_cross( data )
;	结果为 3.


;***********************************************************************

FUNCTION ZERO_CROSS, $
	Data, $
	SUBSTRACT_MEAN=subtract_meanopt, $
	POS=pos

;***********************************************************************
; 常量和操作

; 时间序列的长度
nx = n_elements( data )

; 判断是否需要长整型来表示索引数
if VAR_TYPE( nx ) eq 2 then begin
  idtype = 1
endif else begin
  idtype = 1l
endelse

x = data
; 如果需要的话减去均值
if keyword_set( subtract_meanopt ) then x = x - mean( x )

; 初始化记录过零点数目的变量
nzeroes = 0

; 初始化过零点位置记录向量
pos = [ -1 ]

;***********************************************************************
; 探测过零点的位置

; 计算临近值的乘积，确定标记量
signx = x[0*idtype:nx-2] * x[1*idtype:nx-1]

; 对计算结果进行遍历
for i = 0 * idtype, nx - 2 do begin

  ; 如果标记量为负，则参与计算的两个值正负相反，则在它们之间存在一个过零值
  if signx[i] lt 0 then begin
    ; 添加过零点到列表中
    nzeroes = nzeroes + 1
    pos = [ pos, i ]

  ; 如果临近值乘积为零，那么可能在后续处理中存在过零点
  ; 同时确保不在单调的零值区间内（还未对此值进行计数）
  endif else if ( signx[i] eq 0 ) and ( x[i] ne 0 ) then begin
    ; 找出下一个非零值
    id = min( where( x[i+1:nx-1] ne 0, nid ) )
    ; 判断满足条件的值是否存在
    if nid ne 0 then begin
      ; 如果零值区间末端的两个值用用相反的正负标志则可判定一个过零点的存在
      
      if x[i] * x[i+1+id] lt 0 then begin
        ; 添加找出的过零点到列表中
        ; 注意记录下零值区间中间位置
        nzeroes = nzeroes + 1
        pos = [ pos, i + ( id + 1 ) / 2 ]
      endif
    endif
  endif
endfor

; 从位置向量中移除初始值
if nzeroes ne 0 then pos = pos[1*idtype:nzeroes]

;***********************************************************************
; 返回结果

return, nzeroes
END
