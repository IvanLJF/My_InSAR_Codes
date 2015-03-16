@tli_plot_linear_def
@tli_plot_hpa
@tli_hpa_1level
@tli_hpa_2level
@tli_hpa_3level
@tli_hpa_loop
@tli_merge_results
PRO TLI_HPA_TIANJIN_REFCR05
  ;  COMPILE_OPT idl2


  workpath_orig='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_RefCR05'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  coef=0.5
  force=1
  mask_pt_corr=0.7
  mask_arc= 0.8
  mask_pt_coh= 0.7
  tile_samples=50
  tile_lines=50
  search_radius=25 ; Search radius to locate the adj. points.
  v_acc=5
  dh_acc=10
  
  IF 1 THEN BEGIN
    ;    TLI_REFRESH_MSK, hpapath, level=7
    ; Run tli_hpa_1level.pro
    mask_arc=0.8
    mask_pt_coh=0.8
    v_acc=10
    dh_acc=10
    coor=COMPLEX(1282, 3079)
    plistfile=hpapath+'plist'
    plist=TLI_READMYFILES(plistfile, type='plist')
    refcoor=TLI_PROX_PT_SINGLE(coor, plist,ind=refind)
;    TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc, refind=refind
    
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
      tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.001,/los_to_v,cpt='surfer'
  ENDIF
  IF 0 THEN BEGIN
    coef=0.5
    ; Run tli_hpa_2level.pro
    TLI_HPA_2LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel2vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.001
    
    coef=0.6
    ; Run tli_hpa_3level.pro
    TLI_HPA_3LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel3vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005
    
    
    i_orig=4
    
    i_start=8
    iter=10
    FOR i=i_start, i_start+iter DO BEGIN
      coef_start=coef+(i-i_start)*0.1
      coef_end=coef+(i-i_start+1)*0.1
      coef=[coef_start,coef_end]
      ; Run tli_hpa_loop.pro
      TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
        mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
        tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
        v_acc=v_acc, dh_acc=dh_acc
      hpafiles=TLI_HPA_FILES(hpapath,level=i)
      tli_plot_linear_def,hpafiles.vdh, hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005
      
    ENDFOR
    
    
    
    ;  coef=[0.6,1]
    ;  FOR i=7, 13 DO BEGIN
    ;    TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
    ;      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
    ;      tile_samples=tile_samples, tile_lines=tile_lines
    ;  ENDFOR
    
    IF 1 THEN BEGIN
    
      type='ptattr'
      TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
      type='plist'
      TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
      type='vdh'
      TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
    ENDIF
    
    ptsize_orig=0.005
    TLI_PLOT_HPA, hpapath, ptsize=ptsize_orig, cpt='surfer',/los_to_v,/compress,percent=0.5
  ENDIF
  
  
END