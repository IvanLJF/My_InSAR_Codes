;
; Some experiments on the journal: Remote Sensing.
;
; Written by:
;   T.LI @ SWJTU, 20140313
;
FUNCTION TLI_INFO_WITHIN_RANGE, info, range,ind=ind, samples=samples, lines=lines
  
  ; First change the range. The updated range is referred to the flipped image.
  range=[samples-1-range[2], range[1], samples-1-range[0], range[3]]
  
  ; Then change the info. The updated info is referred to the flipped image, its (0, 0) is located at the upper-left corner.
  
  x=info[0, *]
  y=lines-1-info[1, *]
  ind=WHERE(x GE range[0] AND $
            x LE range[2] AND $
            y GE range[1] AND $
            y LE range[3])
  IF ind[0] EQ -1 THEN Message, 'Error! No info in the given range.'
  result=[info[0,ind], lines-1-info[1, ind], info[2, ind]]  ; These are the right point set.
  
;  result=[result[0,*], lines-1-result[1, *], result[2, *]] ; These are the results prepared for GMT.
  
  RETURN, result

END


PRO TLI_REMOTESENSING



  ;*********************Show the valid point numbers of the AOIs in level 1 and level 10.******************
  IF 0 THEN BEGIN
    ; Define params.
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/HPA/'
    figpath=workpath+'figures/'
    lel1vdhfile=workpath+'vdh'
    lel10vdhfile=workpath+'lel10vdh_merge'
    
    ; Read the files
    lel1vdh=TLI_READMYFILES(lel1vdhfile, type='vdh')
    lel10vdh=TLI_READMYFILES(lel10vdhfile, type='vdh')
    samples=5000
    lines=6150
    
    ; Separate the plist
    lel1_r=(samples-1-lel1vdh[1, *])/2.09555
    ;  lel1_i=(lines-1-lel1vdh[2, *])/2.09326
    lel1_i=(lel1vdh[2, *])/2.09326
    ;  TLI_WRITE, figpath+'temp.txt', [lel1_r, lel1_i],/txt
    
    lel10_r=(samples-1-lel10vdh[1, *])/2.09555
    ;  lel10_i=(lines-1-lel10vdh[2, *])/2.09326
    lel10_i=(lel10vdh[2, *])/2.09326
    ;  WINDOW, xsize=650, ysize=800,/free
    ;  Plot, lel1_r, lel1_i, xrange=[0, 2385], yrange=[0,2937], psym=1, symsiz=2
    
    
    
    
    
    
    ; S6 (1900,0 - 2260, 320)  ; 这个坐标不是影像坐标……而是做完图之后的图像坐标……
    ; 做完图之后的影像大小是2386*2938
    ; 做图之前的影像大小是5000*6150
    ; 拉伸比例是2.09555*2.09326
    coors=[1900,0,2260,320]
    coors=double(coors)
    lel1_pts=where(lel1_r GE coors[0] and $
      lel1_r LE coors[2] and $
      lel1_i GE coors[1] and $
      lel1_i LE coors[3])
    lel10_pts=where(lel10_r GE coors[0] and $
      lel10_r LE coors[2] and $
      lel10_i GE coors[1] and $
      lel10_i LE coors[3])
    nptlel1=N_ELEMENTS(lel1_pts)
    nptlel10=N_ELEMENTS(lel10_pts)
    Print, 'Point numbers of lel1 and lel10 in AOI S6:',nptlel1, nptlel10
    
    lel1x=lel1_r[lel1_pts]
    lel1y=lel1_i[lel1_pts]
    lel10x=lel10_r[lel10_pts]
    lel10y=lel10_i[lel10_pts]
    xrange=[coors[0], coors[2]]
    yrange=[coors[1], coors[3]]
    window,/free, xsize=650, ysize=800
    ;  oPlot, lel1x, lel1y, xrange=[0, 2385], yrange=[0,2937], psym=1, symsiz=1
    Plot, lel10x, 2937-lel10y,xrange=[0, 2385], yrange=[0,2937],psym=1, symsize=1
    
    
    
    
    ; S7
    coors=[790,500,970,660]
    coors=double(coors)
    lel1_pts=where(lel1_r GE coors[0] and $
      lel1_r LE coors[2] and $
      lel1_i GE coors[1] and $
      lel1_i LE coors[3])
    lel10_pts=where(lel10_r GE coors[0] and $
      lel10_r LE coors[2] and $
      lel10_i GE coors[1] and $
      lel10_i LE coors[3])
    nptlel1=N_ELEMENTS(lel1_pts)
    nptlel10=N_ELEMENTS(lel10_pts)
    Print, 'Points numbers of lel1 and lel10 in AOI S7:',nptlel1, nptlel10
    
    lel1x=lel1_r[lel1_pts]
    lel1y=lel1_i[lel1_pts]
    lel10x=lel10_r[lel10_pts]
    lel10y=lel10_i[lel10_pts]
    xrange=[coors[0], coors[2]]
    yrange=[coors[1], coors[3]]
    ;  window,/free, xsize=650, ysize=800
    ;  oPlot, lel1x, lel1y, xrange=[0, 2385], yrange=[0,2937], psym=1, symsiz=1
    oPlot, lel10x, 2937-lel10y,psym=1, symsize=1
    
    ; S8
    coors=[2140,1167,2380,1380]
    coors=double(coors)
    lel1_pts=where(lel1_r GE coors[0] and $
      lel1_r LE coors[2] and $
      lel1_i GE coors[1] and $
      lel1_i LE coors[3])
    lel10_pts=where(lel10_r GE coors[0] and $
      lel10_r LE coors[2] and $
      lel10_i GE coors[1] and $
      lel10_i LE coors[3])
    nptlel1=N_ELEMENTS(lel1_pts)
    nptlel10=N_ELEMENTS(lel10_pts)
    Print, 'Points numbers of lel1 and lel10 in AOI S8:',nptlel1, nptlel10
    
    lel1x=lel1_r[lel1_pts]
    lel1y=lel1_i[lel1_pts]
    lel10x=lel10_r[lel10_pts]
    lel10y=lel10_i[lel10_pts]
    xrange=[coors[0], coors[2]]
    yrange=[coors[1], coors[3]]
    ;  window,/free, xsize=650, ysize=800
    ;  oPlot, lel1x, lel1y, xrange=[0, 2385], yrange=[0,2937], psym=1, symsiz=1
    oPlot, lel10x, 2937-lel10y,psym=1, symsize=1
    
    ; S9
    coors=[862, 2187, 1042, 2347]
    coors=double(coors)
    lel1_pts=where(lel1_r GE coors[0] and $
      lel1_r LE coors[2] and $
      lel1_i GE coors[1] and $
      lel1_i LE coors[3])
    lel10_pts=where(lel10_r GE coors[0] and $
      lel10_r LE coors[2] and $
      lel10_i GE coors[1] and $
      lel10_i LE coors[3])
    nptlel1=N_ELEMENTS(lel1_pts)
    nptlel10=N_ELEMENTS(lel10_pts)
    Print, 'Points numbers of lel1 and lel10 in AOI S9:',nptlel1, nptlel10
    
    
    lel1x=lel1_r[lel1_pts]
    lel1y=lel1_i[lel1_pts]
    lel10x=lel10_r[lel10_pts]
    lel10y=lel10_i[lel10_pts]
    xrange=[coors[0], coors[2]]
    yrange=[coors[1], coors[3]]
    ;  window,/free, xsize=650, ysize=800
    ;  oPlot, lel1x, lel1y, xrange=[0, 2385], yrange=[0,2937], psym=1, symsiz=1
    oPlot, lel10x,2937- lel10y,psym=1, symsize=1
    
  ENDIF
  
  
  
  ;*******************************correct the stamps result********************************************
  workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/HPA/figures/'
  vstampsfile_orig=workpath+'ps_mean_v.xy_gmt.txt'
  vstampsfile=workpath+'ps_mean_v_stamps.txt'
  vmtifile=workpath+'lel10vdh_merge.tmp.txt'
  vdhfile_mti=workpath+'lel10vdh_merge'
  vdhfile_stamps=workpath+'vdh_stamps'
  
  pliststampsfile=workpath+'plist_stamps'
  plistmtifile=workpath+'plist_mti'
  plistlookupfile=workpath+'plistlookup'
  IF 0 THEN BEGIN
    v_stamps_orig=TLI_READTXT(vstampsfile_orig,/easy)
    v_stamps=v_stamps_orig[2, *]
    
    vdh_mti=TLI_READMYFILES(vdhfile_mti, type='vdh')
    v_mti_orig=vdh_mti[1:3, *]
    v_mti=v_mti_orig[2,*]
    ; Convert to vertical deformation rate
    v_mti=v_mti/COS(degree2radius(41.08))
    ; Make the deformation value all minus.
    maxv=MAX(v_mti, min=minv)
    v_mti=v_mti-maxv
    
    
    mode_stamps=MODE(v_stamps,nbins=30)
    mode_mti=MODE(v_mti, nbins=30)
    
    mean_stamps=MEAN(v_stamps)
    mean_mti=MEAN(v_mti)
    ; I should add some values to stamps result.
    dif=mode_mti-mode_stamps
    v_stamps=v_stamps+dif[0]
    minv=MIN(v_stamps, max=maxv)
    Print, 'Range of StaMPS deformation rates:', [minv, maxv]
    
    ; Ready to plot
    ; Create a psuedo vdhfile for StaMPS.
    npt=N_ELEMENTS(v_stamps)
    vdh_stamps=[DINDGEN(1, npt), v_stamps_orig[0:1, *], v_stamps, DBLARR(1, npt)]
    TLI_WRITE, vdhfile_stamps, vdh_stamps
    
    ; Plot the stamps result
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/HPA/'
    vdhfile=vdhfile_stamps
    rasfile=workpath+'ave.ras'
    sarlistfile=workpath+'sarlist'
    outputfile=workpath+'vdh_stamps.tif'
    ptsize=0.005
    noframe=0
    maxv=0
    minv=-71.25
    fliph_pt=0
    flipv_pt=1
    fliph_image=1
    los_to_v=0  ; This is a converted deformation rate map. Do not convert twice.
    minus=0
    cpt='tli_def'
    colorbar_interv=7
    dpi=800
    no_clean=1
    show=1
    TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
      colorbar_interv=colorbar_interv,compress=compress,cpt=cpt,delta=delta,dpi=dpi,$
      fliph_pt=fliph_pt,flipv_pt=flipv_pt, fliph_image=fliph_image, flipv_image=flipv_image,$
      geocode=geocode, geodims=geodims,intercept=intercept,los_to_v=los_to_v,maxv=maxv, minv=minv,minus=minus,$
      no_colorbar=no_colorbar,noframe=noframe,no_clean=no_clean, outputfile=outputfile,$
      overwrite=overwrite,percent=percent,ptsize=ptsize,refine=refine,show=show,$
      tick_major=tick_major, tick_minor=tick_minor,unit=unit,xsize=xsize, ysize=ysize
      
  ENDIF
  ;***********************************
  
  
  IF 0 THEN BEGIN
    IF 1 THEN BEGIN
    
      ;************************************************************************
      ; The plistmtifile should be cleaned up first.
      vdh=TLI_READMYFILES(vdhfile_mti, type='vdh')
      
      ; Convert to vertical deformation rate
      v_mti=vdh[3, *]
      v_mti=v_mti/COS(degree2radians(41.08))
      
      ; Make the deformation value all minus.
      maxv=MAX(v_mti, min=minv)
      v_mti=v_mti-maxv
      
      ; Write the files
      vmti=[5000-vdh[1, *], 6150-vdh[2, *], v_mti]
      plistmti=COMPLEX(vmti[0, *], vmti[1, *])
      Print, 'Original Points:', N_ELEMENTS(plistmti)
      ind=LINDGEN(1, N_ELEMENTS(plistmti))
      
      temp=SORT(plistmti)
      plistmti=plistmti[*, temp]
      ind=ind[*, temp]
      
      temp=UNIQ(plistmti)
      plistmti=plistmti[*, temp]
      ind=ind[*, temp]
      
      vmti=vmti[*, ind]
      Print, 'Updated Points:', N_ELEMENTS(plistmti)
      
      vmtifile=workpath+'mti_uniq.txt'
      
      TLI_WRITE, vmtifile, vmti,/txt
      
      ;*********************************** ; Files extracted from the StaMPS result.**************
      IF 0 THEN BEGIN
      
        plist=TLI_READTXT(plistfile, /easy)
        v=TLI_READTXT(vfile,/easy)
        v=v[2,*]
        v=v/COS(degree2radius(41.079))
        v=v-max(v)
        maxv=MAX(v, min=minv)
        Print, 'range of deformation velocity:',maxv, minv
        
        x=5000-plist[1, *]
        y=6150-plist[0, *]
        
        maxx=MAX(x, min=minx)
        maxy=MAX(y,min=miny)
        Print, 'x range:', [minx, maxx]
        Print, 'y range:', [miny, maxy]
        
        vgmt=[x,y, v]
        
        TLI_WRITE, vgmtfile, vgmt,/txt
      ENDIF
      
      
      
      ; The StaMPS files are corrected and saved in vdhfile_stamps
      vdh_stamps=TLI_READMYFILES(vdhfile_stamps, type='vdh')
      
      coors_stamps=COMPLEX(vdh_stamps[1,*], vdh_stamps[2,*])
      
      v_stamps=vdh_stamps[1:3, *]
      
      maxv=MAX(v_stamps[2, *], min=minv)
      Print, 'Range of v:', [minv, maxv]
      TLI_WRITE, vstampsfile, v_stamps,/txt
      
    ENDIF
    
    
    ;***********************************Compare points******************************
    ; Find the points that are:
    ;   Exclusively owned by StaMPS
    ;   Exclusively owned by MTI
    ;   Shared by two method.
    ;
    v_stamps=TLI_READTXT(vstampsfile,/easy)
    v_mti=TLI_READTXT(vmtifile,/easy)
    
    plist_stamps=COMPLEX(v_stamps[0, *], v_stamps[1, *])
    plist_mti=COMPLEX(v_mti[0, *], v_mti[1, *])
    
    TLI_WRITE, pliststampsfile, plist_stamps
    TLI_WRITE, plistmtifile, plist_mti
    TLI_COMPARE_PLIST, pliststampsfile, plistmtifile,/txt,/gamma, samples=5000, lines=6150,/outputlookup
    
    ;***********************************Extract the identical deformation rates.********************
    ; I have to compare the two result files.
    lookup=TLI_READDATA(pliststampsfile+'.lookup', samples=2, format='double')
    ind=WHERE(lookup[1, *] NE -1)
    useful_lookup=lookup[*, ind]
    Print, 'Number of identical points:', N_ELEMENTS(ind)
    ; information of stamps
    info_stamps=v_stamps[*, ind]
    ; Information of MTI
    info_mti=v_mti[*, useful_lookup[1, *]]
    ; Write the information
    TLI_WRITE, workpath+'common_info', [info_stamps, info_mti]
    TLI_WRITE, workpath+'common_info.txt', [info_stamps, info_mti],/txt
    
    ;-------------------------------Extract exclusive informaiton ------------------------------------
    lookup_stamps=TLI_READDATA(pliststampsfile+'.lookup', samples=2, format='double')
    commonind=WHERE(lookup_stamps[1, *] NE -1, complement=stamps_exc_ind)
    lookup_mti=TLI_READDATA(plistmtifile+'.lookup', samples=2, format='double')
    commonind=WHERE(lookup_mti[1, *] NE -1, complement=mti_exc_ind)
    
    ; Get the information
    stamps_exc_info=v_stamps[*, stamps_exc_ind]
    mti_exc_info=v_mti[*, mti_exc_ind]
    
    ; Write the information
    TLI_WRITE, workpath+'stamps_exc_info', stamps_exc_info
    TLI_WRITE, workpath+'stamps_exc_info.txt', stamps_exc_info,/txt
    
    TLI_WRITE, workpath+'mti_exc_info', mti_exc_info
    TLI_WRITE, workpath+'mti_exc_info.txt', mti_exc_info,/txt
    
    
    ;***********************************Compare the information**************************************
    commoninfo=TLI_READDATA(workpath+'common_info', samples=6, format='double')
    stamps=commoninfo[2, *]
    mti=commoninfo[5, *]
    
    
    mode_stamps=MODE(stamps)
    mode_mti=MODE(mti)
    mode_dif=mode_mti-mode_stamps
    
    stamps=stamps+mode_dif[0]
    
    
    dif=(mti-stamps)
    mindif=MIN(dif, max=maxdif)
    Print, 'Range of difference:', [mindif, maxdif]
    Print, 'Mean difference:', MEAN(dif)
    TLI_WRITE, workpath+'mti_vs_stamps.txt', [stamps, mti],/txt
    TLI_WRITE, workpath+'mti_vs_stamps_all.txt', [stamps, mti, ABS(dif)],/txt
    
    ;  Plot, stamps, mti, psym=1, xrange=[-70,0],yrange=[-70,0]
    
    ; Compute the regression params, and print the results:
    result = REGRESS(TRANSPOSE(mti), TRANSPOSE(stamps), SIGMA=sigma, CONST=const, $
      MEASURE_ERRORS=measure_errors, FTEST=ftest, Correlation=corr, YFIT=yfit)
    ;  result = REGRESS(TRANSPOSE(stamps), TRANSPOSE(mti), SIGMA=sigma, CONST=const, $
    ;    MEASURE_ERRORS=measure_errors, FTEST=ftest, Correlation=corr, YFIT=yfit)
    PRINT, 'Constant: ', const
    PRINT, 'Coefficients: ', result[*]
    PRINT, 'Standard errors: ', sigma
    PRINT, 'Ftest:', ftest
    Print, 'Correlation:', corr
    
  ENDIF
  
  ; Extract the information within the given range
  ; the range is given in the convert command
  ; convert plist_mti_exc.ras -crop 1000x360+3654+1681 pts_mti_aoi.jpg
  range=[3654, 1681, 4653, 2040]  ; Range in the un_flipped raster images.
  workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/HPA/figures/'
  stamps_excfile=workpath+'stamps_exc_info'
  mti_excfile=workpath+'mti_exc_info'
  commonfile=workpath+'common_info'
  samples=5000
  lines=6150
