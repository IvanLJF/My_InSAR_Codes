<<<<<<< HEAD
<<<<<<< HEAD
@tli_psselect_single
PRO TLI_HPA_SHENZHEN
  ; HPA set for Shanghai

  ;  COMPILE_OPT idl2
  ;  workpath_orig='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Airport'
  ;  workpath_orig='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'

  workpath_orig='/mnt/software/myfiles/Software/experiment/ENV_PS_Shenzhen'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  ;  tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.005,/no_clean,cpt='surfer'
  
  coef=0.5
  force=1
  mask_pt_corr=0.7
  mask_arc= 0.7
  mask_pt_coh= 0.7
  tile_samples=50
  tile_lines=50
  search_radius=25 ; Search radius to locate the adj. points.
  v_acc=5
  dh_acc=10
  ;    TLI_REFRESH_MSK, hpapath, level=9
  IF 1 THEN BEGIN
    mskfile=hpapath+'msk'
    IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
    ; Run tli_hpa_1level.pro
    mask_arc=0.75
    mask_pt_coh=0.75
    v_acc=3
    dh_acc=10
;    TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls
;    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.005,/no_clean,cpt='rainbow',/fliph_image,/fliph_pt
    
    mskfile=hpapath+'msk'
    IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
    coef=[0.4,0.5]
    ; Run tli_hpa_2level.pro
    TLI_HPA_2LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel2vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.001,cpt='surfer',/show
    
    
    
    coef=[0.5,0.6]
    ; Run tli_hpa_3level.pro
    TLI_HPA_3LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel3vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005,cpt='surfer'
  ENDIF
  
  i_orig=2
  
  i_start=9
  iter=4
  FOR i=i_start, i_start+iter DO BEGIN
  
    coef_start=coef+(i-i_orig)*0.1
    coef_end=coef+(i-i_orig+1)*0.1
    coef=[coef_start,coef_end]
    
    ; Run tli_hpa_loop.pro
    TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    hpafiles=TLI_HPA_FILES(hpapath,level=i)
    tli_plot_linear_def,hpafiles.vdh, hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005,cpt='surfer'
    
  ENDFOR
  
  ;  coef=[0.6,1]
  ;  FOR i=7, 13 DO BEGIN
  ;    TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
  ;      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
  ;      tile_samples=tile_samples, tile_lines=tile_lines
  ;  ENDFOR
  
  IF 1 THEN BEGIN
    level=i_start+iter-1
    type='ptattr'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='plist'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='vdh'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ENDIF
  
  ptsize_orig=0.001
  TLI_PLOT_HPA, hpapath, level=[i_start-1, i_start+iter-1], ptsize=ptsize_orig
  
