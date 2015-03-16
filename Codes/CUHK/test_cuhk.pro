;- 
;- Purpose:
;-     Do common test for the project
;- Calling Sequence:
;-    
;- Inputs:
;-    
;- Optional Input Parameters:
;- 
;- Keyword Input Parameters:
;-    
;- Outputs:
;-
;- Commendations:
;-
;- Modification History:
;-

; PATH_SEP
; finity
; value_locate()
PRO TEST_CUHK

  COMPILE_OPT idl2

;- Test for DInSAR
;
;---------------------------calculate Cohrence for 1*1 multi-look image----------------
;    master= 'D:\ISEIS\Data\Img\ASAR-20070726.img'
;    slave= 'D:\ISEIS\Data\Img\ASAR-20090205.img.registered.slc'
;    master_ss= 5195
;    master_ls= 27313
;    win_r=5
;    win_azi=35
;    result= TLI_COHERENCE(master, slave, master_ss, master_ls, win_r=win_r, win_azi=win_azi, $
;                        c_outpath=c_outpath,c_outname=c_outname)
;
;  infile= 'D:\ISEIS\Data\Img\ASAR-20070726-ASAR-20090205.img.registered.slc.cc'
;  result= FLTARR(5195,2000)
;  OPENR, lun, infile,/GET_LUN
;  READU, lun, result
;  FREE_LUN, lun
;  PRINT, MAX(result)
;  temp= result
;  scale=0.5
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  pwr= CONGRID(SQRT(temp),sz[0],sz[1])
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE='cc'
;  LOADCT,0
;  TVSCL, pwr,/ORDER
;-----------------------------------------------------------------------------
    
;    master='/mnt/software/ForExperiment/TSX_TJ_500/20090327.rslc'
;    slave='/mnt/software/ForExperiment/TSX_TJ_500/20090407.rslc'
;    s_offset=0
;    l_offset=0
    
;    master='/mnt/software/ForExperiment/ITF_ENVISAT/20070726.slc'
;    slave='/mnt/software/ForExperiment/ITF_ENVISAT/20070830.slc'
;    s_offset=17;17--15
;    l_offset=10;12--11
    
;        master='/mnt/software/ForExperiment/ITF_ENVISAT/20070726.slc'
;    slave='/mnt/software/ForExperiment/ITF_ENVISAT/20070621.slc'
;    s_offset=22;17--15
;    l_offset=69;12--11
;    master='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090327.slc'
;    slave='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090407.slc'
;    s_offset=110
;    l_offset=57
;
;master='/mnt/software/ISEIS/Data/Img/20070726.mli'
;master_ss= 5195
;master_ls= 5462
;slave='/mnt/software/ISEIS/Data/Img/ASAR-20070726_SimImg.SimImg'
;slave_ss= 5195
;slave_ls= 5462

;master='/mnt/software/ISEIS/Data/Img/TSX-20091114.mli'
;master_ss= 21408
;master_ls= 27778
;slave='/mnt/software/ISEIS/Data/Img/TSX-20091114-simdem'
;slave_ss= 21408
;slave_ls= 27778
;;---------------------------TLI_DEMCOREG-------------------
;degree=1
;DEMCoregFile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'
;result= TLI_DEMCOREG(master, slave, master_ss, master_ls, slave_ss, slave_ls, degree=degree)
;;----------------------Tli_largest_corr--------------
;master_s=1000
;master_l= 1000
;s_offset=0
;l_offset=0
;winsub_r= 200
;winsub_azi= 5*winsub_r0
;winsearch_r= 45
;result= TLI_LARGEST_CORR(master,slave,master_ss, master_ls, slave_ss, slave_ls, $
;                         master_s, master_l, s_offset, l_offset, $
;                         winsub_r= winsub_r,winsub_azi=winsub_azi, winsearch_r= winsearch_r,/master_swap_endian)
;PRINT, master_s, master_l, result[0]-master_s, result[1]-master_l
;-------------------------------Tli_coarse_coreg_corr-----------------
;s_offset= 0
;l_offset= 0
;winsearch_r= 32
;winsearch_azi= 32
;winsub_r= 1024;大于300
;winsub_azi= 1024;大于600
;coreg_outfile=c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'
;result= TLI_COARSE_COREG_CORR(master, slave, master_ss, master_ls, slave_ss, slave_ls, $
;                          s_offset, l_offset, c_outfile= c_outfile, $
;                          winsearch_r=winsearch_r,winsearch_azi=winsearch_azi, $
;                          winsub_r=winsub_r,winsub_azi=winsub_azi,/master_swap_endian)
;PRINT, result

