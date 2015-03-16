;- 
;- Script that:
;-      Get Data from A Circle in Original Data Set
;- Usage:
;-      result= CircleData(input, cx, cy, r)
;-      input  : Original Data
;-      [cx,cy]: Circle Center in X-Coor and Y-Coor
;-      r      : Radius of the Circle
;- Eg.:
;-      result= CircleData(input, [12,13], 5)
;- Commendations:
;- Author:
;-      T. Li @ InSAR Team in SWJTU
;-      14:52, 2011-10-08
;-
FUNCTION CircleData, input, cx, cy, r
  
;  a= FINDGEN(50,50);- 数据
;  c= [12,15];- 圆心
;  r= 5;- 半径
;  ii= COMPLEXARR(50,50);- index数组
  ;- Check Input Params
  n_param= N_PARAMS()
  IF n_param NE 4 THEN result= Dialog_message('Usage:result= CircleData(input, cx, cy, r)')
;  input= input
;  cx= cx
;  cy= cy
;  r= r
  
  sz= SIZE(input,/DIMENSIONS)
  n_samples= sz(0) & n_lines= sz(1)
  ii= COMPLEXARR(n_samples, n_lines)
  FOR i= 0,n_samples-1 DO BEGIN
    FOR j= 0,n_lines-1 DO BEGIN
      ii(i,j)= COMPLEX(i,j)
    ENDFOR
  ENDFOR
  ii= ii-COMPLEX(cx,cy)
  ii= ABS(ii);- 计算每一点与圆心的距离
  ii= WHERE(ii LT r);- 抽取半径小于5的索引
  mask= REPLICATE(0,n_samples,n_lines);- 创建掩模矩阵
  mask(ii)=1 ;- 建立掩模
  result= input*mask
  
  RETURN, result  
  
END