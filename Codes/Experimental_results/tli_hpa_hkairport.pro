PRO TLI_HPA_HKAIRPORT

  workpath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/'
  workpath_orig=workpath
  hpapath=workpath+'HPA'+PATH_SEP()
  logfile=hpapath+'log.txt'
  
  plistfile=hpapath+'plist'
  sarlistfile=workpath+'SLC_tab'
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  adifile=workpath+'adi'
  imlistfile=workpath+'im_list'
  ;---------------------------------------
  IF 0 THEN BEGIN  ; Select point using ADI
    TLI_SELECT_PS_ADI, imlistfile, adi=0.5, amp=0, plistfile=plistfile
  ENDIF
  
  ;  adi=TLI_READDATA(adifile, samples=finfo.range_samples, format='float')
  ;
  ;  adi_mode=MODE(adi, nbins=100)
  ;  Print, mean(adi,/NAN), stddev(adi,/NAN)
  ;  Print, adi_mode
  ;  STOP
  ;-----------------------------------------------
  ; HPA
  
  
  ;-----------------------------------
  ; Prepare the differential phase for PTs.
  ; call the script: PS_Data_Prepare
  ;------------------------------------------
  
  
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
    coh=0.8
    ;    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
    ;      method='ls', coh=coh, pbase_thresh=pbase_thresh
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  ;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.003,/minus
  ENDIF
  
  IF 0 THEN BEGIN
  
    coef=[0.4, 0.43]
    ; Run tli_hpa_2level.pro
    TLI_HPA_2LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel2vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.001
    
    coef=[0.43, 0.46]
    ; Run tli_hpa_3level.pro
    TLI_HPA_3LEVEL,workpath_orig,coef=coef,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
    tli_plot_linear_def,hpapath+'lel3vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=0.005
    
    coef=0.46
    i_orig=4
    
    i_start=4
    iter=10
    FOR i=i_start, i_start+iter DO BEGIN
      coef_start=coef+(i-i_start)*0.03
      coef_end=coef+(i-i_start+1)*0.03
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
    ptsize_orig=0.002
    TLI_PLOT_HPA, hpapath, ptsize=ptsize_orig, cpt='tli_def',/compress,percent=0.5,/minus, colorbar_interv=4
  ENDIF
  
  ; Plot the result on google earth.
  IF 0 THEN BEGIN
    ; First merge the result
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/HPA/all_figures/'
    IF 0 THEN BEGIN
      plistfile=workpath+'plistupdate_GAMMA.ll'
    ENDIF ELSE BEGIN
      plistfile=workpath+'lel6plist_update_merge_GAMMA.ll'
    ENDELSE
    
    
    plist=TLI_READDATA(plistfile, format='fcomplex', samples=1, /swap_endian)
    result=DOUBLE([REAL_PART(plist), IMAGINARY(plist)+0.00041])
    TLI_WRITE, plistfile+'.txt', result,/TXT
    
  ;  ptsize_orig=0.002
  ;  tli_plot_linear_def,vdhfile, hpapath+'ave.ras',hpapath+'sarlist_Linux', ptsize=ptsize_orig,/minus,colorbar_interv=4,/no_clean
  ENDIF
  
  ;--------------------------------------------------------------
  ; Extract data.
  workpath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/HPA/all_figures/'
  geopath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/geocode/'
  dempar=geopath+'dem_seg.par'
  llfile=workpath+'lel6plist_update_merge_GAMMA.ll'
  deffile=workpath+'lel6vdh_merge.tmp.txt'
  ll=TLI_READDATA(llfile, samples=2, format='float',/swap_endian)
  def=TLI_READTXT(deffile,/easy)
  IF 0 THEN BEGIN
    range=[234,978, 492, 252]; startx endx starty endy
    outputfile=workpath+'north_runway.txt'
  ENDIF ELSE BEGIN
    range=[264, 1012, 791, 550]
    outputfile=workpath+'south_runway.txt'
  ENDELSE
  
  deminfo=TLI_LOAD_PAR(dempar)
  npt=1001 ; 1000 pieces
  range=double(range)
  
  coors_x=TLI_STRETCH_DATA(DINDGEN(npt), range[0:1])
  coors_y=TLI_STRETCH_DATA(DINDGEN(npt), range[2:3])
  
  ; Convert to geocoded coors
  geo_x=deminfo.corner_lon+deminfo.post_lon*coors_x
  geo_y=deminfo.corner_lat+deminfo.post_lat*coors_y+0.00041
  
  ; Find the identical points
  vdh=[ll, def[2, *]]
  vdh_coors=COMPLEX(vdh[0, *], vdh[1, *])
  result=[DINDGEN(1, npt)*3800D / 1000D, DBLARR(2, npt)]
  coors=[TRANSPOSE(COMPLEX(geo_x, geo_y)), COMPLEXARR(1, npt)]
  FOR i=0, npt-1 DO BEGIN
    coor_i=COMPLEX(geo_x[i],geo_y[i])
    dis=ABS(vdh_coors-coor_i)
    
    dis_min=MIN(dis, ind)
    coors[1, i]=vdh_coors[ind]
    result[1, i]=vdh[2, ind]
    result[2, i]=dis_min
  ENDFOR
  
  TLI_WRITE, outputfile, result[0:1, *],/txt

  STOP
END