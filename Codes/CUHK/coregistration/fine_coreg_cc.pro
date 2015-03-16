;+
; Purpose:
;    Do fine coregistration
; Calling Sequence:
;    result= FINE_COREG_CC(coarse_result, master, slave, winsz=winsz, winsearchsz=winsearchsz, $
;                        outfile= outfile,Degree=degree, acc=acc,mns=MNS, mnl=MNL,sns=SNS,   $
;                        snl=SNL, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints,$
;                        quality_file= quality_file,ovsfactor=ovsfactor )
; Inputs:
;    coarse_result  :  Result of coarse_coreg_cc.pro. (**.coff)
;    master         : Master SLC
;    slave          : Slave SLC
; Optional Input Parameters:
;    None
; Keyword Input Parameters:
;    winsz          : Window size to calculate cc.
;    winsearchsz    : Window size to search coor.
;    outfile        : File to maitain results.
;    degree         : Degree of polinomial
;    acc            : Accuracy of coarse coreg
;    mns            : Master samples.
;    mnl            : Master lines.
;    sns            : Slave samples
;    snl            : Slave lines.
;    pointsperl     : Points per line.
;    pointspers     : Points per sample.
;    allpoints      : All points distributed in the image. If keywords opintsperl & pointspers are set, then this keyword is ignored.
;    quality_file   : An ASCII file containing RMSE of all the offsets. 
;    ovsfactor      : Oversampling factor.
; Outputs:
;    Polynomial coefficients.
; Commendations:
;    winsz          : 64.
;    winsearch      : 8.
;    pointsperl     : 30.
;    pointspers     : 30.
; Example:
;    master= 'D:\ISEIS\Data\Img\ASAR-20070726.slc'
;    slave= 'D:\ISEIS\Data\Img\ASAR-20070830.slc'
;    s_offset=-17
;    l_offset=-12
;    MNS=5195
;    MNL=27313
;    SNS=5195
;    SNL=27316
;    winsz=64
;    winsearch=4
;    degree=2
;    acc=8
;    pointsperl=30
;    pointspers=30
;    ovsfactor=32
;    coarse_result= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff'
;    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'
;    quality_file= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.rmse'
;    result= Fine_Coreg_CC(coarse_result, master, slave, winsz=winsz, winsearchsz=winsearchsz, $
;                          outfile= outfile,Degree=degree, acc=acc,mns=MNS, mnl=MNL,sns=SNS,   $
;                          snl=SNL, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints,$
;                          quality_file= quality_file,ovsfactor=ovsfactor)
; Modification History:
;    01/03/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK
;    10/05/2012: Add TLI_REFINEOFFS.pro..T.Li
;-
FUNCTION FINE_COREG_CC, coarse_result, master, slave, winsz=winsz, winsearchsz=winsearchsz, $
                        outfile= outfile,Degree=degree, acc=acc,mns=MNS, mnl=MNL,sns=SNS,   $
                        snl=SNL, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints,$
                        quality_file= quality_file,ovsfactor=ovsfactor ; txt文件，记录方差，完成后自动打开文档给用户查看。只有两个文件的单独配准就不打开了。
  						  ; 此文件在批量配准时，第一个数据初始化文件，后面的配准都是添加记录。所以一开始必须先删掉原来的记录文件。删不掉再创建一个新的。
  						  ; 保证首次输入的记录文件是新的，可以写的。

  COMPILE_OPT idl2

  IF ~KEYWORD_SET(winsz) THEN $
    winsz= 64
  IF ~KEYWORD_SET(winsearchsz) THEN $
    winsearchsz= 5
  IF ~KEYWORD_SET(outfile) THEN $
    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'
  IF ~Keyword_set(quality_file) THEN $
    quality_file= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.rmse'
  IF ~N_elements(Degree) THEN $
    Degree=1
  IF ~(KEYWORD_SET(acc)) THEN $
    acc=100D
  IF ~Keyword_set(ovsfactor) THEN ovsfactor=32
  ;------------------Initialization--------------************************Attention************************
  master_ss = mns ;READ_PARAMS(master_h, 'range_samples')-1
  master_ls = mnl; READ_PARAMS(master_h, 'azimuth_lines')-1
  slave_ss = sns; READ_PARAMS(slave_h, 'range_samples')-1
  slave_ls= snl; READ_PARAMS(slave_h, 'azimuth_lines')-1
  resample_factor=10D
  step_width= 1/(resample_factor)
;------------------Initialization--------------************************Attention************************
  finfo= FILE_INFO(coarse_result)
  nlines= finfo.size/40
  result= DBLARR(6, nlines)
  OPENR, lun, coarse_result, /GET_LUN
  READU, lun, result
  FREE_LUN, lun
