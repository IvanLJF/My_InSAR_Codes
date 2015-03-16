;-
;- Script that:
;-      Find the Point with Largest cc in Slave SLC
;- Usage:
;-      Result=TLI_IDENTICAL_POINT(master_file, slave_file, master_s, master_l, $
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

FUNCTION TLI_IDENTICAL_POINT, master_file, slave_file, master_ss, master_ls, slave_ss, slave_ls, $
                      master_s, master_l, s_offset, l_offset, $
                      winsub_r= winsub_r, winsub_azi=winsub_azi, winsearch_r=winsearch_r, winsearch_azi= winsearch_azi, $
                      master_swap_endian=master_swap_endian, slave_swap_endian=slave_swap_endian, $
                      sample_acc=sample_acc, line_acc=line_acc, ovsfactor=ovsfactor
  COMPILE_OPT idl2
;-----------------------------Check Params--------------------------
  IF ~KEYWORD_SET(winsub_r) THEN winsub_r=512
  IF ~KEYWORD_SET(winsub_azi) THEN winsub_azi= 512
  
  IF ~KEYWORD_SET(winsearch_r) THEN winsearch_r=10
  IF ~KEYWORD_SET(winsearch_azi) THEN winsearch_azi=winsearch_r
  
;  winsearch_or=winsearch_r*2
;  winsearch_oazi=winsearch_azi*2
;  winsearch_or= (winsearch_or+winsub_r)
;  winsearch_oazi= (winsearch_oazi+winsub_azi)
  winsub_or= winsub_r
  winsub_oazi= winsub_azi
  winsearch_or= winsub_r
  winsearch_oazi= winsub_azi
  
;  PRINT, winsearch_or, winsearch_oazi, winsub_or, winsub_oazi
  winsearch_or=winsub_or
  master_samples= master_ss
  master_lines= master_ls
  slave_samples= slave_ss
  slave_lines= slave_ls
;-----------------------------------------------------------------  
  
  subset_start_s= LONG64(master_s-FLOOR(winsub_or/2))
  subset_end_s= LONG64(master_s+FLOOR(winsub_or/2))-1
  subset_start_l= LONG64(master_l-FLOOR(winsub_oazi/2))
  subset_end_l= LONG64(master_l+FLOOR(winsub_oazi/2))-1; Subset from MASTER IMAGE.
  search_start_s= LONG64(master_s+s_offset-FLOOR(winsearch_or/2))
  search_end_s= LONG64(master_s+s_offset+FLOOR(winsearch_or/2))-1
  search_start_l= LONG64(master_l+l_offset-FLOOR(winsearch_oazi/2))
  search_end_l= LONG64(master_l+l_offset+FLOOR(winsearch_oazi/2))-1; Search from SLAVE IMAGE.
  
  IF subset_start_s LT 0 THEN BEGIN ; Sample <0
    subset_start_s = 0
    subset_end_s= subset_start_s+winsub_or-1
  ENDIF
  IF subset_end_s GT master_ss-1 THEN BEGIN; Sample > All samples
    subset_start_s= master_ss-winsub_or
    subset_end_s= master_ss-1
  ENDIF
  IF subset_start_l LT 0 THEN BEGIN; Line <0
    subset_start_l =0
    subset_end_l= subset_start_l+winsub_azi-1
  ENDIF
  IF subset_end_l GT master_ls-1 THEN BEGIN; Line > All lines
    subset_start_l= master_ls-winsub_azi
    subset_end_l= master_ls-1
  ENDIF
  
  IF search_start_s LT 0 THEN BEGIN ; Sample <0
    search_start_s = 0
    search_end_s= search_start_s+winsearch_or-1
  ENDIF
  IF search_end_s GT slave_ss-1 THEN BEGIN; Sample > All samples
    search_start_s= slave_ss-winsearch_or
    search_end_s= slave_ss-1
  ENDIF
  IF search_start_l LT 0 THEN BEGIN; Line <0
    search_start_l =0
    search_end_l= search_start_l+winsearch_oazi-1
  ENDIF
  IF search_end_l GT slave_ls-1 THEN BEGIN; Line > All lines
    search_start_l= slave_ls-winsearch_oazi
    search_end_l= slave_ls-1
  ENDIF
  
  IF KEYWORD_SET(master_swap_endian) THEN BEGIN
    master_subset= TLI_SUBSETDATA(master_file, master_ss, master_ls, $
                                  subset_start_s, subset_end_s-subset_start_s+1, subset_start_l, subset_end_l-subset_start_l+1, $
                                  /sc,/swap_endian)
  ENDIF ELSE BEGIN
    master_subset= TLI_SUBSETDATA(master_file, master_ss, master_ls, $
                                  subset_start_s, subset_end_s-subset_start_s+1, subset_start_l, subset_end_l-subset_start_l+1, $
                                  /sc,/swap_endian)
  ENDELSE
  master_subset= SQRT(master_subset)

  IF KEYWORD_SET(slave_swap_endian) THEN BEGIN  
    slave_search= TLI_SUBSETDATA(slave_file, slave_ss, slave_ls, $
                                  search_start_s, search_end_s-search_start_s+1, search_start_l, search_end_l-search_start_l+1, $
                                  /sc,/swap_endian)
  ENDIF ELSE BEGIN
    slave_search= TLI_SUBSETDATA(slave_file, slave_ss, slave_ls, $
                                  search_start_s, search_end_s-search_start_s+1, search_start_l, search_end_l-search_start_l+1, $
                                  /sc,/swap_endian)
  ENDELSE
  result= TLI_CrossCorrelate(master_subset, slave_search,sample_acc,line_acc,ovsfactor=ovsfactor)
  result= [[master_s,master_l]+[s_offset, l_offset]+result[0:1],result[2]]
  
  
  
;  c= MAX(result, p) ;- FIND max_cc(c) and its position(p).
;  sz= SIZE(slave_search,/DIMENSIONS)
;  s= p MOD sz[0]
;  l= FLOOR(p/sz[0])
;  s= search_start_s+s
;  l= search_start_l+l;- Change p to the real coor.
;  result= [s,l,c]
  RETURN, result
  
END