;---------------------Tli_Fine_coreg_corr-----------------------
;coarse_result= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'
;winsearch_r= 3
;winsearch_azi= 10
;winsub_r= 512;大于300
;winsub_azi= 512;大于600
;outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'
;result=TLI_FINE_COREG_CORR( coarse_result, master, slave, $ 
;                        master_ss, master_ls, slave_ss, slave_ls,outfile= outfile,   $
;                          winsearch_r=winsearch_r,winsearch_azi= winsearch_azi, $
;                          winsub_r=winsub_r, winsub_azi=winsub_azi, $
;                          /master_swap_endian, slave_swap_endian=slave_swap_endian)
;Print, 'aaa'
;
;
;fine_result= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'
;result= DBLARR(6,2)
;  OPENR, lun, fine_result, /GET_LUN
;  READU, lun, result
;  FREE_LUN, lun
;  print, result
;------------------------------Tli_subsetdata-------------  
;result= TLI_SUBSETDATA(slave, slave_ss, slave_ls, 3000,5000,22000,5000, /float)
;  scale=0.2
;  temp=result
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  pwr= CONGRID(SQRT(temp),sz[0],sz[1])
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE='PWR'
;  LOADCT,0
;  TVSCL, pwr,/ORDER
;;
;  result= TLI_SUBSETDATA(master, master_ss, master_ls, 2510,301.5,2510,301, /float,/swap_endian)
;  scale=1
;  temp=result
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  pwr= CONGRID(SQRT(temp),sz[0],sz[1])
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE='PWR'
;  LOADCT,0
;  TV, pwr,/ORDER

;-------------largest_CC----------------------
;;slave=master
;      winsub= 58
;      winsearch= 6
;;      winsearch= winsearch+winsub
;      s_offset= 22;22
;      l_offset= 69;69
;      master_file = master
;      slave_file = slave
;      master_s=510  ;- Sample of master to coregistration
;      master_l=480 ;- Line of master to coregistration
;      result=LARGEST_CC(master_file, slave_file, master_s, master_l, s_offset, l_offset, winsub=winsub, winsearch=winsearch)  
;PRINT, master_s, master_l, result[0]-master_s, result[1]-master_l
;STOP
;------------------SubsetSLC----------------------
;result= subsetSLC(slave, 654.00000 ,      307.00000 ,      2844.0000 ,      307.00000)
;  phase= ABS(result)
;  temp=phase
;  scale=1.0
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  phase= CONGRID(phase,sz[0],sz[1])
;  DEVICE, DECOMPOSED=0
;  LOADCT,0
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1],TITLE='INTERFEROGRAM'
;  TVSCL, phase,/ORDER
;  
;  
;  result= subsetSLC(master,751.00000   ,    157.00000 ,      2988.0000      , 157.00000)
;  phase= ABS(result)
;  temp=phase
;  scale=1.0
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  phase= CONGRID(phase,sz[0],sz[1])
;  DEVICE, DECOMPOSED=0
;  LOADCT,0
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1],TITLE='INTERFEROGRAM'
;  TVSCL, phase,/ORDER

;;----------------------------Coarse_coreg_cc---------------------------------------------
;  master= '/mnt/software/ISEIS/Data/Img/TSX-20091114.slc'
;  slave= '/mnt/software/ISEIS/Data/Img/TSX-20080513.slc'
;  s_offset=166
;  l_offset=2557
;  MNS=21408
;  MNL=27778
;  SNS=21408
;  SNL=27778
;  slave=master
;
;
;
;  master= 'D:\ISEIS\Data\Img\ASAR-20070726.slc'
;  slave= 'D:\ISEIS\Data\Img\ASAR-20070830.slc'
;  s_offset=-17
;  l_offset=-12
;  MNS=5195
;  MNL=27313
;  SNS=5195
;  SNL=27316

