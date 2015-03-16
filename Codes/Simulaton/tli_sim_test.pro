PRO TLI_SIM_TEST

  COMPILE_OPT idl2
  c= 299792458D ; Speed light
  
  workpath='/mnt/software/myfiles/Software/experiment/sim'
  
  resultpath=workpath+'/testforCUHK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    pdifffile= workpath+'/simph'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= resultpath+PATH_SEP()+'plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=resultpath+PATH_SEP()+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=resultpath+PATH_SEP()+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    plafile=resultpath+PATH_SEP()+'pla'
    dvddhfile=resultpath+PATH_SEP()+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= resultpath+PATH_SEP()+'vdh'
    ptattrfile= resultpath+PATH_SEP()+'ptattr'
    plistfile= resultpath+PATH_SEP()+'plist'                            ; PS点列表
    sarlistfile= resultpath+PATH_SEP()+'sarlist_Linux'                        ; 文件列表
    arcsfile= resultpath+PATH_SEP()+'arcs'                              ; 网络弧段列表
    pslcfile= resultpath+PATH_SEP()+'pslc'                              ; 点位上的SLC
    interflistfile= resultpath+PATH_SEP()+'Interf.list'                 ; 干涉列表
    pbasefile=resultpath+PATH_SEP()+'pbase'                             ; 点位基线文件
    dvddhfile=resultpath+PATH_SEP()+'dvddh'                             ; 弧段相对形变速率以及相对高程误差
    vdhfile= resultpath+PATH_SEP()+'vdh'                                ; 点位形变速率以及高程误差
    ptattrfile= resultpath+PATH_SEP()+'ptattr'                          ; 点位信息文件(包含结算过程中所有有用信息)
    plafile= resultpath+PATH_SEP()+'pla'                                ; 点位侧视角文件
    arcs_resfile= resultpath+PATH_SEP()+'arcs_res'                      ; 弧段残差
    res_phasefile= resultpath+PATH_SEP()+'res_phase'                    ; 点位残差
    time_series_linearfile= resultpath+PATH_SEP()+'time_series_linear'  ; 线性形变
    res_phase_slfile= resultpath+PATH_SEP()+'res_phase_sl'              ; 空间滤波结果
    res_phase_tlfile= resultpath+PATH_SEP()+'res_phase_tl'              ; 时间滤波结果
    final_resultfile= resultpath+PATH_SEP()+'final_result'              ; 形变时间序列
    nonlinearfile= resultpath+PATH_SEP()+'nonlinear'                    ; 非线性形变序列
    atmfile= resultpath+PATH_SEP()+'atm'                                ; 大气残差
    time_seriestxtfile= resultpath+PATH_SEP()+'Deformation_Time_Series_Per_SLC_Acquisition_Date.txt'
    dhtxtfile= resultpath+PATH_SEP()+'HeightError.txt'                  ; 最终产品：高程误差
    vtxtfile= resultpath+PATH_SEP()+'Deformation_Average_Annual_Rate.txt' ; 最终产品：点位年形变速率
    logfile= resultpath+PATH_SEP()+'log.txt'
    
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    outfile=TLI_DIRW2L(outfile,/reverse)
  ENDELSE
  
  starttime= SYSTIME(/SECONDS)
  
  ; Load master slc header.
  nintf= FILE_LINES(itabfile)
  nslc= FILE_LINES(sarlistfile)
  finfo= TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  IF 1 THEN BEGIN
    ;将GAMMA的SLC_tab转换为内部各式
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    
    ;;将GAMMA的plist转换为内部格式
    TLI_GAMMA2MYFORMAT_PLIST, plistfilegamma, plistfile
    
    IF 1 THEN BEGIN
      rps=finfo.range_pixel_spacing
      aps=finfo.azimuth_pixel_spacing
      disthresh=500
      optimize=1
      corrthresh=0.8
      ; Networking.
      ; Free network.
      TLI_HPA_FREENETWORK, plistfilegamma,pdifffile, rps, aps, $
        disthresh=disthresh,corrthresh=corrthresh,arcsfile=arcsfile, optimize=optimize, txt=txt
    ENDIF ELSE BEGIN
    
    
    
      range_pixel_spacing= finfo.range_pixel_spacing
      azimuth_pixel_spacing= finfo.azimuth_pixel_spacing
      dist_thresh=1000
      
      ; Delaunay Triangulation.
      result= TLI_DELAUNAY(plistfile,outname=arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
    ENDELSE
    IF 0 THEN BEGIN
      arcs_no= TLI_ARCNUMBER(arcsfile)
      arcs= COMPLEXARR(3, arcs_no)
      OPENR, lun, arcsfile,/GET_LUN
      READU, lun, arcs
      FREE_LUN, lun
      arcs= arcs[0:1, *]
      
      scale=0.2           ;  Strech scale for all the coordinates
      scale_r=0.3            ;  Strech scale for range coordinates
      scale_azi=0.3          ;  Strech scale for azimuth coordinates
      DEVICE, DECOMPOSED=0
      TVLCT, 0,255,0,1
      FOR i=0, arcs_no-1 DO BEGIN
        coor= arcs[*, i]*scale
        PLOTS, [REAL_PART(coor[0]),REAL_PART(coor[1])], [IMAGINARY(coor[0]), IMAGINARY(coor[1])], $
          color=1,/DEVICE
      ENDFOR
    ENDIF
    
    
    Print, 'Delaunay Triangulation Done!!!'
  ENDIF
  
  
  IF 1 THEN BEGIN
  
  
    wavelength= c/finfo.radar_frequency
    deltar= finfo.range_pixel_spacing
    R1= finfo.near_range_slc
    
    TLI_LINEAR_SOLVE_GAMMA, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
      wavelength, deltar, R1
      
    ; 自动选择影像中心点作为参考点，仅作测试用...
    IF 1 THEN BEGIN
      plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
      samples= DOUBLE(finfo.range_samples)
      lines= DOUBLE(finfo.azimuth_lines)
      plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
      min_dist= MIN(plist_dist, refind)
      Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
    ENDIF
    ref_v=0          ; 参考点形变速率，外部数据，需用户指定，默认为0
    ref_dh=0         ; 参考点高程误差, 外部数据，需用户指定，默认为0
    mask_arc= 0.98    ; 范围[0,1]  推荐范围[0.8,1] 弧段时序相关系数阈值
    mask_pt_coh= 0.95 ; 范围[0,1]  推荐范围[0.8,1] 点位时序相关系数阈值
    refind= refind   ; 参考点坐标，需交互选定
    v_acc= 10        ; 相对形变速率极限误差 ，推荐范围[5,100]
    dh_acc= 10       ; 高程极限误差 ，推荐范围[10,100]
    TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    
    ;  TLI_RG_DVDDH, plistfile, dvddhfile, vdhfile, mask_arc, refind
    ;      TLI_RG_DVDDH_NOWEIGHT, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    ;  TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
    
    v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
    x= v[1,*]
    y= v[2,*]
    z= v[3,*]
    show_z= BYTSCL(z)
    Print, '[max min] of z:',MAX(z), MIN(z)
    z_std= STDDEV(z)
    z_m= MEAN(z)
    ind= WHERE((z GE z_m-z_std*3) AND (z LE z_m+3*z_std))
    z_n= z[*, ind]
    Print, '[max min] of z(optimized):',MAX(z_n), MIN(z_n)
    Print, 'STD of z:', STDDEV(z_n)
  ENDIF
END