;+
; Name:
;    TLI_CROSSCORRELATE
; Purpose:
;    Calculate maximum cross correlate using FFT.
; Calling Sequence:
;    result= TLI_CROSSCORRELATE(master_arr, slave_arr, sample_acc, line_acc, ovsfactor=ovsfactor)
; Inputs:
;    master_arr      :  Sub array of master image.
;    slave_arr       :  Sub array of slave image.
;    sample_acc      :  Accuracy of s_offset. The same meaning of search window in sample direction.
;    line_acc        :  Accuracy of l_offset. The same meaning of search window in line direction.
; Keyword Input Parameters:
;    ovsfactor       :  Oversample factor. Equal to 1 if not set.
; Outputs:
;    result          :  Containing 3 samples.
;                       offsetp: slave_arr offsetp relative to master_arr.
;                                real_offsetp= coarse_offp+ offsetp
;                       offsetl: slave_arr offsetl relative to master_arr.
;                                real_offsetl= coarse_offl+ offsetl
;                       cc     : Cross correlate at the point.
; Commendations:
;    master_arr      :  Size MUST be (2^n*2^n)
;    slave_arr       :  Size MUST be (2^n*2^n)
;    ovsfactor       :  MUST be 2^n
;    ls_poly         :  Using poly-fit to determin the maximum values of the offsets.
;   ovs_x      : Oversampling factor in range direction
;   ovs_y      : Oversampling factor in azimuth direction.
;   gauss      : Using gauss function to fit the offset.
;
; Example:
;    master_file= 'D:\ISEIS\Data\Img\ASAR-20070726.slc'
;    slave_file= 'D:\ISEIS\Data\Img\ASAR-20060601.slc'
;    s_offset=-32
;    l_offset=-53
;    MNS=5195
;    MNL=27313
;    SNS=5195
;    SNL=27301
;    line_acc= 8;行坐标配准精度，相当于精配准行坐标搜索窗口
;    sample_acc= 8;列坐标配准精度，相当于精配准列坐标搜索窗口
;    ; 裁剪的范围
;    master_arr= TLI_SUBSETDATA(master_file, mns, mnl,1000,64,1000,64,/fc)
;    slave_arr= TLI_SUBSETDATA(slave_file, sns, snl,1000-s_offset,64, 1000-l_offset,64,/fc)
;    ovsfactor=32
;    result= TLI_CROSSCORRELATE(master_arr, slave_arr,sample_acc, line_acc,ovsfactor=ovsfactor)
; Modification History:
;   20120105          :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;   20131202          : Add the keywords 'ls_poly', ovsfactor_s, ovsfactor_l
;
@tli_max2d
@tli_lsfit
FUNCTION TLI_CROSSCORRELATE, master_arr, slave_arr, sample_acc, line_acc, ovsfactor=ovsfactor,$
       ls_poly=ls_poly, ovs_x=ovs_x, ovs_y=ovs_y, gauss=gauss

  COMPILE_OPT idl2
  IF N_PARAMS() NE 4 THEN $
    Message, 'Usage: result= TLI_CROSSCORRELATE(master_arr, slave_arr, s_offset, l_offset, accl, accp, ovsfactor=ovsfactor)'
  IF KEYWORD_SET(ovsfactor)+KEYWORD_SET(ovs_x) EQ 0 THEN BEGIN
    ovsfactor=1
  ENDIF
  IF ~N_Elements(sample_acc) THEN sample_acc=8
  IF ~N_Elements(line_acc) THEN line_acc=8
  
  ovsfactor= DOUBLE(ovsfactor)
  IF NOT KEYWORD_SET(ovs_x) THEN ovs_x=ovsfactor
  IF NOT KEYWORD_SET(ovs_y) THEN ovs_y=ovs_x
  
  ; Copy the parameters, avoiding parameter aliasing. This will lower the efficiency.
  ;  master= master_arr
  ;  slave= slave_arr
  accp= sample_acc
  accl= line_acc
  l=LONG((SIZE(master_arr,/DIMENSIONS))[1])
  p=LONG((SIZE(master_arr,/DIMENSIONS))[0])
  twol= 2*l
  twop= 2*p
  halfl=L/2
  halfp=p/2
  
  ;- 检查参数
  IF (TOTAL(SIZE(master_arr,/DIMENSIONS)-SIZE(slave_arr,/DIMENSIONS)) NE 0) THEN $
    MESSAGE, 'Error! Sizes of input array are inconsistent.'
  IF (TLI_ISPOWER2(L)+TLI_ISPOWER2(P) NE 2) THEN $
    Message, 'Error! Input master array size is not power of 2!'
  IF (~(TLI_ISPOWER2(ovsfactor))) THEN $
    Message, 'Error! Oversample factor is not power of 2!'
  ;- 处理输入数据
  magmaster= ABS(master_arr)
  magmaster= magmaster- MEAN(magmaster)
  magmask= ABS(slave_arr)
  magmask= magmask- MEAN(magmask)
  
  ;- 1. 计算master和slave的叉乘
  master2= COMPLEXARR(twop,twol)
  mask2= COMPLEXARR(twol, twop)
  master2[0:(p-1), 0:(l-1)]= COMPLEX(magmaster,0);
  mask2[halfp:halfp+p-1, halfl:halfl+l-1]= COMPLEX(magmask, 0);
  
  ;    master2= FFT(master2, -1,/OVERWRITE)
  master2= FFT(master2, -1)
  mask2= FFT(mask2, -1)
  mask2= mask2*CONJ(master2)    ; 频率域的乘积
  mask2= FFT(mask2, 1)          ; 空间域的卷积
  
  ;- 2. 计算所有偏移量的均值。real(mask2)包含了向量叉乘结果。
  ;- mask2(0,0):mask2(N,N)包含了偏移量-N/2:N/2。剩余的部分可以舍弃不用。
  master2= COMPLEXARR(twop, twol); 置空
  
  ;- flipud(fliplr((master)^2))=rotate(magmaster),此为实部
  ;- mask^2,此为虚部
  ;- real/imag包含偏移量的均值
  master2[p:*,l:*]= COMPLEX(ROTATE(magmaster^2,2), magmask^2)
  
  ;- 开始计算
  BLOCK= REPLICATE(COMPLEX(1,0),twop,twol)
  BLOCK= FFT(BLOCK, -1)
  master2= FFT(master2, -1)
  master2= master2*BLOCK
  master2= FFT(master2, 1);Real(master2):master的能量; imag(master2):mask
  ;- 3. 像素级处理：找寻最大的相关系数。
  ;    covar= REAL_PART(mask2[0:p,0:l])/SQRT(REAL_PART(master2[0:p, 0:l])*IMAGINARY(master2[0:p, 0:l]));所有的相关系数
  covar= REAL_PART(mask2[0:p-1,0:l-1])/SQRT(REAL_PART(master2[0:p-1, 0:l-1])*IMAGINARY(master2[0:p-1, 0:l-1]));所有的相关系数
  
  
  
  
  CASE KEYWORD_SET(ls_poly) OF
  
    0: BEGIN  ; Interpolate and locate the maximum value.
    
      sz= SIZE(covar,/DIMENSIONS)
      maxcorr= MAX(covar, ind,/NAN);获取最大值及其索引号
      maxcorrp= ind MOD sz[0];最大值对应的列坐标
      maxcorrl= FLOOR(ind/sz[0]);最大值对应的行坐标
      
      offsetl= -halfl+maxcorrl
      offsetp= -halfp+maxcorrp
      ;    PRINT, 'Pixel level coreg:', offsetp, offsetl,maxcorr
      IF ovsfactor EQ 1 THEN BEGIN
        result= [offsetp, offsetl, maxcorr]
        IF offsetp EQ -256 THEN STOP
        RETURN, result
      ENDIF
      
      ;- --------------------------对相关系数过采样，提取子像素级偏移量--------------------------- -----
      ;一些常规判断
      IF ovsfactor GT 1 THEN BEGIN
        ;- 确定过采样的区域不超出图幅范围
        IF maxcorrl LT accl THEN BEGIN
          ;        PRINT, 'Message: Accl should be larger than winsizel!'
          maxcorrl=accl
        ENDIF
        IF maxcorrp LT accp THEN BEGIN
          ;        PRINT, 'Message: Accp should be smaller than winsizep!'
          maxcorrp= accp
        ENDIF
        IF maxcorrl GT (l-accl) THEN BEGIN
          ;        PRINT, 'Message: Accl should be larger than winsizel!'
          maxcorrl= l-accl
        ENDIF
        IF maxcorrp GT (p-accp) THEN BEGIN
          ;        PRINT, 'Message:'ERROR! Accp should be smaller than winsizep!'
          maxcorrp= p-accp
        ENDIF
        ;- 获取maxcorr周围的元素
        chip= covar[(maxcorrl-accl):(maxcorrl+accl-1),(maxcorrp-accp):(maxcorrp+accp-1)]
        
        ovs_chip= TLI_OVERSAMPLE(chip, ovsfactor, ovsfactor);插值
        maxcorr= ABS(MAX(ovs_chip, ind,/NAN)) ;  获取最大值
        sz= SIZE(ovs_chip,/DIMENSIONS)
        offp= FLOOR(ind/sz[0])
        offl= ind MOD sz[0]; 转换到行列号
        
        offsetL= -halfl+maxcorrl-accl+DOUBLE(offl)/ovsfactor
        offsetp= -halfp+maxcorrp-accp+DOUBLE(offp)/ovsfactor
        
        result= [offsetl, offsetp, maxcorr]
        ;      WINDOW,1, XSIZE=1000,YSIZE=1000 & TVSCL, CONGRID(chip,500,500)
        ;      WINDOW, 2 ,XSIZE=1000,YSIZE=1000 & TVSCL, CONGRID(ovs_chip,500,500)
        ;      PLOTS, offp, offl,/DEVICE,PSYM=2,SYMSIZE=10, COLOR=200
        RETURN, result
      ENDIF
    END
    
    1: BEGIN ; Polynomia fit using LS estimate and then calculate the maximum position.
    
      ; Find the maximum value before interpolation
      sz= SIZE(covar,/DIMENSIONS)
      maxcorr= MAX(covar, ind,/NAN);获取最大值及其索引号
      maxcoor= ARRAY_INDICES(covar, ind)
      
      ; Extract the adjacent pixels around the maximum point.
      
      win=[2*accp+1, 2*accl+1]
      v_adj=TLI_SUBDATA(covar, maxcoor, win, coors=coors)   ; Adjacent values and adjacent indices.
      
      coors_x=REAL_PART(coors) & coors_x= REFORM(coors_x, win[0], win[1])
      coors_y=IMAGINARY(coors) & coors_y= REFORM(coors_y, win[0], win[1])
      
      ; Over sampling. Careful to use the FFT method.
      v_adj=TLI_OVERSAMPLE(v_adj,ovs_x, ovs_y,/expand, /odd)
      coors_x=TLI_OVERSAMPLE(coors_x,ovs_x, ovs_y,/expand, /odd)
      coors_y=TLI_OVERSAMPLE(coors_y,ovs_x, ovs_y,/expand, /odd)
      
      v_adj=REFORM(v_adj, 1, N_ELEMENTS(v_adj))
      coors_x=REFORM(coors_x, 1, N_ELEMENTS(coors_x))
      coors_y=REFORM(coors_y, 1, N_ELEMENTS(coors_y))
      ; Fit using LS estimator.
      ; a[0]+a[1]x+a[2]y+a[3]x^2+a[4]y^2
      