;    master= '/mnt/software/ISEIS/Data/Img/ASAR-20070726.slc'
;    slave= '/mnt/software/ISEIS/Data/Img/ASAR-20030508.slc'
;    s_offset=-58
;    l_offset=-111
;    MNS=5195
;    MNL=27313
;    SNS=5194
;    SNL=27297
    
;    slave=master
;    s_offset=0
;    l_offset=0
;    SNS=MNS
;    SNL=MNL
    
;    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'.rslc'
;
;    c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff'
;    off_outfile = FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff.pts'
;    result= COARSE_COREG_CC(master,slave, s_offset, l_offset, c_outfile= c_outfile, off_outfile= off_outfile, $
;                          winsearch=32,winsub=256,mns=MNS, mnl=MNL, $
;                          sns=SNS, snl=SNL,degree=1,allpoints=49)
;
;PRINT, result
;STOP
;;-------------------------------------Fine_coreg_cc------------------------------------
;    winsz=256
;    winsearch=4
;    degree=1
;    acc=50
;    pointsperl=60
;    pointspers=60
;    ovsfactor=32
;    coarse_result=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.coff'
;    f_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'
;    quality_file= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.rmse'
;    outfile=f_outfile
;    result= Fine_Coreg_CC(coarse_result, master, slave, winsz=winsz, winsearchsz=winsearchsz, $
;                          outfile= outfile,Degree=degree, acc=acc,mns=MNS, mnl=MNL,sns=SNS,   $
;                          snl=SNL, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints,$
;                          quality_file= quality_file,ovsfactor=ovsfactor)

;;------------------------------------Read coreg coeficients------------------------------
;  infile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.foff'
;  finfo= FILE_INFO(infile)
;  nlines= finfo.size/40D
;  result= DBLARR(5,nlines)
;  OPENR, lun, infile, /GET_LUN
;  READU, lun, result
;  FREE_LUN, lun
;
;  
;  coef= TLI_POLYFIT(result,degree=1)
;  
;  PRINT, coef
;  master_coor=COMPLEX([0,5195,0,5195],[0,0,27313,27313])
;;  master_coor= COMPLEX([307,4856,4856],[307,20291,25287])
;  coreg_coor= COORMTOS(coef, master_coor)
;  PRINT, master_coor, coreg_coor, coreg_coor-master_coor
;;-------------------------------------------Slcinterp------------------------------
;      f_offset= f_outfile
;      outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'fine.rslc'
;      Print, outfile
;      result= SLCINTERP(f_offset, master, slave, outfile= outfile, $
;                          mns=MNS, mnl=MNL, $
;                          sns=SNS, snl=SNL, offs=1)
;;-------------------------------------------Show some results------------------------------
;;  outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'.rslc'
;;  file_ns= 5195
;;  file_ls= 27313
;;  temp= SUBSETSLC(outfile, 0,3000,0,3000, fileNs= file_ns, filenl= file_ls)
;;  scale=0.3
;;  sz= SIZE(temp,/DIMENSIONS)*scale
;;  pwr= CONGRID(ABS(temp),sz[0],sz[1])
;;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE='PWR'
;;  LOADCT,0
;;  TV, pwr,/ORDER
;
;  outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'.rslc'
;  temp= SUBSETSLC(outfile,1000,1000,1000,1000,fileNs= MNS, filenl= MNL)
;  masterSLC= SUBSETSLC(master,1000,1000,1000,1000,fileNs= MNS, filenl= MNL)
;  interf= temp*CONJ(masterSLC)
;  phase= ATAN(interf,/PHASE)
;  scale=1.0
;  sz= SIZE(temp,/DIMENSIONS)*scale
;  phase= CONGRID(phase,sz[0],sz[1])
;  DEVICE, DECOMPOSED=0
;  LOADCT, 25
;  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE='INTERFEROGRAM'
;  TVSCL, phase,/ORDER
;  DEVICE, DECOMPOSED=1
;;;----------------------------Filter---------------------------------------------
;  master='/mnt/software/ForExperiment/TSX_TJ_500/20090327.rslc'
;  slave='/mnt/software/ForExperiment/TSX_TJ_500/20090407.rslc'
;  mslc= OPENSLC(master)
;  sslc= OPENSLC(slave)
;  int= mslc*CONJ(sslc)
;  phase= ATAN(int,/PHASE)
;  filtered= tli_goldstein(phase,n_win=6,alpha=-0.1)
;  sz= SIZE(filtered,/DIMENSIONS)
;  DEVICE, DECOMPOSED=0
;  LOADCT, 25
;  WINDOW, /FREE, XSIZE=sz(0), YSIZE=sz(1), TITLE='Goldstein Filtered'
;  TVSCL, filtered,/ORDER

