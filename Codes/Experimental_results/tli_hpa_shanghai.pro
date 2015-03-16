@tli_psselect_single
PRO TLI_HPA_SHANGHAI
  ; HPA for Shanghai

  ;  COMPILE_OPT idl2
  ;  workpath_orig='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Airport'
  ;  workpath_orig='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'

  workpath_orig='/mnt/data_tli/ForExperiment/TSX_PS_SH_ADI_1.1'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  itabfile=hpapath+'itab'
  sarlistfile=hpapath+'sarlist'
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
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
  ;  TLI_REFRESH_MSK, hpapath, level=3
  ;  tli_plot_linear_def,hpapath+'lel8vdh_merge', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.001,/no_clean,cpt='surfer',$
  ;    maxv=0, minv=-27,/minus,/los_to_v,/fliph_image, /fliph_pt,/noframe
  
  
  IF 1 THEN BEGIN
    mskfile=hpapath+'msk'
    IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
    ; Run tli_hpa_1level.pro
    mask_arc=0.75
    mask_pt_coh=0.75
    v_acc=3
    dh_acc=10
;    TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
;       /ls, method='ls', coh=0.9
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.001,$
    /no_clean,cpt='tli_def', /fliph_pt,/refine,/minus,/los_to_v,/noframe
    STOP
    mskfile=hpapath+'msk'
    IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
    coef=[0.4,0.5]
    ; Run tli_hpa_2level.pro
    TLI_HPA_2LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel2vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.001,cpt='surfer'
    
    
    
    coef=[0.5,0.6]
    ; Run tli_hpa_3level.pro
    TLI_HPA_3LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel3vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005,cpt='surfer'
    
    
    i_orig=2
    
    i_start=3
    iter=6
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
    
    
  ENDIF
  ;  coef=[0.6,1]
  ;  FOR i=7, 13 DO BEGIN
  ;    TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
  ;      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
  ;      tile_samples=tile_samples, tile_lines=tile_lines
  ;  ENDFOR
  
  IF 0 THEN BEGIN
    level=8
    type='ptattr'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='plist'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    type='vdh'
    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ENDIF
  
  
  ;  vdhfile=hpapath+'lel8vdh_merge'
  ;  vdh=tli_readmyfiles(vdhfile,type='vdh')
  ;  v=vdh[3, *]
  ;  minv=MIN(v, max=maxv)
  ;  print, minv, maxv
  ;  ; Chagen to the LOS direction.
  ;  v=v/COS(degree2radius(finfo.incidence_angle))
  ;  minv=MIN(v, max=maxv)
  ;  print, minv, maxv
  
  ptsize_orig=0.001
  TLI_PLOT_HPA, hpapath, level=8, ptsize=ptsize_orig, cpt='surfer',/los_to_v,/minus,/fliph_pt,/fliph_image,/noframe,/no_colorbar, maxv=0, minv=-27
  
END