;-
;- Purpose:
;-     Do empirical mode decomposition
;-

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

FUNCTION TLI_EMD, $
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

;FUNCTION TLI_EMD,Bt, residuals, times=times
;  ; Find maxima
;  maxima=0
;  minima=0
;  maxima_ind=0
;  mimima_ind=0
;  residuals_cp = residuals
;  emd
;  WHILE NOT nofinish DO BEGIN
;    FOR i=0, N_ELEMENTS(residuals_cp)-1 DO BEGIN
;    
;      Case i OF
;        0: BEGIN        
;          IF residuals_cp[i] GE residuals_cp[i+1] THEN BEGIN
;            maxima_ind=[maxima, i]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima, i]
;          ENDELSE          
;        END
;        
;        N_ELEMENTS(residuals_cp)-1: BEGIN        
;          IF residuals_cp[N_ELEMENTS(residuals_cp)-1] GT residuals_cp[N_ELEMENTS(residuals_cp)-2] THEN BEGIN
;            maxima_ind=[maxima_ind, (N_ELEMENTS(residuals_cp)-1)]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima_ind, (N_ELEMENTS(residuals_cp)-1)]
;          ENDELSE          
;        END
;        
;        ELSE: BEGIN        
;          IF residuals_cp[i] GT residuals_cp[i-1] AND residuals_cp[i] GE residuals_cp[i+1] THEN BEGIN
;            maxima_ind=[maxima_ind, i]
;          ENDIF ELSE BEGIN
;            minima_ind=[minima_ind, i]
;          ENDELSE
;        END
;      ENDCASE
;      
;    ENDFOR
;    
;    ; Check the result
;    IF maxima_ind LT 2 OR minima_ind LT 2 THEN BEGIN
;    
;      maxima= residuals_cp[maxima_ind]
;      minima= residuals_cp[minima_ind]
;      
;      
;      Print, 'Empirical mode decomposition done successfully.'
;      nofinish=-1
;      RETURN, 1
;    ENDIF ELSE BEGIN
;      ; Interp maxima at each time
;      maxima_interp= INTERPOL(maxima, BT[maxima_ind], BT)
;      ; Interp minima at each time
;      minima_interp= INTERPOL(minima, BT[minima_ind], BT)
;      ; Calculate ml
;      mean_interp= (maxima_interp+minima_interp)/2
;      ; New residuals for next loop
;      residuals_cp = residuals_cp- mean_interp
;    ENDELSE
;    
;  ENDWHILE
;  
;  RETURN,1
;END