;  range=[samples-1-range[2], range[1], samples-1-range[0], range[3]] ; Range in the flipped raster images.
  
  stamps_exc=TLI_READDATA(stamps_excfile, samples=3, format='double') ; Coordinates in the flipped raster images.
  mti_exc=TLI_READDATA(mti_excfile, samples=3, format='double')
  commoninfo=TLI_READDATA(commonfile, samples=6, format='double')
  
  
  stamps_exc_aoi=TLI_INFO_WITHIN_RANGE(stamps_exc, range,samples=samples, lines=lines)
  mti_exc_aoi=TLI_INFO_WITHIN_RANGE(mti_exc, range,samples=samples, lines=lines)
  void=TLI_INFO_WITHIN_RANGE(commoninfo, range,samples=samples, lines=lines,ind=ind)
  commoninfo_aoi=commoninfo[*, ind]
  
  TLI_WRITE, stamps_excfile+'_aoi.txt',stamps_exc_aoi,/txt
  TLI_WRITE, mti_excfile+'_aoi.txt', mti_exc_aoi,/txt
  TLI_WRITE, commonfile+'_aoi.txt', commoninfo_aoi,/txt
  
  TLI_WRITE, stamps_excfile+'_common_aoi.txt', [[stamps_exc_aoi], [commoninfo_aoi[0:2, *]]],/txt
  TLI_WRITE, mti_excfile+'_common_aoi.txt', [[mti_exc_aoi], [commoninfo_aoi[3:*, *]]],/txt
  
  
  ;***********************************Compare the information**************************************
    commoninfo=TLI_READTXT(workpath+'common_info_aoi.txt', /easy)
    stamps=commoninfo[2, *]
    mti=commoninfo[5, *]
    
    
    mode_stamps=MODE(stamps)
    mode_mti=MODE(mti)
    mode_dif=mode_mti-mode_stamps
    
    stamps=stamps+mode_dif[0]
    
    
    dif=(mti-stamps)
    mindif=MIN(dif, max=maxdif)
    Print, 'Range of difference:', [mindif, maxdif]
    Print, 'Mean difference:', MEAN(dif)
    TLI_WRITE, workpath+'mti_vs_stamps.txt', [stamps, mti],/txt
    TLI_WRITE, workpath+'mti_vs_stamps_all.txt', [stamps, mti, ABS(dif)],/txt
    
    ;  Plot, stamps, mti, psym=1, xrange=[-70,0],yrange=[-70,0]
    
    ; Compute the regression params, and print the results:
    result = REGRESS(TRANSPOSE(mti), TRANSPOSE(stamps), SIGMA=sigma, CONST=const, $
      MEASURE_ERRORS=measure_errors, FTEST=ftest, Correlation=corr, YFIT=yfit)
    ;  result = REGRESS(TRANSPOSE(stamps), TRANSPOSE(mti), SIGMA=sigma, CONST=const, $
    ;    MEASURE_ERRORS=measure_errors, FTEST=ftest, Correlation=corr, YFIT=yfit)
    PRINT, 'Constant: ', const
    PRINT, 'Coefficients: ', result[*]
    PRINT, 'Standard errors: ', sigma
    PRINT, 'Ftest:', ftest
    Print, 'Correlation:', corr
  
  STOP
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  ;***************************************some finished experiments****************
  IF 0 THEN BEGIN
    ;************************I have to make sure that the images are identical****************************
    IF 0 THEN BEGIN
      gammaslcfile='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/piece/20091113.rslc'
      stampsslcfile='/mnt/data_tli/ForExperiment/TSX_StaMPS_Tianjin/INSAR_20091113/20091113_crop.slc'
      
      gammaslc=TLI_READDATA(gammaslcfile, samples=5000, format='scomplex',/swap_endian)
      stampsslc=TLI_READDATA(stampsslcfile, samples=5000, format='scomplex')
      
      Print, TOTAL(gammaslc-stampsslc)
      Print, 'They are totally the same.'
    ENDIF
    
  ENDIF
  
  
  
  
  
  Print, 'Main pro finished!', TLI_TIME(/str)
END