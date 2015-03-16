PRO TLI_PSEUDO_PTATTRFILE, vdhfile, v_accfile=v_accfile, dh_accfile=dh_accfile, ptattrfile=ptattrfile
  ; Create the pusedo ptattr file for the input vdh file.
  ; v_accfile  : error vector of v.
  ; dh_accfile : error vector of dh.

  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  sz=SIZE(vdh,/DIMENSIONS)
  npt=sz[1]
  IF NOT KEYWORD_SET(v_accfile) THEN v_acc=DBLARR(1, npt)
  IF NOT KEYWORD_SET(dh_accfile) THEN dh_acc=DBLARR(1, npt)
  IF NOT KEYWORD_SET(ptattrfile) THEN BEGIN
    workpath=FILE_DIRNAME(vdhfile)
    ptattrfile=workpath+'ptattr'
  ENDIF
  
  ptattr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  ptattr= REPLICATE(ptattr, npt); point attribute
  ptattr.parent=0L
  ptattr.steps=0L
  ptattr.v=(vdh[3,*])[*]
  ptattr.dh=(vdh[4,*])[*]
  ptattr.weight=1D
  ptattr.calculated=1B
  ptattr.accepted=1B
  ptattr.v_acc=(v_acc)[*]
  ptattr.dh_acc=(dh_acc)[*]
  
  TLI_WRITE, ptattrfile, ptattr
END



