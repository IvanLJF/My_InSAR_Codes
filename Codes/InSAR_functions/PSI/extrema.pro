; 程序名称:
;	EXTREMA
;
; 程序目的:
;	返回时间序列里局部极值点的位置
;
; 类别:
;	时间序列分析
;
; 调用方法:
;	Result = EXTREMA( Data )
;
; 输入:
;	Data:  整型或浮点型向量
;
; 参数设置:
;	FLAT:  返回所有极值点位置的标记参数，默认返回中间位置
;		
;	ENDS:  设置此参数端点将被记录为极值点，默认情况下端点被记录为下一个极值点之外的点 
;
; 可选输出:
;	MAXIMA:  返回极大值点的位置.
;	MINIMA:  返回极小值点的位置.
;
; 输出:
;	Result:  极值点位置
;
; 处理过程:
;	对每一个点，比较与其左右相邻的两个值来判断给定的点是否极值点
;
; 示例:
;	定义输入数据向量
;	  data = [1,2,3,2]
;	找出极值点的位置
;	  result = extrema( data )
;	结果为 [ 0, 2 ]
; 注：此函数没有对时间序列的端点进行处理，在EMD程序中将对端点效应进行处理
;***********************************************************************

FUNCTION EXTREMA, $
	Data, $
	FLAT=flatopt, ENDS=endsopt, $
	MAXIMA=maxima, MINIMA=minima

;***********************************************************************
; 定义常量和操作

; 取时间序列的长度
nx = n_elements( data )

; 判断是否需要长整型来表示索引数
if VAR_TYPE( nx ) eq 2 then begin
  idtype = 1
endif else begin
  idtype = 1l
endelse

; 默认方式添加端点，将原序列的端点外延，没有引入其他数据
x = [ data[0*idtype], data, data[nx-1] ]

; 设置操作参数
flatopt = keyword_set( flatopt )
endsopt = keyword_set( endsopt )

; 初始化存放极大值和极小值点位置的向量，初值为零，后续处理中将被覆盖
; 
maxima = [ 0 ]
minima = [ 0 ]

;***********************************************************************
; 探测极值点的位置

; 对所有非端点的点位进行遍历
for i = idtype, nx do begin

  ; 找出左边的临近点的值或者单调区间的左边界
  idleft = max( where( x[0*idtype:i-1] ne x[i] ) )
  ; 检查没有左邻近点的情况
  if idleft eq -1 then idleft = 0
  ; 找出有边的临近点的值或者单调区间的右边界
  idright = i + 1 + min( where( x[i+1:nx+1] ne x[i] ) )
  ; 检查没有右邻近点的情况
  if idright eq i then idright = nx + 1

  ; 判断是否记录一个极值点
  check = 1
  if not( flatopt ) then begin
    if i ne ( idleft + idright ) / 2 then check = 0
  endif
  ; 
  if check then begin
    ; 检查极小值点
    if ( x[i] le x[idleft] ) and ( x[i] le x[idright] ) then begin
      minima = [ minima, i - 1 ]
    endif else begin
      ; 检查无极小值点的单调区间
      if flatopt and ( x[i] eq x[i-1] ) and ( x[i] eq x[i+1] ) then begin
        minima = [ minima, i - 1 ]
      endif
    endelse
    ; 检查极大值点
    if ( x[i] ge x[idleft] ) and ( x[i] ge x[idright] ) then begin
      maxima = [ maxima, i - 1 ]
    endif else begin
      ; 检查无极大值点的单调区间
      if flatopt and ( x[i] eq x[i-1] ) and ( x[i] eq x[i+1] ) then begin
        maxima = [ maxima, i - 1 ]
      endif
    endelse
  endif

endfor

; 计数极大极小值点的数量（不包括初始值）
nmaxima = n_elements( maxima ) - 1
nminima = n_elements( minima ) - 1

; 从极大值极小值向量中移除初始值
maxima = maxima[1*idtype:nmaxima]
minima = minima[1*idtype:nminima]

; 检查是否记录非极值端点
if not( endsopt ) then begin
  ; 检查第一点是否极小值
  if ( minima[0*idtype] eq 0 ) and ( nminima gt 1 ) then begin
    ; 找出临近的不同极小值
    id = min( where( data[minima] ne data[0*idtype] ) )
    ; 与第一点点对比
    if data[minima[0*idtype]] gt data[minima[id]] then begin
      ; 移除初始极小值
      id = min( where( data[minima] ne data[0*idtype] ) )
      minima = minima[id:nminima-1]
      nminima = n_elements( minima )
    endif
  endif
  ; 检查第一点是否极大值点
  if ( maxima[0*idtype] eq 0 ) and ( nmaxima gt 1 ) then begin
    ; 找出临近的不同极大值
    id = min( where( data[maxima] ne data[0*idtype] ) )
    ; 与第一点对比
    if data[maxima[0*idtype]] lt data[maxima[id]] then begin
      ; 移除初始极大值
      id = min( where( data[maxima] ne data[0*idtype] ) )
      maxima = maxima[id:nmaxima-1]
      nmaxima = n_elements( maxima )
    endif
  endif
  ; 检查最后一点是否极小值点
  if ( minima[nminima-1] eq nx - 1 ) and ( nminima gt 1 ) then begin
    ; 找出临近的不同极小值
    id = max( where( data[minima] ne data[nx-1] ) )
    ; 与最后一点对比
    if data[minima[nminima-1]] gt data[minima[id]] then begin
      ; 移除初始极小值
      id = max( where( data[minima] ne data[nx-1] ) )
      minima = minima[0*idtype:id]
      nminima = n_elements( minima )
    endif
  endif
  ; 检查最后一点是否极大值点
  if ( maxima[nmaxima-1] eq nx - 1 ) and ( nmaxima gt 1 ) then begin
    ; 找出临近的不同极大值
    id = max( where( data[maxima] ne data[nx-1] ) )
    ; 与最后一点对比
    if data[maxima[nmaxima-1]] lt data[maxima[id]] then begin
      ; 移除初始极大值
      id = max( where( data[maxima] ne data[nx-1] ) )
      maxima = maxima[0*idtype:id]
      nmaxima = n_elements( maxima )
    endif
  endif
endif

; 定义极值点输出变量
extrema = [ minima, maxima ]
; 移除重复值(单调区间可能出现)
check = 0
ctr = 0 * idtype
nextrema = n_elements( extrema )
while check eq 0 do begin
  id = where( extrema ne extrema[ctr], nid )
  if nid ne nextrema - 1 then begin
    extrema = extrema[[ctr,id]]
    nextrema = nid + 1
  endif
  ctr = ctr + 1
  if ctr ge nextrema - 1 then check = 1
endwhile
; 为极值点位置排序Sort extrema locations
id = sort( extrema )
extrema = extrema[id]

;***********************************************************************
; 返回结果

return, extrema
END
