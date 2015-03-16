;-
;- Script that:
;-      Find the Point with Largest cc in Slave SLC
;- Usage:
;-      Result=LARGEST_CC(master_file, slave_file, master_s, master_l, $
;-                                s_offset, l_offset, winsub=winsub, winsearch=winsearch)
;-      master_file    : Full Path of Master SLC.
;-      slave_file     : Full Path of Slave SLC.
;-      master_s       : Sample of Point in Master SLC.
;-      master_l       : Line of Point in Master SLC.
;-      s_offset       : Offset in Sample-Direction. Slave_s= Master_s-s_offset.
;-      l_offset       : Offset in Line-Direction. Slave_l= Master_l-s_offset
;-      winsub         : Subset of Master SLC, relatively small.
;-      winsearch      : Subset of Slave SLC to Find Best Point, relatively large.
;- Commentations:
;-      winsub         : 3
;-      winsearch      : 10
;- Outputs:
;-      result(0:1): slave coor with largest cc.  result(2): cc.
;- Example:
;-      winsub= 5
;-      winsearch= 20
;-      s_offset= 0
;-      l_offset= 0
;-      master_file = 'D:\ForExperiment\TSX_TJ_1500\20090327.rslc'
;-      slave_file = 'D:\ForExperiment\TSX_TJ_1500\20090418.rslc'
;-      master_s=510  ;- Sample of master to coregistration
;-      master_l=480 ;- Line of master to coregistration
;-      result=LARGEST_CC(master_file, slave_file, master_s, master_l, s_offset, l_offset, winsub=winsub, winsearch=winsearch)
;- Author:
;-      22:58, 2011-10-05  : Written by T. Li @ InSAR Team In SWJTU
;-      15:08, 2012-02-08  : Modified just to fit the pixel-level coreg. T. Li @ InSAR Team in CUHK

FUNCTION LARGEST_CC, master_file, slave_file, master_s, master_l, s_offset, l_offset, $
                     winsub=winsub, winsearch=winsearch, $
                     MNS=MNS, MNL=MNL, $
                     SNS=SNS, SNL=SNL, $
                     space_cc=space_cc, $ ;空间相关
                     f_cc=f_cc, $ ;频域相关
                     sample_acc= sample_acc, $ ; 列坐标精度
                     line_acc= line_acc, $  ;行坐标精度
                     ovsfactor= ovsfactor ;过采样因子
  
  COMPILE_OPT idl2
;-----------------------------Check Params--------------------------
  IF N_PARAMS() NE 6 THEN MESSAGE, 'ERROR!'+STRING(13B)+ $
                                   'Usage:Result=Fine_Coregistration, master_file, slave_file, master_s, master_l,'+  $
                                   STRING(13B)+'      s_offset, l_offset, winsub=winsub, winsearch=winsearch'
  IF ~KEYWORD_SET(winsub) THEN winsub=512
  IF ~KEYWORD_SET(winsearch) THEN winsearch=32
;  IF ~FILE_TEST(master_file+'.par') THEN MESSAGE, 'Master .par Not Found!'
;  IF ~FILE_TEST(slave_file+'.par') THEN MESSAGE, 'Slave .par Not Found!'
  ;---------------------------------------------------------------------
  master_samples= MNS ; READ_PARAMS(master_file+'.par','range_samples')
  master_lines= MNL ; READ_PARAMS(master_file+'.par','azimuth_lines')
  slave_samples= SNS ; READ_PARAMS(slave_file+'.par','range_samples')
  slave_lines= SNL ; READ_PARAMS(slave_file+'.par','azimuth_lines')

;-----------------------------------------------------------------
  IF (winsub mod 2) THEN BEGIN    
    subset_start_s= Floor(master_s-(winsub/2))
    subset_end_s= FLOOR(master_s+(winsub/2))
    subset_start_l= FLOOR(master_l-(winsub/2))
    subset_end_l= FLOOR(master_l+(winsub/2))    
  ENDIF ELSE BEGIN    
    subset_start_s= FLOOR(master_s-(winsub/2)+1)
    subset_end_s= FLOOR(master_s+(winsub/2))
    subset_start_l= FLOOR(master_l-(winsub/2)+1)
    subset_end_l= FLOOR(master_l+(winsub/2))      
  ENDELSE
  
  master_subset= SUBSETSLC(master_file, subset_start_s, subset_end_s-subset_start_s+1, $
  							subset_start_l, subset_end_l-subset_start_l+1, $
  							fileNs=MNS, fileNl=MNL)
  
  IF Keyword_set(space_cc) THEN Begin
  
    winsearch_c= winsub+winsearch
    IF (winsearch MOD 2) THEN BEGIN
      search_start_s= Floor(master_s+s_offset-(winsearch_c/2))
      search_end_s= FLOOR(master_s+s_offset+(winsearch_c/2))
      search_start_l= FLOOR(master_l+l_offset-(winsearch_c/2))
      search_end_l= FLOOR(master_l+l_offset+(winsearch_c/2))
    ENDIF ELSE BEGIN
      search_start_s= FLOOR(master_s+s_offset-(winsearch_c/2)+1)
      search_end_s= FLOOR(master_s+s_offset+(winsearch_c/2))
      search_start_l= FLOOR(master_l+l_offset-(winsearch_c/2)+1)
      search_end_l= FLOOR(master_l+l_offset+(winsearch_c/2))
    ENDELSE
    
    slave_search= SUBSETSLC(slave_file, search_start_s, search_end_s-search_start_s+1, $
                            search_start_l, search_end_l-search_start_l+1, $
                            fileNs=SNS, fileNl=SNL)
    
    result= C_CORRELATE_COMPLEX(master_subset, slave_search)
    c= MAX(result, p) ;- FIND max_cc(c) and its position(p).
    sz= SIZE(slave_search,/DIMENSIONS)
    s= p MOD sz[0]
    l= FLOOR(p/sz[0])
    s= search_start_s+s
    l= search_start_l+l;- Change p to the real coor.
    result= [s,l,c]
    Return, result
  ENDIF ELSE BEGIN
    search_start_s= FLOOR(master_s+s_offset-(winsub/2)+1)
    search_end_s= FLOOR(master_s+s_offset+(winsub/2))
    search_start_l= FLOOR(master_l+l_offset-(winsub/2)+1)
    search_end_l= FLOOR(master_l+l_offset+(winsub/2))
    slave_search= SUBSETSLC(slave_file, search_start_s, search_end_s-search_start_s+1, $
                            search_start_l, search_end_l-search_start_l+1, $
                            fileNs=SNS, fileNl=SNL)
    
    result= tli_Crosscorrelate(master_subset, slave_search,sample_acc, line_acc, ovsfactor= ovsfactor)
    result= [[master_s,master_l]+[s_offset, l_offset]+result[0:1],result[2]]

    Return, result
  ENDELSE

END