;-
;- Purpose:
;-     Calculate 1st LEVEL network.
;-
PRO TLI_HPA_1LEVEL_DAM

  c= 299792458D ; Speed light
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_DAM'
  resultpath=workpath+'/HPA'
  ; Input files
  sarlistfilegamma= workpath+'/SLC_tab'
  pdifffile= workpath+'/pdiff0'
  plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= workpath+'/HPA/plist'
  itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=workpath+'/HPA/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=workpath+'/HPA/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  plafile=workpath+'/HPA/pla'
  dvddhfile=workpath+'/HPA/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= workpath+'/HPA/vdh'
  ptattrfile= workpath+'/HPA/ptattr'
  plistfile= resultpath+PATH_SEP()+'plist'                     
  sarlistfile= resultpath+PATH_SEP()+'sarlist_Linux'                       
  arcsfile= resultpath+PATH_SEP()+'arcs'                        
  pslcfile= resultpath+PATH_SEP()+'pslc'                         
  interflistfile= resultpath+PATH_SEP()+'Interf.list'      
  pbasefile=resultpath+PATH_SEP()+'pbase'                 
  dvddhfile=resultpath+PATH_SEP()+'dvddh'                         
  vdhfile= resultpath+PATH_SEP()+'vdh'                             
  ptattrfile= resultpath+PATH_SEP()+'ptattr'                      
  plafile= resultpath+PATH_SEP()+'pla'                          
  arcs_resfile= resultpath+PATH_SEP()+'arcs_res'                 
  res_phasefile= resultpath+PATH_SEP()+'res_phase'                   
  time_series_linearfile= resultpath+PATH_SEP()+'time_series_linear' 
  res_phase_slfile= resultpath+PATH_SEP()+'res_phase_sl'            
  res_phase_tlfile= resultpath+PATH_SEP()+'res_phase_tl'           
  final_resultfile= resultpath+PATH_SEP()+'final_result'       
  nonlinearfile= resultpath+PATH_SEP()+'nonlinear'               
  atmfile= resultpath+PATH_SEP()+'atm'                    
  time_seriestxtfile= resultpath+PATH_SEP()+'Deformation_Time_Series_Per_SLC_Acquisition_Date.txt'
  dhtxtfile= resultpath+PATH_SEP()+'HeightError.txt'             
  vtxtfile= resultpath+PATH_SEP()+'Deformation_Average_Annual_Rate.txt' 
  logfile= resultpath+PATH_SEP()+'log.txt'     ; Log file.
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
      rps=finfo.range_pixel_spacing
      aps=finfo.azimuth_pixel_spacing
      disthresh=500
      optimize=1
      corrthresh=0.8
      ; Networking.
      ; Free network.
      TLI_HPA_FREENETWORK, plistfilegamma,pdifffile, rps, aps, $
        disthresh=disthresh,corrthresh=corrthresh,arcsfile=arcsfile, optimize=optimize, txt=txt
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
      dist_thresh=500
      ;   Delaunay network.
      result=TLI_DELAUNAY(plistfile,outname=arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
      PrintF, loglun, 'dist_thresh:'+STRCOMPRESS(dist_thresh)
      narcs= TLI_ARCNUMBER(arcsfile)
      PrintF,loglun,  'Delaunay triangulation generates'+STRCOMPRESS(narcs)+' arcs.'
    ENDELSE
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
    
    ; Params
;      refind=2123
;      refind=1625; Reference point's index for TSX_PS_Tianjin
    ;    refind=35702; Reference point's index for TSX_PS_Tianjin
;        refind=127700; Reference point's index for TSX_PS_Tianjin
    

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
    mask_arc= 0.9
    mask_pt_coh= 0.9
    v_acc= 100 ; Accuracy threshold of deformation velocity: mm/yr
    dh_acc= 100 ; Accuracy threshold of hight error: m
    
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
  FREE_LUN, lun
  
  CD, resultpath
  SPAWN, './plot_linear_def_XiQing.sh'
  
END