;
; Residual decomposition for HPA
;

PRO TLI_HPA_RESIDUAL

  COMPILE_OPT idl2
  CLOSE,/ALL
  starttime= SYSTIME(/SECONDS)
  c= 299792458D ; Speed light
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'+PATH_SEP()
  basepath=hpapath+'base'
  ; Input files
  sarlistfilegamma= workpath+'SLC_tab'
  level=8
  
  files=TLI_HPA_FILES(hpapath, level='final')
  pdifffile= files.pdiff
  pdiff_swapfile= files.pdiff_swap
  ;  plistfilegamma= workpath+'pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= files.plist
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=hpapath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=files.pbase
  vdhfile= files.vdh
  sarlistfile= hpapath+'sarlist_Linux'
  plistfile_orig=hpapath+'plist'
  ptattrfile= files.ptattr
  plafile= files.pla
  arcs_resfile= files.arcs_res
  res_phasefile= files.res_phase
  time_series_linearfile= files.time_series_linear
  res_phase_slfile= files.res_phase_sl
  res_phase_tlfile= files.res_phase_tl
  final_resultfile= files.final_result
  nonlinearfile= files.nonlinear
  atmfile= files.atm
  time_seriestxtfile= files.time_seriestxt
  dhtxtfile= files.dhtxt
  vtxtfile= files.vtxt
  
  logfile= hpapath+'log.txt'     ; Log file.
  ; If logfile already exist, then append. If not, create a new one.
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  PrintF, loglun, 'Workpath:'+workpath
  PrintF, loglun, 'We use gamma pdiff as input.'
  PrintF, loglun, ''
  PrintF, loglun, 'Start at time :'+STRJOIN(TLI_TIME())
  
  IF 0 THEN BEGIN
    ; Generate basefile and the final merged files.
    TLI_MERGE_RESULTS_ALL, hpapath, 'plist', level=level, outputfile=plistfile
    TLI_MERGE_RESULTS_ALL, hpapath, 'ptattr', level=level, outputfile=ptattrfile
    TLI_MERGE_RESULTS_ALL, hpapath, 'vdh', level=level, outputfile=vdhfile
    TLI_GAMMA_BP_LA_FUN, plistfile, itabfile, sarlistfile, basepath, pbasefile, plafile,gamma=gamma
  ENDIF
  
  ; Load master slc header.
  nintf= FILE_LINES(itabfile)
  ;  itab= LONARR(4, nintf)
  ;  OPENR, lun, itabfile,/GET_LUN
  ;  READF, lun, itab
  ;  FREE_LUN, lun
  ;  mind= itab[0, *]
  ;  mind= mind[UNIQ(mind)]
  ;  nslc= FILE_LINES(sarlistfile)
  ;  sarlist= STRARR(nslc)
  ;  OPENR, lun, sarlistfile,/GET_LUN
  ;  READF, lun, sarlist
  ;  FREE_LUN, lun
  ;  mslc= sarlist[mind-1]
  ;  PrintF,loglun, ''
  ;  PrintF,loglun, 'Master slc image: ', mslc
  ;  finfo= TLI_LOAD_SLC_PAR(mslc+'.par')
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  PrintF, loglun, 'Samples:'+STRCOMPRESS(finfo.range_samples)
  PrintF, loglun, 'Lines:'+STRCOMPRESS(finfo.azimuth_lines)
  PrintF, loglun, 'Range_pixel_spacing:'+STRCOMPRESS(finfo.range_pixel_spacing)
  PrintF, loglun, 'Azimuth_pixel_spacing:'+STRCOMPRESS(finfo.azimuth_pixel_spacing)
  
  
  
  
  ; locate the reference point
  refind=127700
  plist_orig=TLI_READMYFILES(plistfile_orig, type='plist')
  refcoor=plist_orig[refind]
  ;  ref_coor=COMPLEX(3402,5575)
  PrintF, loglun, 'Ref. ind.: '+STRING(refind)
  PrintF, loglun, 'Ref. coor.: '+STRING(refcoor)
  PrintF, loglun, 'Plist file: '+plistfile_orig
  
  ; Find the ref. ind in plist file.
  plist=TLI_READMYFILES(plistfile,type='plist')
  refind=WHERE(plist EQ refcoor)
  IF refind EQ -1 THEN BEGIN
    Message, 'Error! No such point in plist file.'
  ENDIF
  PrintF, loglun, ''
  PrintF, loglun, 'Ref. ind. in the final plist file: '+STRING(refind)
  PrintF, loglun, 'Final plist file: '+plistfile
  
  IF 0 THEN BEGIN
    ; 残差分解--------------------------------------------------------------------------------------------------------------------------
    ; 重新构建连接关系
    Print, 'Retriving connectivities...'
    TLI_RETR_ARCS, plistfile, ptattrfile, refind, arcs_resfile=arcs_resfile
    Print, 'Calculating residuals for each point...'
    ; 计算每个点的残差
    wavelength= c/finfo.radar_frequency;fstruct.wavelength ; ********************************************************请在裁剪后的文件头(*.hdr)中加入此信息：波长***********************************
    R1= DOUBLE(finfo.near_range_slc)
    rps= DOUBLE(finfo.range_pixel_spacing)
    TLI_GET_RESIDUALS, sarlistfile, plistfile, itabfile, pdiff_swapfile, pbasefile,plafile, vdhfile,refind, $
      res_phasefile= res_phasefile, time_series_linearfile= time_series_linearfile,$
      R1,rps, wavelength
      
    ; 空间低频滤波
    Print, 'Doing spatially low pass filtering...'
    aps= finfo.azimuth_pixel_spacing ; Azimuth pixel spacing; fstruct.azimuth_pixel_spacing***************************Please add this parameter in the .hdr file********************
    rps= finfo.range_pixel_spacing ; Range pixel spacing; fstruct.range_pixel_spacing*******************************Please add this parameter in the .hdr file********************
    winsize= 500 ; 大气残差滤波窗口，推荐范围[500-1000]，此处影像太小，窗口太大会有问题
    
    TLI_SL_FILTER, plistfile, res_phasefile, res_phase_slfile= res_phase_slfile,$
      aps, rps, winsize
  ENDIF
  ;时域低频滤波，获取非线性分量
  Print, 'Doing temporally low pass filtering...'
  
  low_f=0 ; Low frequency for filtering 带通滤波器下限
  high_f=0.25; High frequency for filtering 带通滤波器上限
  ;时域高频滤波，获取大气分量
  TLI_TL_FILTER,plistfile, res_phase_slfile, low_f, high_f, res_phase_tlfile= nonlinearfile
  plistfile= plistfile
  res_phase_slfile= res_phase_slfile
  res_phase_tlfile= atmfile
  low_f=0.25 ; Low frequency for filtering 带通滤波器下限
  high_f=1; High frequency for filtering 带通滤波器上限
  TLI_TL_FILTER, plistfile, res_phase_slfile, low_f, high_f, res_phase_tlfile=atmfile
  
  ; 整理结果--------------------------------------------------------------------------------------------------------------------------
  ; 输出二进制文件
  lamda=c/finfo.radar_frequency;fstruct.wavelength ; ********************************************************Pls add this param in *.hdr file***********************************
  Print, 'Sorting out the results...'
  TLI_SORTOUT_FINAL, plistfile, time_series_linearfile, nonlinearfile,lamda, final_resultfile= final_resultfile
  
  ; 输出txt文件
  ref_v=0
  ref_dh=0
  TLI_SORTOUT_TXT,vdhfile, plistfile, itabfile, sarlistfile, final_resultfile,$
    time_seriestxtfile=time_seriestxtfile, dhtxtfile= dhtxtfile, vtxtfile= vtxtfile,$
    refind, ref_v, ref_dh
    
  Print, 'Phase residuals are decomposed.'
  
  PrintF,loglun,  'END_Time:'+STRJOIN(TLI_TIME())
  
  FREE_LUN, loglun
  CLOSE,/ALL
  
END
