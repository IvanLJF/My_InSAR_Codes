PRO TEST_SOLVE

  ; Data Preparation
  Case !D.NAME OF
    'X': BEGIN
      workpath='/mnt/software/myfiles/Software/experiment/TerraSARTestArea'
      slcpath=workpath+'/Area_Management/Area_Processing/Area1'
      diffpath=workpath+'/Basic_InSAR/Interferogram_Generation/Area1'
      resultpath=workpath+'/PSI'
      paramfile='/mnt/backup/TSX-HK/PasEst.txt';************************此处应该使用裁剪之后的PasEst.txt，而不应该是原始影像的ParEst.txt**********
    END
    'WIN': BEGIN
      workpath='D:\myfiles\Software\experiment\TerraSARTestArea'
      slcpath=workpath+'\Area_Management\Area_Processing\Area1'
      diffpath=workpath+'\Basic_InSAR\Interferogram_Generation\Area1'
      resultpath=workpath+'\PSI'
      paramfile='F:\TSX-HK\PasEst.txt'
    END
    ELSE:
  ENDCASE
  
  plistfile= resultpath+PATH_SEP()+'plist'                            ; PS点列表
  sarlistfile= resultpath+PATH_SEP()+'sarlist'                        ; 文件列表
  arcsfile= resultpath+PATH_SEP()+'arcs'                              ; 网络弧段列表
  itabfile= resultpath+PATH_SEP()+'itab'                              ; 干涉组合列表
  pslcfile= resultpath+PATH_SEP()+'pslc'                              ; 点位上的SLC
  interflistfile= resultpath+PATH_SEP()+'Interf.list'                 ; 干涉列表
  pdifffile= resultpath+PATH_SEP()+'pdiff'                            ; 点位上的差分结果
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
  logfile= resultpath+PATH_SEP()+'log.txt'
  OPENW, loglun, logfile,/GET_LUN
  
  
  time_seriestxtfile= resultpath+PATH_SEP()+'Deformation_Time_Series_Per_SLC_Acquisition_Date.txt' ; 最终产品：形变时间序列
  dhtxtfile= resultpath+PATH_SEP()+'HeightError.txt'                  ; 最终产品：高程误差
  vtxtfile= resultpath+PATH_SEP()+'Deformation_Average_Annual_Rate.txt' ; 最终产品：点位年形变速率
  
  ; Load file info
  fname=slcpath+PATH_SEP()+'tsx-20091114.rslc'                       ;任意影像的全路径。目的是为了获取影像行列号以及其它简单信息。
  fname= STRSPLIT(fname, '.',/EXTRACT)
  fname= fname[0]+'.hdr'
  fstruct= TLI_LOAD_CUHK_HDR(fname)
  ; Input files and some params
  samples= fstruct.samples_
  lines= fstruct.lines_
  data_type= LONG(fstruct.data_type_)
  byte_order= LONG(fstruct.byte_order_)
  Case data_type OF
    2: BEGIN
      int=1
    END
    3: BEGIN
      long=1
    END
    4: BEGIN
      float=1
    END
    6: BEGIN
      fc=1
    END
  ENDCASE
  Case byte_order OF
    0 : BEGIN
      swap_endian=0
    END
    1: BEGIN
      swap_endian=1
    END
  ENDCASE
  
  
  PrintF, loglun, 'Image info:'
  PrintF, loglun, 'range_amples: '+STRCOMPRESS(samples)
  PrintF, loglun, 'azimuth_lines: '+STRCOMPRESS(lines)
  
  st= SYSTIME(/SECONDS)
  PRINTF, loglun, 'Start at time:'+STRCOMPRESS(st)
  PrintF, loglun, ''
  PrintF, loglun, 'Selecting PSc and networking.'
  st= SYSTIME(/SECONDS)
  PrintF, loglun, 'Start at time:'+STRCOMPRESS(st)
  IF 1 THEN BEGIN
    IF 1 THEN BEGIN
      ; 选取PS点--------------------------------------------------------------------------------------------------------------------------
      ;- 生成影像列表文件sarlist.
      path=slcpath
      outfile= sarlistfile
      suffix= '.rslc'
      result= TLI_SARLIST(path, suffix, outfile=outfile)
      PRINT, '**************************************'
      PRINT, '* Sarlist file written successfully! *'
      PRINT, '**************************************'
      
      ;- 选取PS点
      outfile= plistfile
      thr_da= 0.25
      thr_amp= 1
      sarlistfile=sarlistfile
      result= TLI_PSSELECT(sarlistfile, samples, lines,$
        float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
        outfile=outfile, thr_da=thr_da, thr_amp=thr_amp)
      PRINT, '**************************************'
      PRINT, '*   PSs file written successfully    *'
      PRINT, '**************************************'
      
      ;- 显示结果
      IF 0 THEN BEGIN
        plist= COMPLEXARR(TLI_PNUMBER(plistfile))
        OPENR, lun, plistfile,/GET_LUN
        READU, lun, plist;点坐标文件
        FREE_LUN, lun
        
        tempmaster=''
        OPENR, lun, sarlistfile,/GET_LUN
        READF, lun, tempmaster
        FREE_LUN, lun
        
        pwr= COMPLEXARR(samples, lines)
        OPENR, lun, tempmaster
        READU, lun, pwr
        FREE_LUN, lun
        pwr= ALOG(ABS(pwr))
        ;    pwr= ABS(OPENSLC(tempmaster,columns=3500,lines=3500,data_type='SCOMPLEX',/swap_endian));底图
        scale= 0.5
        sz=SIZE(pwr,/DIMENSIONS)
        pwr= CONGRID(pwr,sz[0]*scale, sz[1]*scale)
        ;  pwr= ROTATE(pwr, 5)
        ps_index_s= REAL_PART(plist)*scale
        ps_index_l= IMAGINARY(plist)*scale
        WINDOW, xpos=0, ypos=0, xsize=sz[0]*scale, ysize=sz[1]*scale,0
        ;    TVSCL, linear2(pwr)
        TVSCL, pwr,/NAN
        PLOTS, ps_index_s, ps_index_l, psym=1, symsize=1, COLOR=200,/DEVICE
      ENDIF
      
      ; 构网--------------------------------------------------------------------------------------------------------------------------
      plist= plistfile
      outname= arcsfile
      
      range_pixel_spacing= 0.9; fstruct.rps********************************************************请在裁剪后的文件头(*.hdr)中加入此信息：斜距向分辨率***********************************
      azimuth_pixel_spacing= 2.0; fstruct.aps********************************************************请在裁剪后的文件头(*.hdr)中加入此信息：方位向分辨率***********************************
      dist_thresh=1000
      result= TLI_DELAUNAY(plist,outname=outname, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
      
      
      infile= arcsfile
      file_structure= FILE_INFO(infile)
      arcs_no=file_structure.size/24
      PRINT, 'There are', STRCOMPRESS(arcs_no),' arcs in the Delaunay triangulation.'
      PRINTF, loglun,  'There are'+STRCOMPRESS(arcs_no)+' arcs in the Delaunay triangulation.'
      ; 显示
      IF 0 THEN BEGIN
        arcs= COMPLEXARR(3, arcs_no)
        OPENR, lun, infile,/GET_LUN
        READU, lun, arcs
        FREE_LUN, lun
        arcs= arcs[0:1, *]
        
        scale=1           ;  Strech scale for all the coordinates
        scale_r=1            ;  Strech scale for range coordinates
        scale_azi=1          ;  Strech scale for azimuth coordinates
        
        pwrfile=' '
        OPENR, lun, sarlistfile,/GET_LUN
        READF, lun, pwrfile
        FREE_LUN, lun
        
        fstruct= TLI_LOAD_CUHK_HDR((STRSPLIT(pwrfile,'.',/EXTRACT))[0]+'.hdr')
        slc= TLI_READDATA(pwrfile, samples=fstruct.samples_, format='FCOMPLEX')
        avepwr= ABS(slc)
        ;  avepwr= ALOG10(avepwr)
        
        WINDOW, xsize= DOUBLE(fstruct.samples_), ysize= DOUBLE(fstruct.lines_)
        TV, avepwr
        DEVICE, DECOMPOSED=0
        
        TVLCT, 0,255,0,1
        
        FOR i=0, arcs_no-1 DO BEGIN
          coor= arcs[*, i]*scale
          PLOTS, [REAL_PART(coor[0]),REAL_PART(coor[1])], [IMAGINARY(coor[0]), IMAGINARY(coor[1])], $
            color=1,/DEVICE
        ENDFOR
      ENDIF
      et= SYSTIME(/SECONDS)
      PRINTF, loglun, 'End at time:'+STRCOMPRESS(et)
      PrintF, loglun, 'Time consumed:'+STRCOMPRESS((et-st)/3600D)+' h'
      st=SYSTIME(/SECONDS)
      PrintF, loglun, ''
      PrintF, loglun, 'Preparing data for model calculation...'
      PrintF, loglun, 'Start at time:'+STRCOMPRESS(st)
      
      ; 生成干涉組合文件-------------------------------------------------------------------
      paramfile= paramfile
      sarlist= sarlistfile
      method= 0
      output_file= itabfile
      ;    master=26 ;************************************運行時應設置method=0，并刪除‘master=26’**********
      result=TLI_ITAB(paramfile, sarlist,method=method, master=26, output_file=output_file)
      ; 生成點位SLC文件----------------------------------------------------------------------------
      sarlist= sarlistfile
      plist= plistfile
      samples= samples
      lines= lines
      data_type= 'FCOMPLEX'
      swap_endian= swap_endian
      outfile= pslcfile
      result=TLI_PSLC(sarlist,plist, samples, lines,data_type,$
        swap_endian=swap_endian, outfile=outfile, changed_coor= changed_coor)
      npt= TLI_PNUMBER(plistfile)
      PrintF, loglun, 'Number of PSc:', STRCOMPRESS(npt)
      PrintF, loglun, 'Number of interferograms:', STRCOMPRESS(FILE_LINES(sarlistfile))
      Print, 'Number of PSs:', STRCOMPRESS(npt)
      Print, 'Number of interferograms:', STRCOMPRESS(FILE_LINES(sarlistfile))
      ; 生成點位差分文件pdiff，点位基线文件pbase，点位侧视角文件pla---------------------------------------------------------
      ; 創建 intf.list file
      sarlistfile= sarlistfile
      itabfile= itabfile
      interflistfile=interflistfile
      TLI_INTFLIST, sarlistfile, itabfile, interflistfile= interflistfile
      
      ; ******************************************************接下來應該使用Intf.list文件生成差分干涉圖***********************************
      ;
      ; ******************************************************使用Intf.list文件生成差分干涉圖***********************************
      
      diffpath=diffpath
      resultpath=resultpath
      samples=fstruct.samples_
      lines=fstruct.lines_
      
      sarlistfile= sarlistfile
      itabfile= itabfile
      plistfile= plistfile
      
      pdifffile= pdifffile
      pbasefile= pbasefile
      plafile= plafile
      TLI_PDIFF, diffpath, resultpath, samples, lines, sarlistfile, itabfile, plistfile, pdifffile=pdifffile
      TLI_PBASE, diffpath, resultpath, samples, lines, sarlistfile, itabfile, plistfile, pbasefile=pbasefile
      
      sarlistfile=sarlistfile
      itabfile=itabfile
      plistfile=plistfile
      samples= fstruct.samples_
      plafile= plafile
      TLI_PLOOKANGLE, sarlistfile, itabfile, plistfile, samples, plafile
      et= SYSTIME(/SECONDS)
      PrintF, loglun, 'End at time:'+STRCOMPRESS(et)
      PrintF, loglun, 'Time consumed:'+STRCOMPRESS((et-st)/3600D)
      PrintF, loglun, ''
      PrintF, loglun, 'Calculating parameters...'
      st= SYSTIME(/SECONDS)
      PrintF, loglun, 'Start at time:'+STRCOMPRESS(st)
      
      ; 解算相对形变速率以及相对高程误差--------------------------------------------------------------------------------------------------------------------------
      wavelength= 0.031;fstruct.wavelength ; ********************************************************请在裁剪后的文件头(*.hdr)中加入此信息：波长***********************************
      mapinfo= fstruct.map_info_
      mapinfo= STRSPLIT(mapinfo, ',',/EXTRACT)
      R1= DOUBLE(mapinfo[3])
      deltar= DOUBLE(mapinfo[5])
      TLI_LINEAR_SOLVE_CUHK,  sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
        wavelength, deltar, R1
        
      ; 解算形变速率以及高程误差--------------------------------------------------------------------------------------------------------------------------
      ;****************************此处应交互选取参考点******************************
        
      ; 自动选择影像中心点作为参考点，仅作测试用...
      IF 1 THEN BEGIN
        plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
        samples= DOUBLE(fstruct.samples_)
        lines= DOUBLE(fstruct.lines_)
        plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
        min_dist= MIN(plist_dist, refind)
        Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
        PrintF, loglun, 'Reference point index:'+STRCOMPRESS(refind)+'.   Coordinates:'+STRCOMPRESS( plist[refind])
      ENDIF
      ; 自动选择影像中心点作为参考点，仅作测试用.
      
      ref_v=0          ; 参考点形变速率，外部数据，需用户指定，默认为0
      ref_dh=0         ; 参考点高程误差, 外部数据，需用户指定，默认为0
      mask_arc= 0.3   ; 范围[0,1]  推荐范围[0.8,1] 弧段时序相关系数阈值
      mask_pt_coh= 0.3 ; 范围[0,1]  推荐范围[0.8,1] 点位时序相关系数阈值
      refind= refind   ; 参考点坐标，需交互选定
      v_acc= 10        ; 相对形变速率极限误差 ，推荐范围[5,100]
      dh_acc= 10       ; 高程极限误差 ，推荐范围[10,100]
      TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile,mask_arc, mask_pt_coh, refind, v_acc, dh_acc
      
      
      IF 0 THEN BEGIN
        TLI_LS_DVDDH,plistfile, arcsfile, dvddhfile, plistfile_update=plistfile_update, vdhfile=vdhfile, logfile=logfile
      ENDIF
      
      
    ENDIF
    et= SYSTIME(/SECONDS)
    PrintF, loglun, 'End at time:'+STRCOMPRESS(et)
    PrintF,loglun, 'Time consumed:'+STRCOMPRESS((et-st)/3600D)
    PrintF, loglun, ''
    PrintF, loglun, 'Residual phase decomposing...'
    st= SYSTIME(/SECONDS)
    PrintF, loglun, 'Start at time:'+STRCOMPRESS(st)
    
    IF 1 THEN BEGIN
      plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
      samples= DOUBLE(fstruct.samples_)
      lines= DOUBLE(fstruct.lines_)
      plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
      min_dist= MIN(plist_dist, refind)
      Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
    ENDIF
    ; 残差分解--------------------------------------------------------------------------------------------------------------------------
    ; 重新构建连接关系
    Print, 'Retriving connectivities...'
    plistfile=plistfile
    ptattrfile= ptattrfile
    refind= refind
    arcs_resfile= arcs_resfile
    ;  TLI_RETR_ARCS, plistfile, ptattrfile, refind, arcs_resfile=arcs_resfile
    Print, 'Calculating residuals for each point...'
    ; 计算每个点的残差
    sarlistfile= sarlistfile
    plistfile=plistfile
    itabfile=itabfile
    pdifffile=pdifffile
    pbasefile= pbasefile
    vdhfile= vdhfile
    refind=refind
    res_phasefile= res_phasefile
    time_series_linearfile= time_series_linearfile
    wavelength= 0.031;fstruct.wavelength ; ********************************************************请在裁剪后的文件头(*.hdr)中加入此信息：波长***********************************
    mapinfo= fstruct.map_info_
    mapinfo= STRSPLIT(mapinfo, ',',/EXTRACT)
    R1= DOUBLE(mapinfo[3])
    rps= DOUBLE(mapinfo[5])
    TLI_GET_RESIDUALS, sarlistfile, plistfile, itabfile, pdifffile, pbasefile,plafile, vdhfile,refind, $
      res_phasefile= res_phasefile, time_series_linearfile= time_series_linearfile,$
      R1,rps, wavelength
      
    ; 空间低频滤波
    Print, 'Doing spatially low pass filtering...'
    plistfile=plistfile
    res_phasefile= res_phasefile
    res_phase_slfile= res_phase_slfile
    aps= 1.90 ; Azimuth pixel spacing; fstruct.azimuth_pixel_spacing***************************Please add this parameter in the .hdr file********************
    rps= 1.36 ; Range pixel spacing; fstruct.range_pixel_spacing*******************************Please add this parameter in the .hdr file********************
    winsize= 100 ; 大气残差滤波窗口，推荐范围[500-1000]，此处影像太小，窗口太大会有问题
    
    TLI_SL_FILTER, plistfile, res_phasefile, res_phase_slfile= res_phase_slfile,$
      aps, rps, winsize
      
    ;时域低频滤波，获取非线性分量
    Print, 'Doing temporally low pass filtering...'
    plistfile= plistfile
    res_phase_slfile= res_phase_slfile
    res_phase_tlfile= nonlinearfile
    low_f=0 ; Low frequency for filtering 带通滤波器下限
    high_f=0.25; High frequency for filtering 带通滤波器上限
    ;时域高频滤波，获取大气分量
    TLI_TL_FILTER,plistfile, res_phase_slfile, low_f, high_f, res_phase_tlfile= res_phase_tlfile
    plistfile= plistfile
    res_phase_slfile= res_phase_slfile
    res_phase_tlfile= atmfile
    low_f=0.25 ; Low frequency for filtering 带通滤波器下限
    high_f=1; High frequency for filtering 带通滤波器上限
    TLI_TL_FILTER, plistfile, res_phase_slfile, low_f, high_f, res_phase_tlfile=atmfile
    
    ; 整理结果--------------------------------------------------------------------------------------------------------------------------
    ; 输出二进制文件
    plistfile= plistfile
    time_series_linearfile=time_series_linearfile
    nonlinearfile=nonlinearfile
    final_resultfile= final_resultfile
    lamda=0.031;fstruct.wavelength ; ********************************************************Pls add this param in *.hdr file***********************************
    Print, 'Sorting out the results...'
    TLI_SORTOUT_FINAL, plistfile, time_series_linearfile, nonlinearfile,lamda, final_resultfile= final_resultfile
    
  ENDIF
  
  ; 输出txt文件
  IF 1 THEN BEGIN
    plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
    samples= DOUBLE(fstruct.samples_)
    lines= DOUBLE(fstruct.lines_)
    plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
    min_dist= MIN(plist_dist, refind)
    Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
  ENDIF
  
  vdhfile= vdhfile
  plistfile= plistfile
  itabfile= itabfile
  sarlistfile= sarlistfile
  final_resultfile= final_resultfile
  time_seriestxtfile= time_seriestxtfile
  dhtxtfile=dhtxtfile
  vtxtfile= vtxtfile
  refind=refind
  ref_v=0
  ref_dh=0
  TLI_SORTOUT_TXT,vdhfile, plistfile, itabfile, sarlistfile, final_resultfile,$
    time_seriestxtfile=time_seriestxtfile, dhtxtfile= dhtxtfile, vtxtfile= vtxtfile,$
    refind, ref_v, ref_dh
    
  Print, 'Phase residuals are decomposed.'
  et= SYSTIME(/SECONDS)
  PrintF, loglun, 'End at time:'+STRCOMPRESS(et)
  PrintF, loglun, 'Time consumed:'+STRCOMPRESS((et-st)/3600D)
  FREE_LUN, loglun
END