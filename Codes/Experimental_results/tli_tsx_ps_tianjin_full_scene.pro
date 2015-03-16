;
; Investigate the deformation rate map in Tianjin using the full scene of TSX images.
; Test the PSD, LS estimation, and STUN method.
; Prepared for 测绘学报。
; Written by:
;   T.LI @ SWJTU, 20140220
;
@tli_hpa_tianjin
PRO TLI_TSX_PS_TIANJIN_FULL_SCENE

  workpath_orig='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_FullScene'
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
        TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
             method='psd', coh=0.8
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.01,/refine,/minus
;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.003,/minus
  ENDIF
  
  
END