PRO TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
    refind=refind,free_network=free_network, rg=rg, ls=ls, weighted=weighted, method=method, coh=coh,sigma=sigma, $
    pbase_thresh=pbase_thresh, ignore_def=ignore_def
  ; Calculate the deformation parameters for the first level of the points.
  ; method   : The method to calculate relative deformation parameters.
  ;            'psd'  : Peridogram
  ;            'ls'   : Least-squared estimation
  ; rg       : The method to calculate absolute deformation parameters: region growing.
  ; ls       : The method to calculate absolute deformation parameters: least-squared estimation.
  ; weighted : Weighted LS estimation. This will corrupt the sparse matrix in Matlab. Not suggested.
  ; coh      : Coherence used to mask the arcs.
  ; sigma    : Phase sigma used to mask the arcs.
  
  c= 299792458D ; Speed light
  IF ~KEYWORD_SET(mask_arc) THEN mask_arc= 0.5
  IF ~KEYWORD_SET(mask_pt_coh) THEN mask_pt_coh= 0.5
  IF ~KEYWORD_SET(v_acc) THEN v_acc= 5; Accuracy threshold of deformation velocity: mm/yr
  IF ~KEYWORD_SET(dh_acc) THEN dh_acc= 10 ; Accuracy threshold of hight error: m
  IF (KEYWORD_SET(rg) + KEYWORD_SET(ls)) EQ 0 THEN rg=1  ; Ommitted method: least squares.
  IF NOT KEYWORD_SET(weighted) THEN weighted = 0
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
  resultpath=workpath+'HPA'+PATH_SEP()
  basepath= workpath+'HPA/base'
  ; Input files
  sarlistfilegamma= workpath+'SLC_tab'
  pdifffile= workpath+'pdiff0'
  plistfilegamma= workpath+'pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= workpath+'HPA/plist'
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=workpath+'HPA/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=workpath+'HPA/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  plafile=workpath+'HPA/pla'
  dvddhfile=workpath+'HPA/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= workpath+'HPA/vdh'
  ptattrfile= workpath+'HPA/ptattr'
  plistfile= resultpath+'plist'                            ; PS点列表
  sarlistfile= resultpath+'sarlist_Linux'                  ; 文件列表
  arcsfile= resultpath+'arcs'                              ; 网络弧段列表
  pslcfile= resultpath+'pslc'                              ; 点位上的SLC
  interflistfile= resultpath+'Interf.list'                 ; 干涉列表
  pbasefile=resultpath+'pbase'                             ; 点位基线文件
  dvddhfile=resultpath+'dvddh'                             ; 弧段相对形变速率以及相对高程误差
  vdhfile= resultpath+'vdh'                                ; 点位形变速率以及高程误差
  ptattrfile= resultpath+'ptattr'                          ; 点位信息文件(包含结算过程中所有有用信息)
  plafile= resultpath+'pla'                                ; 点位侧视角文件
  plistfile_update=plistfile+'update'                                 ; PS点列表 - updated
  
  logfile= resultpath+'log.txt'     ; Log file.
  IF ~FILE_TEST(resultpath,/DIRECTORY) THEN FILE_MKDIR, resultpath
  IF ~FILE_TEST(basepath,/DIRECTORY) THEN BEGIN
    FILE_MKDIR, basepath
    CD, basepath
    SPAWN, 'base_all'
  ENDIF
  
  TLI_LOG, logfile, '***************************************************'
  TLI_LOG, logfile,'Workpath:'+workpath
  TLI_LOG, logfile, 'We use gamma pdiff as input.'
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Start at time '+TLI_TIME(/str)
  
  IF 1 THEN BEGIN
    ;将GAMMA的SLC_tab转换为内部各式
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    
    ;;将GAMMA的plist转换为内部格式
    TLI_GAMMA2MYFORMAT_PLIST, plistfilegamma, plistfile
  ENDIF
  
  TLI_GAMMA_BP_LA_FUN, plistfile, itabfile, sarlistfilegamma, basepath, pbasefile, plafile,/force
  
  ; Load master slc header.
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  nintf=itab_stru.nintf_valid
  itab= itab_stru.itab_valid
  
  finfo= TLI_LOAD_MPAR(sarlistfile, itabfile)
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Samples:'+STRCOMPRESS(finfo.range_samples)
  TLI_LOG, logfile, 'Lines:'+STRCOMPRESS(finfo.azimuth_lines)
  TLI_LOG, logfile, 'Range_pixel_spacing:'+STRCOMPRESS(finfo.range_pixel_spacing)
  TLI_LOG, logfile, 'Azimuth_pixel_spacing:'+STRCOMPRESS(finfo.azimuth_pixel_spacing)
  
  IF 1 THEN BEGIN
  
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Params set for networking:'
    
    IF KEYWORD_SET(free_network) THEN BEGIN
      rps=finfo.range_pixel_spacing
      aps=finfo.azimuth_pixel_spacing
      disthresh=1000
      optimize=1
      corrthresh=0.75
      ; Networking.
      ; Free network.
      TLI_HPA_FREENETWORK, plistfilegamma,pdifffile, rps, aps, $
        disthresh=disthresh,corrthresh=corrthresh,arcsfile=arcsfile, optimize=optimize, txt=txt,/swap_endian
      ; Write log file.
      TLI_LOG, logfile, 'disthresh: '+STRCOMPRESS(disthresh)
      TLI_LOG, logfile, 'optimize: '+STRCOMPRESS(optimize)
      TLI_LOG, logfile, 'corrthresh: '+STRCOMPRESS(corrthresh)
      
      ; Check arcs
      npt=TLI_PNUMBER(plistfile)
      TLI_LOG, logfile, 'Free networking generates'+STRCOMPRESS(npt*(npt-1)/2D)+' arcs.'
      narcs= TLI_ARCNUMBER(arcsfile)
      TLI_LOG, logfile,  'Arcs after optimization:'+STRCOMPRESS(narcs)
    ENDIF ELSE BEGIN
      range_pixel_spacing= finfo.range_pixel_spacing
      azimuth_pixel_spacing= finfo.azimuth_pixel_spacing
      dist_thresh=1000
      ;   Delaunay network.
      result=TLI_DELAUNAY(plistfile,outname=arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh, logfile=logfile)
      TLI_LOG, logfile, 'dist_thresh:'+STRCOMPRESS(dist_thresh)
      narcs= TLI_ARCNUMBER(arcsfile)
      TLI_LOG, logfile,  'Delaunay triangulation generates'+STRCOMPRESS(narcs)+' arcs.'
    ENDELSE
    ; Solve dvddh.
    wavelength= c/finfo.radar_frequency
    deltar= finfo.range_pixel_spacing
    R1= finfo.near_range_slc
    
    TLI_LINEAR_SOLVE_GAMMA, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
      wavelength, deltar, R1,method=method,pbase_thresh=pbase_thresh,ignore_def=ignore_def
    TLI_LOG, logfile, 'Networking and linear deformation calculation finished:'+TLI_TIME(/str)
    TLI_LOG, logfile, ''
    TLI_DAT2ASCII, dvddhfile, samples=6, format='DOUBLE', outputfile=dvddhfile+'_'+method
  ENDIF
  
  
  
  
  IF KEYWORD_SET(rg) THEN BEGIN
  
    ; 自动选择影像中心点作为参考点，仅作测试用...
    plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
    IF NOT KEYWORD_SET(refind) THEN BEGIN
      samples= DOUBLE(finfo.range_samples)
      lines= DOUBLE(finfo.azimuth_lines)
      plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
      min_dist= MIN(plist_dist, refind)
    ENDIF
    ;  refind=26873
    TLI_LOG, logfile, 'using region growing method to calculate the deformation rate map.'
    TLI_LOG, logfile,  'Reference point index:'+STRCOMPRESS(refind)+'. Coordinates:'+STRCOMPRESS(plist[refind]),/prt
    
    ref_v=0
    ref_dh=0
    weight=0  ; 0: coh
    ; 1: sigma
    ; 2: both
    ;  mask_arc= 0.9
    ;  mask_pt_coh= 0.75
    ;  v_acc= 5; Accuracy threshold of deformation velocity: mm/yr
    ;  dh_acc= 10 ; Accuracy threshold of hight error: m
    
    ; Solve vdh
    Print, refind
    TLI_RG_DVDDH_CONSTRAINTS, plistfile, dvddhfile, vdhfile, ptattrfile, mask_arc,mask_pt_coh, refind,v_acc, dh_acc
    TLI_LOG, logfile, 'Time is:'+TLI_TIME(/str)
    TLI_LOG, logfile, 'ref_v:'+STRCOMPRESS(ref_v)
    TLI_LOG, logfile, 'ref_dh:'+STRCOMPRESS(ref_dh)
    TLI_LOG, logfile, 'weight:'+STRCOMPRESS(weight)
    TLI_LOG, logfile, 'mask_arc:'+STRCOMPRESS(mask_arc)
    TLI_LOG, logfile, 'mask_pt_coh:'+STRCOMPRESS(mask_pt_coh)
    TLI_LOG, logfile, 'v_acc:'+STRCOMPRESS(v_acc)
    TLI_LOG, logfile, 'dh_acc:'+STRCOMPRESS(dh_acc)
    
  ENDIF
  
  IF KEYWORD_SET(ls) THEN BEGIN
  
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Calculate the deformation params using LS estimation. Start:'+TLI_TIME(/str),/prt
    
    TLI_LS_DVDDH, plistfile, arcsfile, dvddhfile, weighted=weighted, plistfile_update=plistfile_update, $
      vdhfile=vdhfile, logfile=logfile, coh=coh, sigma=sigma
    
    TLI_PSEUDO_PTATTRFILE, vdhfile, v_accfile=v_accfile, dh_accfile=dh_accfile, ptattrfile=ptattrfile
    
    TLI_LOG, logfile, 'Calculate the deformation params using LS estimation. END:'+TLI_TIME(/str)
    
  ENDIF
  
  
  TLI_LOG, logfile, 'hpa level 1 is finished.'
  TLI_LOG, logfile, ''

  v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  x= v[1,*]
  y= v[2,*]
  z= v[3,*]
  maxz=MAX(z, min=minz)
  IF maxz GT 1000 OR minz LT -1000 THEN BEGIN
    Message, 'Error: The range of z is abnormal : [minz, maxz] = ['+STRCOMPRESS(minz)+STRCOMPRESS(maxz)+']'
  ENDIF
  TLI_LOG, logfile,  '[max min] of deformation velocity:'+STRCOMPRESS(MAX(z))+STRCOMPRESS(MIN(z))
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'hpa level1 is finished at time:'+TLI_TIME(/str)
  TLI_LOG, logfile, '*************************************************'
  TLI_LOG, logfile, ''
  Print, 'hpa level1 is finished.'
  
  
  
END