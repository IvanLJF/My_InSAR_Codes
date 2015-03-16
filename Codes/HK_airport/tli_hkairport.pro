PRO TLI_HKAIRPORT

  
  workpath_orig='/mnt/backup/ExpGroup/TSX_PS_HK_Airport'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  sarlistfile=hpapath+'sarlist'
  itabfile=workpath_orig+PATH_SEP()+'itab'
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  coef=0.5
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
  ;TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls
  outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
  tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',ptsize=0.005,/no_clean,cpt='rainbow'
  
  
END