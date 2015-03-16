;
; Do HPA for Beichen, Tianjin, China
;
@tli_plot_linear_def
@tli_plot_hpa
@tli_hpa_1level
@tli_hpa_2level
@tli_hpa_3level
@tli_hpa_loop
@tli_merge_results
PRO TLI_HPA_TIANJIN_BEICHEN

  workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
  workpath_orig=workpath
  hpapath=workpath+'HPA'+PATH_SEP()
  
  plistfile=hpapath+'plist'
  
  sarlistfile=workpath+'SLC_tab'
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  adifile=workpath+'adi'
  
  ;---------------------------------------
  IF 0 THEN BEGIN
    ; Select PTs with ADI < 0.4
    TLI_HPA_DA, sarlistfile, samples=finfo.range_samples, format=finfo.image_format,/swap_endian,outputfile=workpath+'adi'
    plist=TLI_PSSELECT_SINGLE(adifile, coef=0.4, samples=finfo.range_samples, format='float')
    TLI_WRITE, plistfile+'.txt', [Real_Part(plist), finfo.azimuth_lines-IMAGINARY(plist)],/TXT
    TLI_WRITE, plistfile, plist
    TLI_WRITE, plistfile+'_gamma', [LONG(Real_Part(plist)), LONG(IMAGINARY(plist))],/swap_endian
  ENDIF
  ;------------------------------------------
  
  ;-----------------------------------
  ; Prepare the differential phase for PTs.
  ; call the script: PS_Data_Prepare
  ;------------------------------------------
  
  
  ;--------------------------------------------
  ; HPA start
  coef=0.4
  force=1
  mask_pt_corr=0.7
  mask_arc= 0.8
  mask_pt_coh= 0.7
  tile_samples=50
  tile_lines=50
  search_radius=25 ; Search radius to locate the adj. points.
  v_acc=5
  dh_acc=10
  
  
  ;  tli_plot_linear_def,hpapath+'psd_vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  ;*************************************************
  ;******Calculate the deformation rate map*********
  ;*************************************************
  IF 0 THEN BEGIN
    ;    TLI_REFRESH_MSK, hpapath, level=7
    ; Run tli_hpa_1level.pro
    mask_arc=0.8
    mask_pt_coh=0.8
    v_acc=3
    dh_acc=10
    pbase_thresh=100
    coh=0.6
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
      method='ls', coh=coh, pbase_thresh=pbase_thresh
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  ;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.003,/minus
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
    
    i_start=4
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
    
  ENDIF
  ;
  ;  ;  coef=[0.6,1]
  ;  ;  FOR i=7, 13 DO BEGIN
  ;  ;    TLI_HPA_LOOP, workpath_orig, level=i, coef=coef,force=force,$
  ;  ;      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
  ;  ;      tile_samples=tile_samples, tile_lines=tile_lines
  ;  ;  ENDFOR
  ;
  ;  IF 0 THEN BEGIN
  ;
  ;    type='ptattr'
  ;    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ;    type='plist'
  ;    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ;    type='vdh'
  ;    TLI_MERGE_RESULTS_ALL,hpapath, type,level=level,/recursive
  ;  ENDIF
  ;
  IF 0 THEN BEGIN
    ptsize_orig=0.005
    TLI_PLOT_HPA, hpapath, ptsize=ptsize_orig, cpt='tli_def',/compress,percent=0.5,/minus, colorbar_interv=4,/no_colorbar
  ENDIF
  
  ; Plot the result on google earth.
  
  
  
  
END