;       order=3
      gauss=1
      
      v_adj_fit=TLI_LSFIT(coors_x, coors_y, z=v_adj, inverse=inverse, coefs_all=coefs_all, order=order, $
        fit_err=fit_err, fit_sig=fit_sig, coefs_err=coefs_err, status=status, gauss=gauss)
      IF status EQ -1 THEN BEGIN
        Print, 'Warning: TLI_CROSSCORRELATE, failed in fitting the circular periodic function.Singular array detected.'
        result=!Values.F_NAN*FINDGEN(3)
        RETURN, result
      ENDIF
      
      maxcoorx=coefs_all[4]
      maxcoory=coefs_all[5]
      v_max=coefs_all[0]+coefs_all[1]
      v_max_err=fit_sig
      
      offsetx= -halfp+maxcoorx
      offsety= -halfl+maxcoory
      result=[offsetx, offsety, v_max]
      
      
        
      IF ABS(offsetx) GE p/2D OR ABS(offsety) GE l/2D THEN BEGIN ; This will introduce wrong estimation.
        Print, 'Warning: Offsets are greater than the half window size:'
        Print, 'Offsetx, Offsety, coh.:'+STRJOIN(STRING(result))
        Print, 'Half window size:'+STRCOMPRESS(p/2D)+STRCOMPRESS(l/2D)
        result=FINDGEN(3)*!values.F_NAN
      ENDIF
        Print, result
        
      RETURN, result
      
    END
    
    ELSE:
  ENDCASE
  
  
END