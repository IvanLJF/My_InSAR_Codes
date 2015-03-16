; 程序名称:EMD
; 程序目的:用经验模式分解方法估算每个模态函数（IMF），将不同频率的信号分离，输入数据必须是向量
;
; 类别:时间序列分析
;
; 调用方法:Result = EMD( Data )
;
; 输入:
;	Data:  包含待分析数据的浮点型向量
;
; 可设置参数:
;	QUEK:  设置此参数后，程序将通过判断连续两次提取所得结果的差异判断是否终止
;	SHIFTFACTOR:  程序将连续两次得到的结果之间的标准方差与其对比，默认值为 0.3
;	SPLINEMEAN:  设置此参数后, 程序将通过对极值点均值拟合的方式估计局部均值，默认为使用上下包络线的均值
;	VERBOSE:  设置此参数程序将输出一些中间结果和错误提示
;
;	ZEROCROSS:  设置此参数后程序将通过比较极值点与过零点的数目决定是否输出IMFs（二者相差最多为1），默认的判定条件是
;		检核连续两次提取结果间的差值
;
; 输出:
;	imf:  返回一个包含所有IMF的浮点型矩阵，一行为一个IMF分量
;
; 调用外部函数:
;	EXTREMA.pro（返回局部极值点的位置）
;	VAR_TYPE.pro（判断数据类型）
;	ZERO_CROSS.pro（获取过零点的数量）
;
; 此EMD函数利用迭代方法将给定的时间序列分解为本征模函数
;
; 示例:
;	生成时间序列DATA，DATA=randomn（5,100,1）
;	imf = EMD( DATA )       

FUNCTION EMD, $
	Data, $
	SHIFTFACTOR=shiftfactor, $
	QUEK=quekopt, SPLINEMEAN=splinemeanopt, ZEROCROSS=zerocrossopt, $
	VERBOSE=verboseopt, $
	FIX_H=fixno

;***********************************************************************
; 定义常量和操作，如果没有设置操作参数则采用默认值

; 设置判断标准差系数，如果最后剩余的项的标准差小于epsilon与原始数据标准差的乘积，则剩余的项为趋势项
epsilon = 0.00001

; 设置筛循环的次数，确保提取结果为稳定的IMF
ncheckimf = 3

;控制输出IFM个数
no=0.0
; 设置限制计算IMF时的连续的筛过程之间的正态标准差，只有当ZEROCROSS没有设置的时候使用
if not( keyword_set( shiftfactor ) ) then shiftfactor = 0.3

; 初始化检核终止的条件变量，Check = 0代表还未得到任何结果
check = 0
; Check = 1 代表已得到一个IMF
checkimfval = 1
; Check = 2 代表得到残余项
checkresval = 2
; Check = 3 代表退出程序.
checkexitval = 3

; 获得数据长度
ndata = n_elements( data )

; 获取数据长度的位数，确定是否需要长整型数字建立数据项的索引（数据在数组中的位置）
if VAR_TYPE( ndata ) eq 2 then begin
  idtype = 1
endif else begin
  idtype = 1l
endelse

; 获取参数的操作
quekopt = keyword_set( quekopt )
splinemeanopt = keyword_set( splinemeanopt )
zerocrossopt = keyword_set( zerocrossopt )

; 获取判断是否显示中间结果和错误、警告信息的参数
verboseopt = keyword_set( verboseopt )

; 初始化待分解的向量，即将数据赋值给待分解的向量，用于后续的筛过程
x = data

;***********************************************************************
; 将输入的数据分解为其包含的IMFs

