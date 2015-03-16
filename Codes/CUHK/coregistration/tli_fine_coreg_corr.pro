FUNCTION TLI_FINE_COREG_CORR, coarse_result, master, slave, $                        
                        master_ss, master_ls, slave_ss, slave_ls,pno=pno,  outfile=outfile,$
                          winsearch_r=winsearch_r,winsearch_azi= winsearch_azi, $
                          winsub_r=winsub_r, winsub_azi=winsub_azi, degree=degree, $
                          master_swap_endian=master_swap_endian, slave_swap_endian=slave_swap_endian, $
                          acc=acc, ovsfactor=ovsfactor

;  ON_ERROR, 2
  COMPILE_OPT idl2
  
  MNS= master_ss
  MNL= master_ls
  SNS= slave_ss
  SNL= slave_ls
  
  IF ~KEYWORD_SET(winsub_r) THEN winsub_r=512
  IF ~KEYWORD_SET(winsub_azi) THEN winsub_azi= winsub_r
  winsub= MAX([winsub_r,winsub_azi])
  
  IF ~KEYWORD_SET(winsearch_r) THEN winsearch_r=3
  IF ~KEYWORD_SET(winsearch_azi) THEN winsearch_azi=winsearch_r
  winsearch= MAX([winsearch_r, winsearch_azi])
  
  IF ~KEYWORD_SET(acc) THEN acc=100D
  IF ~KEYWORD_SET(ovsfactor) THEN ovsfactor=32
  
  IF ~KEYWORD_SET(degree) THEN degree=1
  
;  IF ~KEYWORD_SET(winsz) THEN $
;    winsz= 256
;  IF ~KEYWORD_SET(winsearchsz) THEN $
;    winsearchsz= 5
  IF ~KEYWORD_SET(outfile) THEN $
    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'

;------------------Initialization--------------************************Attention************************
;  master_h= master+'.par'
;  slave_h= slave+'.par'
;  master_ss = READ_PARAMS(master_h, 'range_samples')-1
;  master_ls = READ_PARAMS(master_h, 'azimuth_lines')-1
;  slave_ss = READ_PARAMS(slave_h, 'range_samples')-1
;  slave_ls= READ_PARAMS(slave_h, 'azimuth_lines')-1
;------------------Initialization--------------************************Attention************************

  coef= DBLARR(6,2)
  OPENR, lun, coarse_result, /GET_LUN
  READU, lun, coef
  FREE_LUN, lun

  s_offset= coef[0,0]
  l_offset= coef[0,1]
  
  ;------------First calculate the conjunction-----------
  conjunction= FLTARR(4); 起始行，终止行，起始列，终止列。主影像坐标系。
  conjunction[0] = (-s_offset) > 0;起始列
  conjunction[1] = (master_ss-s_offset) < master_ss;终止列
  conjunction[2] = (-l_offset) > 0; 起始行
  conjunction[3] = (master_ls-l_offset) < master_ls; 终止行
  conjunction= conjunction+[ FLOOR((winsearch+winsub)/2)+winsearch+acc,$
                            -FLOOR((winsearch+winsub)/2)-winsearch-acc-((MNS-SNS)>0),$
                            +FLOOR((winsearch+winsub)/2)+winsearch+acc,$
                            -FLOOR((winsearch+winsub)/2)-winsearch-acc-((MNL-SNL)>0)]
  
  ;------------Decide the control points----------

  cp_coor= TLI_SPREADPOINTS(conjunction, pointsperl=25,pointspers=25)
  x= REAL_PART(cp_coor)
  y= IMAGINARY(cp_coor)
  ;-------------Interpolate for master SLC-------------
  sz= SIZE(cp_coor,/N_ELEMENTS)
  
;  offset_s= coef[0,0]
;  offset_l= coef[0,1]
  cp_coor_s= COORMTOS(coef, cp_coor) ;Points in slave SLC
  
  tempa0=winsub_r
  IF ~(winsub_r MOD 2) THEN tempa0=winsub_r+1
  tempa1=winsub_azi
  IF ~(winsub_azi MOD 2) THEN tempa1=winsub_azi+1
  
;  winsearch_r= winsearch_r*2+winsub_r
;  winsearch_azi= winsearch_azi+winsub_azi
;  tempb0=winsearch_r
;  tempb1=winsearch_azi
;  IF ~(tempb0 MOD 2) THEN tempb0=winsearch_r+1
;  IF ~(tempb1 MOD 2) THEN tempb1=winsearch_azi+1
  
  ;----------------------Really fine-coreg----------------
  fine_result=[0,0,0,0,0]; master_s, master_l, slave_s,slave_l, cc
  
  FOR i=0, sz[0]-1 DO BEGIN
    master_s= Real_part(cp_coor[i])
    master_l= Imaginary(cp_coor[i])
    slave_coor=CoorMtoS(coef, COMPLEX(master_s, master_l))
    slave_s=Real_part(slave_coor)
    slave_l=Imaginary(slave_coor)
    s_offset= slave_s - master_s
    l_offset= slave_l - master_l
    result=TLI_LARGEST_CORR(master, slave, master_ss, master_ls, slave_ss, slave_ls, $
                        master_s, master_l, s_offset, l_offset,$
                        winsub_r=winsub_r, winsub_azi=winsub_azi, $
                        winsearch_r=winsearch_r, winsearch_azi=winsearch_azi, $
                        sample_acc=sample_acc, line_acc=line_acc, ovsfactor=ovsfactor,/master_swap_endian);**********************************************ATTENTION**************
    fine_result= [[fine_result],[master_s, master_l, result]]
    PRINT, STRING(i)+'/'+STRCOMPRESS(sz[0]-1), master_s, master_l,result[0]-master_s, $
           result[1]-master_l,result[0]-master_s-s_offset, result[1]-master_l-l_offset,result[2]
  ENDFOR
;  OPENW, lun, outfile,/GET_LUN
;  WRITEU, lun, fine_result
;  FREE_LUN, lun;写出offs文件
;  
  
  master= master
  slave= slave
  threshold= 0.01;相关系数阈值
  degree= degree;degree
  max_iterations=200;max_iterations
  osfactor= 32D; 过采样因子。本参数和下面两个参数应该从精配准中获取。
  corrwinl= winsub_azi; 行相关窗口
  corrwinp= winsub_r; 列相关窗口
  weighting= 3;加权方法。
  master_ovs_az=1;主影像方位向过采样因子
  master_ovs_rg=1;主影像斜距向过采样因子
  crit_value=10; 迭代终止值
  foff_file= fine_result
;  foff_file=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'  
  TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
                    weighting=weighting,crit_value= crit_value,$
                    refine_data= refine_data, coef=coef,/no_offfile

;;---------------------Return result-----------------
  result= DOUBLE(refine_data[1:*, *])
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, result
  FREE_LUN, lun
  
  RETURN, result
END