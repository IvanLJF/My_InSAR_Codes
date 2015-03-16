FUNCTION TLI_COARSE_COREG_CORR, master,  $ ; 
                          slave, master_ss, master_ls, slave_ss, slave_ls, $
                          s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
                          winsearch_r=winsearch_r,winsearch_azi= winsearch_azi, $
                          winsub_r=winsub_r, winsub_azi=winsub_azi, degree=degree, acc=acc,$
                          master_swap_endian=master_swap_endian, slave_swap_endian=slave_swap_endian
;  ON_ERROR, 2
  COMPILE_OPT idl2
 
  IF ~KEYWORD_SET(winsub_r) THEN winsub_r=512
  IF ~KEYWORD_SET(winsub_azi) THEN winsub_azi= winsub_r
  
  IF ~KEYWORD_SET(winsearch_r) THEN winsearch_r=50
  IF ~KEYWORD_SET(winsearch_azi) THEN winsearch_azi=winsearch_r
  IF ~KEYWORD_SET(acc) THEN acc=16
  
  IF ~KEYWORD_SET(degree) THEN degree= 1
  
  ;- Initialization 
  MNS= master_ss
  MNL= master_ls
  SNS= slave_ss
  SNL= slave_ls
  winsub= MAX([winsub_r, winsub_azi])
  winsearch= MAX([winsub_r, winsub_azi]+[winsearch_r*2, winsearch_azi*2])

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
  cp_coor= TLI_SPREADPOINTS(conjunction, pointsperl=5, pointspers=5)
  x= REAL_PART(cp_coor)
  y= IMAGINARY(cp_coor)
  ;------------Calculate offsets for each point----------
;  winsearch= winsearch+winsub
  offsets= [0,0,0,0,0];[master_s, master_l, slave_s, slave_l, cc]
  
;  winsearch_r=winsearch_r
;  winsearch_azi= winsearch_azi
;  winsub_r=winsub_r
;  winsub_azi=winsub_azi
  
  line_acc= acc
  sample_acc= acc
  ovsfactor=ovsfactor
  FOR i= 0, N_Elements(x)-1 DO BEGIN
    PRINT, STRCOMPRESS(i)+'/' +STRCOMPRESS(N_Elements(x)-1)
      master_s= x[i]
      master_l= y[i]
      result=TLI_LARGEST_CORR(master, slave, master_ss, master_ls, slave_ss, slave_ls, $
                        master_s, master_l, s_offset, l_offset,$
                        winsub_r=winsub_r, winsub_azi=winsub_azi, $
                        winsearch_r=winsearch_r, winsearch_azi=winsearch_azi, $
                        master_swap_endian=master_swap_endian,sample_acc=sample_acc, line_acc=line_acc, $
                        ovsfactor=ovsfactor);**********************************************ATTENTION**************
      PRINT, master_s, master_l, result[0]-master_s, result[1]-master_l,result[2]
      offsets=[[offsets],[master_s, master_l, result]]
  ENDFOR

  master= master
  slave= slave
  threshold= 0.1;相关系数阈值
  degree= degree;degree
  max_iterations=10;max_iterations
  osfactor= 32D; 过采样因子。本参数和下面两个参数应该从精配准中获取。
  corrwinl= winsub_azi; 行相关窗口
  corrwinp= winsub_r; 列相关窗口
  weighting= 3;加权方法。
  master_ovs_az=1;主影像方位向过采样因子
  master_ovs_rg=1;主影像斜距向过采样因子
  crit_value=10; 迭代终止值
  foff_file= offsets
;  foff_file=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'  
  TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
                    weighting=weighting,crit_value= crit_value,$
                    refine_data= refine_data, coef=coef,/no_offfile
  result= TLI_POLYFIT(refine_data[1:*,*],degree=degree)
;  foff_file=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'  





;  ;-------Adaptive adjustment of threshold ---------
;  ccall= offsets[4,*]
;  thresh= MEAN(ccall)-3D*(STDDEV(ccall))
;  ;-------Adaptive adjustment of threshold ---------  
;  
;  index= WHERE(ccall GT thresh)
;  IF N_ELEMENTS(index) LE 3 THEN BEGIN
;    result= DIALOG_MESSAGE('ERROR!'+STRING(13B)+'Coherence between the 2 SLCs is to low to do coregistration!')
;    RETURN, -1
;  ENDIF
;  offsets= offsets[*, index]
  
;------------reject bad data according to offsets----------------
;  FOR i=0,1 DO BEGIN
;    a= offsets[2,*]-offsets[0,*]
;    thr_up= MEAN(a)+2*STDDEV(a)
;    thr_down= MEAN(a)-2*STDDEV(a)
;
;    offsets= offsets[*, WHERE(a LE thr_up AND a GE thr_down)]
;    
;    a= offsets[3,*]-offsets[0,*]
;    thr_up= MEAN(a)+2*STDDEV(a)
;    thr_down= MEAN(a)-2*STDDEV(a)
;    offsets= offsets[*, WHERE(a LE thr_up AND a GE thr_down)]
;
;  ENDFOR
;------------reject bad data----------------

  ;------------Polyfit-----------------------------------
;  ;Using 2-time polynomial. From master to slave.
;  master_s= offsets[0, *]
;  master_l = offsets[1, *]
;  slave_s = offsets[2, *]
;  slave_l= offsets[3, *]
;  cc = offsets[4, *]
;  ;Least squares
;  ca0= REPLICATE(1, 1, SIZE(master_s,/N_ELEMENTS))
;  ca1= master_s
;  ca2= master_l
;  
;  IF KEYWORD_SET(ls0) THEN BEGIN
;    result=[[MEAN(offsets[2,*]-offsets[0,*]), 1, 0, 0, 0, 0], $
;            [MEAN(offsets[3,*]-offsets[1,*]), 0, 1, 0, 0, 0]]
;  ENDIF ELSE BEGIN  
;    IF KEYWORD_SET(ls2) THEN BEGIN
;      ca3= master_s*master_l
;      ca4= master_s^2
;      ca5= master_l^2;b=a0+a1*ca1+a2*ca2+a3*ca3+a4*ca4+a5*ca5
;      a= [ca0,ca1,ca2,ca3,ca4,ca5]
;      coefx= TRANSPOSE(LA_LEAST_SQUARES(a, slave_s))
;      coefy= TRANSPOSE(LA_LEAST_SQUARES(a, slave_l));- LS poly . slave(xs, ys)=F(xm, ym)
;      result= [[coefx], [coefy]]
;    ENDIF ELSE BEGIN
;      a=[ca0,ca1,ca2]
;      coefx= TRANSPOSE(LA_LEAST_SQUARES(a, slave_s))
;      coefy= TRANSPOSE(LA_LEAST_SQUARES(a, slave_l));- LS poly . slave(xs, ys)=F(xm, ym)
;      result= [[coefx,0,0,0], [coefy,0,0,0]]
;    ENDELSE
;  ENDELSE
  IF ~KEYWORD_SET(c_outfile) THEN $
    c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demcoff'  
  result= DOUBLE(result)
  OPENW, lun, c_outfile,/GET_LUN
  WRITEU, lun, result
  FREE_LUN, lun
;  
;  IF KEYWORD_SET(off_outfile) THEN BEGIN
;    OPENW, lun, off_outfile,/GET_LUN
;    PRINTF, lun, offsets
;    FREE_LUN, lun
;  ENDIF
  
;  
;  
;  PRINT, 'final result:',offsets
  RETURN, result

END