; 主循环（筛过程），直到将信号全部分解出为止
while check lt checkexitval do begin

  ; 检查是否已获取所有的IMFs，或者是否已得到残余项
  ; 找出局部极值点及其位置
  nextrema = n_elements( EXTREMA( x ) )
  ; 判断极值点个数是否小于等于2，如果是则得到残余项（趋势项）
  if nextrema le 2 then check = checkresval
  ; 检核残余项是否达到满足要求的大小
  if stddev( x ) lt epsilon * stddev( data ) then check = checkresval

  ; 记录原始信号
  x0 = x

  ; 初始化判断是否已提取稳定IMF的变量
  checkimf = 0
  checkres = 0

  ; 未满足IMF条件时一直循环
  ; 这些条件对应的数值将进入检核变量被记录
  while check eq 0 do begin

    ; 找出形成上下包络线的局部极值点位置，分别放入minima、maxima
    ;temp = extrema( x, minima=minima, maxima=maxima, /flat )
    temp = EXTREMA( x, minima=minima, maxima=maxima )
    nminima = n_elements( minima )
    nmaxima = n_elements( maxima )

    ; 未得到较好的包络曲线，在极值点向量端点添加常量，（处理端点效应），判断原来的端点是否极值点，在端点处得到最佳拟合   
    period0 = 2 * abs( maxima[0] - minima[0] )
    
    period1 = 2 * abs( maxima[nmaxima-1] - minima[nminima-1] )

    ; 为极值点向量添加新的端点（原来的端点不一定是极值点）
    maxpos = [ maxima[0]-2*period0, maxima[0]-period0, maxima, $
        maxima[nmaxima-1]+period1, maxima[nmaxima-1]+2*period1 ]
    maxval = [ x[maxima[0]], x[maxima[0]], x[maxima], x[maxima[nmaxima-1]], $
        x[maxima[nmaxima-1]] ]
    minpos = [ minima[0]-2*period0, minima[0]-period0, minima, $
        minima[nminima-1]+period1, minima[nminima-1]+2*period1 ]
    minval = [ x[minima[0]], x[minima[0]], x[minima], x[minima[nminima-1]], $
        x[minima[nminima-1]] ]

    ; 估计局部均值
    ; 判断是否利用极值点均值进行拟合
    if splinemeanopt then begin

      ; 初始化独立局部均值的位置和值
      meanpos = [ 0 ]
      meanval = [ 0 ]
      ; 如果第一个极值点是极小值点先做如下处理
      if minpos[0] lt maxpos[0] then begin
        meanpos = [ meanpos, ( minpos[0] + maxpos[0] ) / 2 ]
        meanval = [ meanval, ( minval[0] + maxval[0] ) / 2. ]
      endif
      ; 对所有极值进行循环，交替求解相邻的极大值与极小值间的平均值
      for i = 0 * idtype, nmaxima + 4 - 1 do begin
        ; 查找此极大值下一个极小值的位置
        id1 = min( where( minpos gt maxpos[i] ), nid )
        ; 判断满足条件的极值点是否存在
        if nid ne 0 then begin
          ; 添加均值的位置和值
          meanpos = [ meanpos, ( maxpos[i] + minpos[id1] ) / 2 ]
          meanval = [ meanval, ( maxval[i] + minval[id1] ) / 2. ]
          ; 查找此极小值下一个极大值的位置
          id2 = min( where( maxpos gt minpos[id1] ), nid )
          ; 判断满足条件的极值点是否存在
          if nid ne 0 then begin
            ; 添加均值的位置和值
            meanpos = [ meanpos, ( maxpos[id2] + minpos[id1] ) / 2 ]
            meanval = [ meanval, ( maxval[id2] + minval[id1] ) / 2. ]
          endif
        endif
      endfor
      ; 获取估计值的数量
      nmean = n_elements( meanpos ) - 1
      ; 为估值的位置索引排序并且移除初始值
      id = sort( meanpos[1:nmean] )
      meanpos = meanpos[1+id]
      meanval = meanval[1+id]
      ; 利用样条插值估计局部均值
      localmean = spline( meanpos, meanval, indgen( ndata ) )

    ; 如果想利用极值得到均值则需采用如想方法
    endif else begin

      ; 对极大、极小值点分别通过样条插值得到上下包络线
      maxenv = spline( maxpos, maxval, indgen( ndata ) )
      minenv = spline( minpos, minval, indgen( ndata ) )
      ; 计算平均包络线
      localmean = ( minenv + maxenv ) / 2.

    endelse

    ; 从当前数据减去局部均值
    xold = x
    x = x - localmean

    ; 如果IMF判定准则是极值点与过零点个数的比值
    if zerocrossopt then begin
      ; 计算过零点数量
      nzeroes = ZERO_CROSS( x )
      ; 计算极值点数量
      nextrema = n_elements( EXTREMA( x ) )
      ; 检查过零点的数量是否与极值点数量相等或者最多相差1
      if nextrema - nzeroes le 1 then begin
        ; 满足条件的话把得到的量作为候选IMF
        checkimf = checkimf + 1
      endif else begin
        ; 不满足条件则不作为IMF
        checkimf = 0
      endelse
    endif

    ; 如果IMF判定条件为检核连续两轮迭代所得结果之差的大小
    if not( zerocrossopt ) then begin
      ; 量测那一种准则作为筛过程的终止条件 

      ; 利用传统方法计算标准差
      if not( quekopt ) then begin
        sd = total( ( ( xold - x )^2 ) / ( xold^2 + epsilon ) )
      ; 采用改进的方法计算标准差
      endif else begin
        sd = total( ( xold - x ) ^ 2 ) / total( xold^2 )
      endelse

      ; 比较标准差和阈值并判定是否得到一个IMF
      if sd lt shiftfactor then begin
        
        checkimf = checkimf + 1
      endif else begin
        
        checkimf = 0
      endelse

    endif

    ; 判断是否得到满足条件的残余项，如果得到将其视为一个IMF分量存储
    if stddev( x ) lt epsilon * stddev( data ) then checkres = checkres + 1

    ; 判断是否得到满足条件的IMF
    if checkimf eq ncheckimf then check = checkimfval
    if checkres eq ncheckimf then check = checkimfval

  endwhile

  ; 存储得到的IMF到imf矩阵中
  if VAR_TYPE( imf ) eq 0 then begin
    ; 判断是否为第一个IMF
    imf = x
  endif else begin
    ; 如果不是第一个则另存一行
    imf = [ [imf], [x] ]
  endelse
  ; 判断是否已经得到残余项
  if check eq checkresval then begin
    check = checkexitval
  endif else begin
    check = 0
  endelse

  ; 从原始信号中减去上一个IMF
  x = x0 - x

endwhile

;***********************************************************************
; 返回结果

return, imf

END
