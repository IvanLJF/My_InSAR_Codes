;-
;- This pro is written just for Chen Fulong in order to analyze
;- the deformation field in Andkor, Cambodia.
;-
;- Written by:
;-   T. LI @ ISEIS, CUHK
;-   At 20130919.
;-
@tli_hpa_shenzhen
PRO TLI_HPA_ANGKOR

  COMPILE_OPT idl2
  
  workpath_orig='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  coef=0.4
  force=1
  mask_pt_corr=0.75
  mask_arc= 0.75
  mask_pt_coh= 0.75
  tile_samples=50
  tile_lines=50
  search_radius=25 ; Search radius to locate the adj. points.
  v_acc=5
  dh_acc=10
  
  mskfile=hpapath+'msk'
  IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
  ; Run tli_hpa_1level.pro
  mask_arc=0.75
  mask_pt_coh=0.75
  v_acc=3
  dh_acc=10
  IF 0 THEN BEGIN
    ;      TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',ptsize=0.005,/no_clean,cpt='rainbow',$
      /show,/minus,/los_to_v,/flipv_image,/flipv_pt
      
      
    ; Geocoding.
    plistfile_final=hpapath+'plistupdate'
    outputfile=hpapath+'plist_GAMMA'
    TLI_GAMMA2MYFORMAT_PLIST, plistfile_final, outputfile,/REVERSE
  ENDIF
  
  IF 0 THEN BEGIN
    ; Convert the result from rdc to google earth
    workpath='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI'
    workpath=workpath+PATH_SEP()
    
    geopath='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/geocode'
    geopath=geopath+PATH_SEP()
    
    hpapath=workpath+'HPA'+PATH_SEP()
    sarlistfile=hpapath+'sarlist'
    vdhfile=hpapath+'vdh'
    pmapllfile=geopath+'plist_GAMMA.ll'
    
    vacuate=1
    npt_final=20000
    refine_data=1
    minus=1
    sarlistfile=sarlistfile
    los_to_v=1
    colortable_name='angkor'
    intercept=14
    
    TLI_DEFINGOOGLE,pmapllfile, vdhfile, cptfile=cptfile, colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
      maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
      refine_data=refine_data,delta=delta,refined_data=refined_data,minus=minus,sarlistfile=sarlistfile,$
      los_to_v=los_to_v,intercept=14
  ENDIF
  
  IF 0 THEN BEGIN
  
    ; Plot the geocoded result
  
    geopath='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/geocode'
    geopath=geopath+PATH_SEP()
    vdhfile=geopath+'vdh'
    llfile=geopath+'plist_GAMMA.ll'
    vdhfile_ll=vdhfile+'_ll'
    sarlistfile=geopath+'sarlist'
    
    finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
    vdh=TLI_READMYFILES(vdhfile, type='vdh')
    ll=TLI_READDATA(llfile, samples=2, format='float',/swap_endian)
    v=vdh[3,*]
    minv=MIN(v, max=maxv)
    v=v-maxv
    v=v/COS(DEGREE2RADIUS(finfo.incidence_angle))+14
    minv=MIN(v, max=maxv)
    Print, 'Range of deformation rates: [', minv, maxv, ']'
    result=[ll, v]
    finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
    TLI_WRITE, vdhfile_ll+'_cfl', result,/txt
    
    ; Count the min-max of the longitude and latitude
    deminfo=TLI_LOAD_PAR(geopath+'dem_seg.par')
    samples=DOUBLE(deminfo.width)
    lines=DOUBLE(deminfo.nlines)
    corner_lat=13.656667
    corner_lon=103.63
    post_lat=-8.3333330e-05
    post_lon=8.3333330e-05
    Print, 'Range of lon.: [',corner_lon, corner_lon+samples*post_lon,samples*post_lon, ' ]'
    Print, 'Range of lat: [', corner_lat+lines*post_lat,corner_lat, lines*post_lat, ' ]'
  ENDIF
  
  IF 1 THEN BEGIN
    ; Output the DEM error for chenfulong
    geopath='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/geocode'
    geopath=geopath+PATH_SEP()
    vdhfile=geopath+'vdh'
    llfile=geopath+'plist_GAMMA.ll'
    vdh=TLI_READMYFILES(vdhfile, type='vdh')
    ll=TLI_READDATA(llfile, samples=2, format='float',/swap_endian)
    dh=vdh[4, *]
    
    mindh=MIN(dh, max=maxdh)
    Print, 'Range of dh: [', mindh, maxdh, ']'
    
    result=[ll, dh]
    
    TLI_WRITE, geopath+'dem_err.txt', result,/txt
  ENDIF
  
END