=======
=======
@tli_minmax
>>>>>>> febac1474f69361a8edcd7fe86bc33da0956213f
@tli_psselect_single
PRO TLI_HPA_SHENZHEN

  workpath_orig='/mnt/software/myfiles/Software/experiment/ENV_PS_Shenzhen'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  sarlistfile=hpapath+'sarlist'
  itabfile=workpath_orig+PATH_SEP()+'itab'
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
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
  IF 0 THEN BEGIN
    TLI_REFRESH_MSK, hpapath, level=2
    IF 0 THEN BEGIN
      mskfile=hpapath+'msk'
      IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
      ; Run tli_hpa_1level.pro
      mask_arc=0.75
      mask_pt_coh=0.75
      v_acc=3
      dh_acc=10
      ;      TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls
      ;      outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
      ;      tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',ptsize=0.005,/no_clean,cpt='rainbow',/fliph_image,/fliph_pt
      
      mskfile=hpapath+'msk'
      IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
      coef=[0.4,0.45]
      ; Run tli_hpa_2level.pro
      ;      TLI_HPA_2LEVEL,workpath_orig,coef=coef,$
      ;        mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      ;        tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      ;        v_acc=v_acc, dh_acc=dh_acc
      ;      tli_plot_linear_def,hpapath+'lel2vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.001,cpt='surfer',/show
      
      
      
      coef=[0.45,0.5]
      ; Run tli_hpa_3level.pro
      TLI_HPA_3LEVEL,workpath_orig,coef=coef,$
        mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
        tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
        v_acc=v_acc, dh_acc=dh_acc
      tli_plot_linear_def,hpapath+'lel3vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005,cpt='surfer'
      
      adi_start=0.5
      adi_stepwise=0.02
      i_adi_start=4
      i_start=4
      iter=10
      TLI_REFRESH_MSK, hpapath, level=4
      
      FOR i=i_start, i_start+iter DO BEGIN
      
        coef_start=adi_start+(i-i_adi_start)*adi_stepwise
        coef_end=coef_start+adi_stepwise
        coef=[coef_start,coef_end]
        
        ; Run tli_hpa_loop.pro
        TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
          mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
          tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
          v_acc=v_acc, dh_acc=dh_acc
        hpafiles=TLI_HPA_FILES(hpapath,level=i)
        tli_plot_linear_def,hpafiles.vdh, hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005,cpt='surfer'
        
      ENDFOR
      
    ENDIF
  ENDIF
  
  
  IF 0 THEN BEGIN
    ;    level=i_start+iter-1
    level=14
    type='ptattr'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='plist'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='vdh'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ENDIF
  IF 0 THEN BEGIN
    plistfile=hpapath+'lel14plist_update_merge'
    vdhfile=hpapath+'lel14vdh_merge'
    result=TLI_MINMAX(vdhfile, sarlistfile=sarlistfile,/minus,/LOS_TO_V, type='vdh')
    
    
    ptsize_orig=0.001
    TLI_PLOT_HPA, hpapath, level=14, ptsize=ptsize_orig, /flipv_image, /flipv_pt,cpt='rainbow', minv=result[0], maxv=result[1],/minus,/los_to_v
    
    ;  STOP
    ; Geocoding just for the merged result of level 14.
    plistfile_final=hpapath+'lel14plist_update_merge'
    outputfile=hpapath+'lel14plist_merge_GAMMA'
    TLI_GAMMA2MYFORMAT_PLIST, plistfile_final, outputfile,/REVERSE
    
    ; Convert the result from rdc to google earth
    workpath='/mnt/software/myfiles/Software/experiment/ENV_PS_Shenzhen/geocode'
    workpath=workpath+PATH_SEP()
    
    hpapath='/mnt/software/myfiles/Software/experiment/ENV_PS_Shenzhen/HPA'+PATH_SEP()
    sarlistfile=hpapath+'sarlist'
    vdhfile=hpapath+'lel14vdh_merge'
    pmapllfile=workpath+'lel14plist_merge_GAMMA.ll'
    
    vacuate=1
    npt_final=20000
    refine_data=1
    minus=1
    sarlistfile=sarlistfile
    los_to_v=1
    TLI_DEFINGOOGLE,pmapllfile, vdhfile, cptfile=cptfile, colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
      maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
      refine_data=refine_data,delta=delta,refined_data=refined_data, minus=minus,sarlistfile=sarlistfile,$
      los_to_v=los_to_v
  ENDIF
  
  ; Plot the geocoded result
  
  geopath='/mnt/software/myfiles/Software/experiment/ENV_PS_Shenzhen/geocode'
  geopath=geopath+PATH_SEP()
  vdhfile=geopath+'lel14vdh_merge'
  llfile=geopath+'lel14plist_merge_GAMMA.ll'
  vdhfile_ll=vdhfile+'_ll'
  sarlistfile=geopath+'sarlist'
  
  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  ll=TLI_READDATA(llfile, samples=2, format='float',/swap_endian)
  v=vdh[3,*]
  minv=MIN(v, max=maxv)
  v=v-maxv
  v=v/COS(DEGREE2RADIUS(finfo.incidence_angle))
  result=[ll, v]
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  
  TLI_WRITE, vdhfile_ll, result,/txt
  
  ; Count the min-max of the longitude and latitude
  deminfo=TLI_LOAD_PAR(geopath+'dem_seg.par')
  samples=DOUBLE(deminfo.width)
  lines=DOUBLE(deminfo.nlines)
  corner_lat=23.00
  corner_lon=113.68
  post_lat=-4.1666665e-05
  post_lon=4.1666665e-05
  Print, 'Range of lon.: [',corner_lon, corner_lon+samples*post_lon,samples*post_lon, ' ]'
  Print, 'Range of lat: [', corner_lat+lines*post_lat,corner_lat, lines*post_lat, ' ]'
  
  
<<<<<<< HEAD
>>>>>>> 6f170446021e02c141b707fbe30c46582505c0fb
=======
  STOP
>>>>>>> febac1474f69361a8edcd7fe86bc33da0956213f
END