;  coef= TLI_POLYFIT(result)
  coef= result
  s_offset= coef[0,0]
  l_offset= coef[0,1]

  ;------------First calculate the conjunction-----------
  conjunction= FLTARR(4); 起始行，终止行，起始列，终止列。主影像坐标系。
  conjunction[0] = (-s_offset) > 0;起始列
  conjunction[1] = (master_ss-s_offset) < master_ss;终止列
  conjunction[2] = (-l_offset) > 0; 起始行
  conjunction[3] = (master_ls-l_offset) < master_ls; 终止行
  conjunction= conjunction+[ FLOOR((winsearchsz+winsz)/2)+winsearchsz+acc,$
                            -FLOOR((winsearchsz+winsz)/2)-winsearchsz-acc-((MNS-SNS)>0),$
                            +FLOOR((winsearchsz+winsz)/2)+winsearchsz+acc,$
                            -FLOOR((winsearchsz+winsz)/2)-winsearchsz-acc-((MNL-SNL)>0)]

  ;------------Decide the control points----------
  cp_coor= TLI_SPREADPOINTS(conjunction, pointsperl=pointsperl, pointspers=pointspers,allpoints=allpoints)
  ;-------------Set some params-------------
  sz= SIZE(cp_coor,/N_ELEMENTS)
  offset_s= coef[0,0]
  offset_l= coef[0,1]
  cp_coor_s= COORMTOS(coef, cp_coor) ;Points in slave SLC
 
  ;----------------------Really fine-coreg----------------
  fine_result=DOUBLE([0,0,0,0,0]); master_s, master_l, slave_s,slave_l, cc

  FOR i=0, sz[0]-1 DO BEGIN
    
    master_s= Real_part(cp_coor[i])
    master_l= Imaginary(cp_coor[i])
    slave_coor=CoorMtoS(coef, COMPLEX(master_s, master_l))
    slave_s=Real_part(slave_coor)
    slave_l=Imaginary(slave_coor)
    s_offset= slave_s - master_s
    l_offset= slave_l - master_l
    winsub=winsz
    winsearch= winsearchsz
    result= Largest_cc(master, slave, master_s, master_l, s_offset, l_offset,$
                       winsub=winsub, winsearch=winsearch, $
                       MNS=MNS, MNL=MNL, $
                       SNS=SNS, SNL=SNL, $
                       sample_acc=sample_acc,ovsfactor=ovsfactor, line_acc= line_acc)
    
;    result= [master_s, master_l,result]
    fine_result= [[fine_result],[master_s, master_l, result]]
;    IF ~(i MOD 50) THEN BEGIN
      PRINT, STRING(i)+'/'+STRING(sz[0]-1), master_s, master_l, result[0]-master_s, result[1]-master_l, result[0]-master_s-s_offset, result[1]-master_l-l_offset
;    ENDIF
  ENDFOR
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, fine_result
  FREE_LUN, lun;写出off文件
  
  ;------------------------数据精化-------------------------------
  Print, 'Fine- Coreg is finished!'
  Print, 'Start refining data...'
  
  master= master
  slave= slave
  MNS= MNS;主影像列数
  MNL= MNL;主影像行数
  SNS= SNS;从影像总列数
  SNL= SNL;从影像总行数
  threshold= 0.1;相关系数阈值
  degree= degree;degree
  max_iterations=3400;max_iterations
  osfactor= ovsfactor; 过采样因子。本参数和下面两个参数应该从精配准中获取。
  corrwinl= winsub; 行相关窗口
  corrwinp= winsub; 列相关窗口
  weighting= 1;加权方法。
  master_ovs_az=1;主影像方位向过采样因子
  master_ovs_rg=1;主影像斜距向过采样因子
  crit_value=10; 迭代终止值
  foff_file=outfile
  TLI_REFINEOFFS, master, slave, MNS, MNL, SNS, SNL, foff_file, osfactor,corrwinl,corrwinp,master_ovs_az,master_ovs_rg,$
                    threshold=threshold, degree=degree, max_iterations= max_iterations,$
                    weighting=weighting,crit_value= crit_value,$
                    refine_data= refine_data, coef=coef
  ;计算偏移量标准差
  master_coor= Complex(refine_data[1,*],refine_data[2,*])
  slave_coor= Complex(refine_data[3,*],refine_data[4,*])
  slave_coor_true= COORMTOS(coef, master_coor,/offs)
  err= slave_coor-slave_coor_true
  stdxoff= STDDEV(REAL_PART(err))
  stdyoff= STDDEV(Imaginary(err))
  stdoff= SQRT(stdxoff^2+stdyoff^2)
  ;------------------------数据精化-------------------------------
  PRINT,'Offsets RMSE:', stdxoff, stdyoff
  result= DOUBLE(coef)
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, result
  FREE_LUN, lun
  
  
  pts= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'fine.pts'
  OPENW, lun, pts,/GET_LUN
  PRINTF, lun, '; ENVI Image to Image GCP File '
  PRINTF, lun, '; base file: '+master
  PRINTF, lun, '; warp file: '+slave
  PRINTF, lun, '; Base Image (x,y), Warp Image (x,y)'
  PRINTF, lun, ';'
  PRINTF, lun, refine_data[1:4, *]
  Free_LUN, lun
  
  
  
;;---------------------Return result-----------------
  ; 写出STD(offset)
  
;  IF ~FILE_TEST(quality_file) THEN BEGIN
;	  OPENW, lun, quality_file,/GET_LUN
;	  PRINTF, lun, 'Filename    ', 'Range Offset RMSE ', '    Azimuth Offset RMSE'
;	  PRINTF, lun, Fw_RemovePostfix(master, /only), STRCOMPRESS(0) , STRCOMPRESS(0)
;	  PRINTF, lun, Fw_RemovePostfix(slave, /only), STRCOMPRESS(stdxoff) , STRCOMPRESS(stdyoff)
;  ENDIF ELSE BEGIN
;      OPENW, lun, quality_file,/GET_LUN,/APPEND
;      PRINTF, lun, Fw_RemovePostfix(slave, /only), STRCOMPRESS(stdxoff) , STRCOMPRESS(stdyoff)
;  ENDELSE
;  Free_Lun, lun

  RETURN, result
END