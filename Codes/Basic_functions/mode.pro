;+--------------------------------------------------------------------------
;| 数组求众数----一组数据中出现次数最多的数据
;| 输入: 数值数组----没有维数限制
;| 输出: Return 众数
;|           关键字输出: bigfreq: 众数出现次数
;+--------------------------------------------------------------------------
;
; History:
;   Original version: Copy from HH.
;   20140314        : Add NBINS=NBINS, T.LI @ SWJTU
;
Function Mode, array, bigfreq=bigfreq, nbins=nbins
  IF NOT KEYWORD_SET(nbins) THEN nbins=20
  h = Histogram(array, MIN=Min(array), NBINS=NBINS, locations=locations)
  bigfreq = Max(h)
  m=locations[WHERE(h EQ bigfreq)]
;  m = Where(h EQ bigfreq) + Min(array)
  
  Return, m
End