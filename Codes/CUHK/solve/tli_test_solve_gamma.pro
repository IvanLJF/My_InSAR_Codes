PRO TLI_TEST_SOLVE_GAMMA

  COMPILE_OPT idl2
  CLOSE,/ALL
  starttime= SYSTIME(/SECONDS)
  c= 299792458D ; Speed light
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_DAM'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'/testforCUHK'
  resultpath=resultpath+PATH_SEP()
  basepath=workpath+'base'
  ; Input files
  sarlistfilegamma= workpath+'SLC_tab'
  pdifffile= workpath+'pdiff0'
  pdiff_swapfile= workpath+'pdiff0_swap'
  plistfilegamma= workpath+'pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= resultpath+'plist'
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=resultpath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=resultpath+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  dvddhfile=resultpath+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= resultpath+'vdh'
  sarlistfile= resultpath+'sarlist'
  ptattrfile= resultpath+'ptattr'                          ; 点位信息文件(包含结算过程中所有有用信息)
  plafile= resultpath+'pla'                                ; 点位侧视角文件
  arcs_resfile= resultpath+'arcs_res'                      ; 弧段残差
  res_phasefile= resultpath+'res_phase'                    ; 点位残差
  time_series_linearfile= resultpath+'time_series_linear'  ; 线性形变
  res_phase_slfile= resultpath+'res_phase_sl'              ; 空间滤波结果
  res_phase_tlfile= resultpath+'res_phase_tl'              ; 时间滤波结果
  final_resultfile= resultpath+'final_result'              ; 形变时间序列
  nonlinearfile= resultpath+'nonlinear'                    ; 非线性形变序列
  atmfile= resultpath+'atm'                                ; 大气残差
  time_seriestxtfile= resultpath+'Time_Series.txt'
  dhtxtfile= resultpath+'HeightError.txt'                  ; 最终产品：高程误差
  vtxtfile= resultpath+'Deformation_Rate.txt' ; 最终产品：点位年形变速率
  
  logfile= resultpath+'log.txt'     ; Log file.
  ; If logfile already exist, then append. If not, create a new one.
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  PrintF, loglun, 'Workpath:'+workpath
  PrintF, loglun, 'We use gamma pdiff as input.'
  PrintF, loglun, ''
  PrintF, loglun, 'Start at time (JULIAN):'+STRCOMPRESS(SYSTIME(/JULIAN))
  st= SYSTIME(/SECONDS)
  PrintF, loglun, 'Start at time (Seconds):'+STRCOMPRESS(LONG(st))
  
  IF 1 THEN BEGIN
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    TLI_GAMMA2MYFORMAT_PLIST, plistfilegamma, plistfile
    ; Generate basefile
    TLI_GAMMA_BP_LA_FUN, plistfile, itabfile, sarlistfile, basepath, pbasefile, plafile,gamma=gamma
  ENDIF
  
  ; Load master slc header.
  nintf= FILE_LINES(itabfile)
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  mind= itab[0, *]
  mind= mind[UNIQ(mind)]
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  mslc= sarlist[mind-1]
  PrintF,loglun, ''
  PrintF,loglun, 'Master slc image: ', mslc
  finfo= TLI_LOAD_SLC_PAR(mslc+'.par')
  PrintF, loglun, 'Samples:'+STRCOMPRESS(finfo.range_samples)
  PrintF, loglun, 'Lines:'+STRCOMPRESS(finfo.azimuth_lines)
  PrintF, loglun, 'Range_pixel_spacing:'+STRCOMPRESS(finfo.range_pixel_spacing)
  PrintF, loglun, 'Azimuth_pixel_spacing:'+STRCOMPRESS(finfo.azimuth_pixel_spacing)
  
  IF 1 THEN BEGIN
  
    PrintF, loglun, ''
    PrintF, loglun, 'Params set for networking:'
    IF 1 THEN BEGIN
      IF 1 THEN BEGIN
        rps=finfo.range_pixel_spacing
        aps=finfo.azimuth_pixel_spacing
        disthresh=100
        optimize=1
        corrthresh=0.8
        ; Networking.
        ; Free network.
        TLI_HPA_FREENETWORK, plistfilegamma,pdifffile, rps, aps, $
          disthresh=disthresh,corrthresh=corrthresh,arcsfile=arcsfile, optimize=optimize, txt=txt,/swap_endian
        ; Write log file.
        Printf, loglun, 'disthresh: '+STRCOMPRESS(disthresh)
        Printf, loglun, 'optimize: '+STRCOMPRESS(optimize)
        Printf, loglun, 'corrthresh: '+STRCOMPRESS(corrthresh)
        ; Check arcs
        npt=TLI_PNUMBER(plistfile)
        PrintF,loglun, 'Free networking generates'+STRCOMPRESS(npt*(npt-1)/2D)+' arcs.'
        narcs= TLI_ARCNUMBER(arcsfile)
        PrintF,loglun,  'Arcs after optimization:'+STRCOMPRESS(narcs)
      ENDIF ELSE BEGIN
        range_pixel_spacing= finfo.range_pixel_spacing
        azimuth_pixel_spacing= finfo.azimuth_pixel_spacing
        dist_thresh=100
        ;   Delaunay network.
        result=TLI_DELAUNAY(plistfile,outname=arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
        PrintF, loglun, 'dist_thresh:'+STRCOMPRESS(dist_thresh)
        narcs= TLI_ARCNUMBER(arcsfile)
        PrintF,loglun,  'Delaunay triangulation generates'+STRCOMPRESS(narcs)+' arcs.'
      ENDELSE
    ENDIF
    ; Solve dvddh.
    wavelength= c/finfo.radar_frequency
    deltar= finfo.range_pixel_spacing
    R1= finfo.near_range_slc
    
    TLI_LINEAR_SOLVE_GAMMA, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
      wavelength, deltar, R1
    et= SYSTIME(/SECONDS)
    ct= (et-st)/3600D
    PRINTF, loglun, 'Time consumed for networking and linear deformation calculation:'+STRCOMPRESS(ct)
    PrintF, loglun, ''
    PrintF, loglun, 'Params set for region growing:'
    st= et
    
    plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
    IF 1 THEN BEGIN
      samples= DOUBLE(finfo.range_samples)
      lines= DOUBLE(finfo.azimuth_lines)
      plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
      min_dist= MIN(plist_dist, refind)
    ENDIF
    Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
    PrintF, loglun,  'Reference point index:'+STRCOMPRESS(refind)+'. Coordinates:'+STRCOMPRESS(plist[refind])
    
    ref_v=0
    ref_dh=0
    weight=0  ; 0: coh
    ; 1: sigma
    ; 2: both
    mask_arc= 0.85
    mask_pt_coh= 0.9
    v_acc= 1 ; Accuracy threshold of deformation velocity: mm/yr
    dh_acc= 10 ; Accuracy threshold of hight error: m
    
    ; Solve vdh
    Print, refind
    TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile, mask_arc,mask_pt_coh, refind,v_acc, dh_acc
    
    PrintF, loglun, 'ref_v:'+STRCOMPRESS(ref_v)
    PrintF, loglun, 'ref_dh:'+STRCOMPRESS(ref_dh)
    PrintF, loglun, 'weight:'+STRCOMPRESS(weight)
    PrintF, loglun, 'mask_arc:'+STRCOMPRESS(mask_arc)
    PrintF, loglun, 'mask_pt_coh:'+STRCOMPRESS(mask_pt_coh)
    PrintF, loglun, 'v_acc:'+STRCOMPRESS(v_acc)
    PrintF, loglun, 'dh_acc:'+STRCOMPRESS(dh_acc)
    PrintF, loglun, 'hpa level 1 is finished.'
    PrintF, loglun, ''
    et= SYSTIME(/SECONDS)
    ct= (et-st)/3600D
    v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
    x= v[1,*]
    y= v[2,*]
    z= v[3,*]
    PrintF,loglun,  '[max min] of deformation velocity:'+STRCOMPRESS(MAX(z))+STRCOMPRESS(MIN(z))
    PrintF,loglun, 'Time consumed:'+STRCOMPRESS(ct)
    PrintF, loglun, ''
    PrintF, loglun, 'hpa level1 is finished.'
    Print, 'hpa level1 is finished.'
  ENDIF
  
  
  ; ******************************Residual phase decomposition***********************************************
  
  IF 1 THEN BEGIN
  
  
  
  
    IF 1 THEN BEGIN
      IF 1 THEN BEGIN
        plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
        samples= DOUBLE(finfo.range_samples)
        lines= DOUBLE(finfo.azimuth_lines)
        plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
        min_dist= MIN(plist_dist, refind)
        Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
      ENDIF
      
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
      winsize= 200 ; 大气残差滤波窗口，推荐范围[500-1000]，此处影像太小，窗口太大会有问题
      
      TLI_SL_FILTER, plistfile, res_phasefile, res_phase_slfile= res_phase_slfile,$
        aps, rps, winsize
        
      ;时域低频滤波，获取非线性分量
      Print, 'Doing temporally low pass filtering...'
      
      low_f=0 ; Low frequency for filtering 带通滤波器下限
      high_f=0.15; High frequency for filtering 带通滤波器上限
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
      
    ENDIF
      
    endtime= SYSTIME(/SECONDS)
    time_cons= (endtime-starttime)/3600D
    Print, 'Time consumed:', time_cons
  ENDIF
  
  FREE_LUN, loglun
  CLOSE,/ALL

END