;-------------------Generate results----------------------------------------
;    mlook_a= 5
;    mlook_r= 1
;    result= TLI_RESULTFILE(master, slave, mlook_a, mlook_r,i_outfile=i_outfile,p_outfile=p_outfile, $
;                          c_outfile= c_outfile)

;;;;;;;---------------------------Read interferogram---------------------------
;  infile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.registered.int'
;  temp= SUBSETSLC(infile, 100,500,100,500)
;  phase= ATAN(temp,/PHASE)
;  sz=SIZE(phase,/DIMENSIONS)
;    scale= 2
;    sz= sz*scale
;    show= CONGRID(phase,sz[0], sz[1])
;    DEVICE, DECOMPOSED=0
;    LOADCT, 25
;    WINDOW, XSIZE=sz[0], YSIZE=sz[1]
;    TVSCL, show,/NAN

;;;;----------------------------Read phase and cc-----------------------
;  infile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.registered.phase'
;  master_ls= READ_PARAMS(master+'.par', 'lines')
;  master_ss= READ_PARAMS(master+'.par', 'samples')
;  master_ls=3000
;  result= FLTARR(master_ss, master_ls)
;  OPENR, lun, infile,/GET_LUN,/SWAP_ENDIAN
;  READU, lun, result
;  FREE_LUN, lun
;  result= result[100:800, 100:800]
;  phase= result
;  sz=SIZE(phase,/DIMENSIONS)
;  scale= 1
;  sz= sz*scale
;  show= CONGRID(phase,sz[0], sz[1])
;  DEVICE, DECOMPOSED=0
;  LOADCT, 25
;  WINDOW, XSIZE=sz[0], YSIZE=sz[1]
;  TVSCL, show,/NAN

