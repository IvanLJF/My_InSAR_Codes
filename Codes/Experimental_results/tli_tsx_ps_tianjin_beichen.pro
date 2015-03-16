PRO TLI_TSX_PS_TIANJIN_BEICHEN
  workpath_orig='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen_SBAS'
  hpapath=workpath_orig+PATH_SEP()+'HPA'+PATH_SEP()
  
  lsvdhfile=hpapath+'ls_vdh'
  psdvdhfile=hpapath+'psd_vdh'
  
  
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
  
  
;  tli_plot_linear_def,hpapath+'psd_vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  ;*************************************************
  ;******Calculate the deformation rate map*********
  ;*************************************************
  IF 1 THEN BEGIN
    ;    TLI_REFRESH_MSK, hpapath, level=7
    ; Run tli_hpa_1level.pro
    mask_arc=0.8
    mask_pt_coh=0.8
    v_acc=10
    dh_acc=10
    pbase_thresh=100
    TLI_HPA_1LEVEL,workpath_orig, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
      method='ls', coh=0.9, pbase_thresh=pbase_thresh
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  ;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.003,/minus
  ENDIF
  STOP
  ;*************************************************
  ;*********************Compare the results*********
  ;*************************************************
  IF 1 THEN BEGIN
    lsvdh=TLI_READMYFILES(lsvdhfile, type='vdh')
    psdvdh=TLI_READMYFILES(psdvdhfile, type='vdh')
    
    plist1=COMPLEX(lsvdh[1, *], lsvdh[2, *])
    plist2=COMPLEX(psdvdh[1, *], psdvdh[2, *])
    plist1file=hpapath+'lsplist'
    plist2file=hpapath+'psdplist'
    lkupfile=plist2file+'.lookup'
    TLI_WRITE, plist1file, plist1
    TLI_WRITE, plist2file, plist2
    TLI_COMPARE_PLIST, plist1file, plist2file, /outputlookup
    
    lkup=TLI_READDATA(lkupfile, samples=2, format='double')
    
    ; Find identical points
    ind_common=WHERE(lkup[1, *] NE -1)
    lkup=lkup[*, ind_common]
    
    ; Compare results
    lsv=lsvdh[3, ind_common] & lsdh=lsvdh[4, ind_common]
    psdv=psdvdh[3, ind_common] & psddh=psdvdh[4, ind_common]
    v_diff=psdv-lsv
    dh_diff=psddh-lsdh
    
    Print, 'range of deformation rate differences:',MEAN(ABS(v_diff)), STDDEV(v_diff)
    Print, 'range of dem error differences:',MEAN(ABS(dh_diff)), STDDEV(dh_diff)
    
    Print, 'RMSE of deformation rate:', SQRT(MEAN(ABS(v_diff)^2))
    Print, 'RMSE of DEM error:', SQRT(MEAN(ABS(dh_diff)^2))
  ENDIF
  
  
  ;*************************************************
  ;*********************Count the stamps results****
  ;*************************************************
  IF 0 THEN BEGIN
  
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen_StaMPS/INSAR_20091113/'
    resultfile=workpath+'ps_mean_v.xy'
    result=TLI_READTXT(resultfile,/easy)
    
    v=result[2, *]
    
    minv=MIN(v, max=maxv)
    
    Print, 'Range of v:', minv, maxv
  ENDIF
END