PRO TLI_EMP_MODE_DEC

  ; Input params
  refind= 17170
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed light
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
    pdifffile= workpath+'/pdiff0'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= workpath+'/testforCUHK/plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=workpath+'/testforCUHK/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=workpath+'/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    dvddhfile=workpath+'/testforCUHK/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= workpath+'/testforCUHK/vdh'
    atmfile= workpath+'/testforCUHK/atm'
    nonfile= workpath+'/testforCUHK/nonlinear'
    noisefile= workpath+'/testforCUHK/noise'
    time_seriesfile= workpath+'/testforCUHK/time_series'
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    dvddhfile=TLI_DIRW2L(dvddhfile,/REVERSE)
    vdhfile=TLI_DIRW2L(vdhfile,/REVERSE)
  ENDELSE
  
  ; Read sarlistfile
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(1,nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read plist
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  
  ; Load itabfile's info
  nintf= FILE_LINES(itabfile) ; Number of interferograms.
  ; Read itab
  itab= INTARR(4)
  Print, '* There are', STRCOMPRESS(nintf), ' interferograms. *'
  OPENR, lun, itabfile,/GET_LUN
  FOR i=0, nintf-1 DO BEGIN
    tmp=''
    READF, lun, tmp
    tmp= STRSPLIT(tmp, ' ',/EXTRACT)
    itab= [[itab], [tmp]]
  ENDFOR
  FREE_LUN, lun
  itab= itab[*, 1:*]
  master_index= itab[0, *]-1
  slave_index= itab[1, *]-1
  master_index= master_index[UNIQ(master_index)]
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
      ' Its name is: ', FILE_BASENAME(sarlist[master_index-1]), ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Load plistfile's info
  npt= TLI_PNUMBER(plistfile); Number of points.
  
  ; Check params
  IF refind EQ 0 OR refind EQ npt-1 THEN BEGIN
    MESSAGE, 'Error: We do not believe it is robust to set refind as: ', STRCOMPRESS(refind)
  ENDIF
  
  ; Load pdifffile
  pdiff= TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',/SWAP_ENDIAN)
  
  ; Load pbasefile
  pbase= TLI_READDATA(pbasefile, samples=13,format='DOUBLE',/SWAP_ENDIAN)
  
  ; Load vdhfile
  vdh= TLI_READDATA(vdhfile,samples=5, format='DOUBLE')
  npt_arcs= (SIZE(vdh,/DIMENSIONS))[1]
  
  ; Different phase referred to the refind
  refphase= pdiff[refind, *]  ; Phase difference between points and refind.
  pdiff_refind= pdiff*CONGRID(CONJ(refphase), npt, nintf); pdiff - refind*********refrence point included.**********
  pdiff_refind= ATAN(pdiff_refind,/PHASE)                ; phase
  
  ; Calculate dvddh related phase
  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  R1= READ_PARAMS(sarlist[master_index[0]]+'.par', 'near_range_slc')
  rps= READ_PARAMS(sarlist[master_index[0]]+'.par', 'range_pixel_spacing')
  stec= READ_PARAMS(sarlist[master_index[0]]+'.par', 'sar_to_earth_center')
  erbs= READ_PARAMS(sarlist[master_index[0]]+'.par', 'earth_radius_below_sensor')
  wavelength = (c) / radar_frequency ;米为单位
  
  ref_coor= plist[refind]
  ref_x= REAL_PART(ref_coor)
  ; Slant range of ref. p
  ref_r= R1+(ref_x)*rps
  ; Look angle of ref. p
  cosla= (stec^2+ref_r^2-erbs^2)/(2*stec*ref_r)
  sinla= SQRT(1-cosla^2)
  K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
  K2= -4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
  
  Bt= TBASE_ALL(sarlistfile, itabfile)
  
  IF TOTAL(pbase[6:8, *]) EQ 0 THEN BEGIN
    Print, '* Warning: No precision baseline is available. *'
    Bperp= pbase[1, *]
  ENDIF ELSE BEGIN
    Bperp= pbase[7, *]
  ENDELSE
  
  refind_ind= WHERE(vdh[0, *] EQ refind)
  ref_v= (vdh[3, refind_ind])[0]
  ref_dh= (vdh[4, refind_ind])[0]
  
  ; Atmospheric phase
  atm_phase= DBLARR(npt, nintf+3) ; itab+3 means there is  x line,  y line,and a mask line.
  atm_phase[*, 0:1]= TRANSPOSE([REAL_PART(plist), IMAGINARY(plist)])
  non_phase= atm_phase
  time_series_phase= atm_phase
  noise_phase= atm_phase
  
  FOR i=0, npt_arcs-1 DO BEGIN
    IF ~(i MOD 100) THEN BEGIN
      Print,i, '/', STRCOMPRESS(npt_arcs-1)
    ENDIF
  
    pt_ind= vdh[0, i] ; Point index
    pt_phase= pdiff_refind[pt_ind, *]
    pt_dv= (vdh[3, i]-ref_v)[0]
    pt_ddh= (vdh[4, i]-ref_dh)[0]
    
    res= TRANSPOSE(pt_phase-(K1*Bperp*pt_ddh+K2*Bt*pt_dv))
    emd_res=TLI_EMD(res)
    ; We believe that the first component is APS, second nonlinear vel., others noise.
    IF N_ELEMENTS(SIZE(emd_res,/DIMENSIONS)) EQ 1 THEN BEGIN
      n_component=1
    ENDIF ELSE BEGIN
    n_component= (SIZE(emd_res,/DIMENSIONS))[1]
    ENDELSE
 
    CASE n_component OF
      0: BEGIN
        Print, 'There is no obvious residuals at this point: ', STRCOMPRESS(i)
      END
      1: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
      END
      2: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
      END
      3: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
        noise_phase[i, 2:*]= [1D, emd_res[*, 2]]
      END
      ELSE: BEGIN
        atm_phase[i, 2:*]= [1D, emd_res[*, 0]]
        non_phase[i, 2:*]= [1D, emd_res[*, 1]]
        noise_phase[i, 2:*]= [1D, TOTAL(emd_res[*, 2:*], 2)]
      END
    ENDCASE
  ENDFOR
  
  v_all= DBLARR(npt)
  v_ind= TRANSPOSE(vdh[0, *])
  time_series_phase[*,3:*]= TRANSPOSE(BT) ## v_all + non_phase[*, 3:*]
  
  OPENW, lun, atmfile,/GET_LUN
  WRITEU, lun, atm_phase
  FREE_LUN, lun
  
  OPENW, lun, nonfile,/GET_LUN
  WRITEU, lun, non_phase
  FREE_LUN, lun
  
  OPENW, lun, noisefile,/GET_LUN
  WRITEU, lun, noise_phase
  FREE_LUN, lun
  
  OPENW, lun, time_seriesfile,/GET_LUN
  WRITEU, lun, time_series_phase
  FREE_LUN, lun
  
  Print, 'Files written successfully!'
  
END