;-----------------------------------------------------------------------
;;-----------------------------tli_selectmaster-------------------
;    paramfile='/mnt/software/ISEIS/Data/Img/Result_ASAR_Full.txt'
;    sarlist='/mnt/software/ISEIS/Data/Img/sarlist.txt'
;    method=2
;    result=TLI_SELECTMASTER(paramfile, sarlist, method=method, weights=weights)
;    Print, result
;    Print, 'Master File:'
;    nlines= FILE_LINES(sarlist)
;    temp= STRARR(nlines)
;    OPENR, lun, sarlist,/GET_LUN
;    READF, lun, temp
;    FREE_LUN, lun
;    Print, temp[result]
;STOP
;----------------tli_ras2vec---------------------
;    rasinfile= 'D:\myfiles\Software\TSX_PS_TJ_Piece\piece\20090327.rslc'
;    samples= 3500
;    lines= 3500
;    swap_endian=1
;    pinfile= 'D:\myfiles\Software\TSX_PS_TJ_Piece\plist'
;    data_type= 'SCOMPLEX'
;    result= TLI_RAS2VEC(rasinfile,pinfile,data_type, samples, lines, /swap_endian)
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;- Test for PSI
;
;;-----------------Tli_sarlist----------------------
;    path='F:\TSX-HK\subRslc\'
;    suffix= '.rslc'
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;;    result= TLI_SARLIST(path, suffix, outfile=sarlistfile)
;;;  ----------------------Tli_itab---------------
;    paramfile= 'F:\TSX-HK\subRslc\PasEst.txt'
;;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    itabfile= 'F:\TSX-HK\PSI_CUHK\itab.txt'
;    master=20
;    method=2; 主影像选取方法：
;            ; 0: 单一主影像
;            ; 1: 自由组合
;            ; 2: 多主影像
;;    result= TLI_ITAB(paramfile, sarlistfile, method= method, master= master, output_file= itabfile)
;;;---------------------------Tli_psselect------------------
;;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    samples= 2679
;    lines= 1471
;    fc= 1
;    swap_endian= 0
;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;    thr_da= 0.25
;    thr_amp= 1
;;    result= TLI_PSSELECT(sarlistfile, samples, lines,$
;;                  float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
;;                  outfile=plistfile, thr_da=thr_da, thr_amp=thr_amp)    
;;;---------------------------TLI_DELAUNAY------------------
;;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;    arcsfile='F:\TSX-HK\PSI_CUHK\arcs'
;    range_pixel_spacing= 0.9
;    azimuth_pixel_spacing= 2.04
;    dist_thresh=1000
;;    result= TLI_DELAUNAY(plistfile,outname= arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
;;;;-------------------------Tli_pslc------------------
;;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    pslcfile='F:\TSX-HK\PSI_CUHK\pslc'
;;    samples= 2679
;;    lines= 1471
;    data_type='FCOMPLEX'
;    swap_endian=0
;;    result=TLI_PSLC(sarlistfile,plistfile, samples, lines,data_type,$
;;                     swap_endian=swap_endian, outfile=pslcfile)
;;   
;;  ----------------------Tli_pint---------------
;;    pslcfile='F:\TSX-HK\PSI_CUHK\pslc'
;;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;;    itabfile= 'F:\TSX-HK\PSI_CUHK\itab.txt'
;;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    pintfile='F:\TSX-HK\PSI_CUHK\pint'
;;    TLI_PINT, pslcfile, plistfile, itabfile, sarlistfile, pint_file=pintfile
;    Print, '****************************'
;    Print, '*         Finished!        *'
;    Print, '****************************'
;
;;----------------To Read Pint File----------------
;    nlines= TLI_PNUMBER(plistfile)
;    nsamples= FILE_LINES(itabfile)+1 ;第一列是点坐标
;    pint= COMPLEXARR(nsamples, nlines)
;    OPENR, lun, pintfile,/GET_LUN
;    READU, lun, pint
;    FREE_LUN, lun


; ---------------------------Commen files---------------------------
; Input files
    sarlistfile= 'D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\testforCUHK\sarlist_Win'
    pdifffile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\pdiff0'
    plistfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\testforCUHK\plist'
    itabfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\itab'
    arcsfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\testforCUHK\arcs'
    pbasefile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\pbase'
    outfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\testforCUHK\dvddh'
    pdiffrasfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\pdiff0.01.ras'
    pdeffile='D:\myfiles\Software\experiment\TSX_PS_Tianjin_20120925\pdef4'
    
  IF (!D.NAME) EQ 'X' THEN BEGIN

    sarlistfile= STRSPLIT(sarlistfile,'_',/EXTRACT)
    nstr= N_ELEMENTS(sarlistfile)
    sarlistfile= STRJOIN(sarlistfile[0:nstr-2],'_')
    sarlistfile= sarlistfile[0]+'_Linux'
    sarlistfile= TLI_DIRW2L(sarlistfile)
    pdifffile= TLI_DIRW2L(pdifffile)
    plistfile= TLI_DIRW2L(plistfile)
    itabfile= TLI_DIRW2L(itabfile)
    arcsfile=TLI_DIRW2L(arcsfile)
    pbasefile=TLI_DIRW2L(pbasefile)
    outfile=TLI_DIRW2L(outfile)
    pdiffrasfile=TLI_DIRW2L(pdiffrasfile)
    pdeffile= TLI_DIRW2L(pdeffile)
  ENDIF
  pdef= TLI_READDATA(pdeffile, samples=1, format='FLOAT',/SWAP_ENDIAN)
  
  STOP
END