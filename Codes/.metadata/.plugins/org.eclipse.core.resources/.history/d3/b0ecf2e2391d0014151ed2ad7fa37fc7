;
; Experimental results by using baseline combinations.
;
; Written by
;   T.LI @ SWJTU, 20140801.
;
@tli_defingoogle
@kml
PRO TLI_COCO_HK

  workpath='/mnt/data_tli/ForExperiment/Lemon_gg/TSX_PS_HK/'
  hpapath=workpath+'HPA'+PATH_SEP()
  geopath=workpath+'geocode'+PATH_SEP()
  logfile=hpapath+'log.txt'
  
  plistfile=hpapath+'plist'
  sarlistfile=workpath+'SLC_tab'
  adifile=workpath+'adi'
  imlistfile=workpath+'im_list'
  pmapllfile=geopath+'plistupdate_gamma.ll'
  vdhfile=hpapath+'vdh'
  
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  ;---------------------------------------
  IF 0 THEN BEGIN  ; Select point using ADI
    TLI_SELECT_PS_ADI, imlistfile, adi=0.5, amp=0, plistfile=plistfile
  ENDIF
  
  ;-----------------------------------
  ; Prepare the differential phase for PTs.
  ; call the script: PS_Data_Prepare
  ;------------------------------------------
  
  
  ;*************************************************
  ;******Calculate the deformation rate map*********
  ;*************************************************
  method='coco'
  coh=0.8
  ignore_def=0
  IF 1 THEN BEGIN
    ;    TLI_REFRESH_MSK, hpapath, level=7
    ; Run tli_hpa_1level.pro
    TLI_HPA_1level,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
      method=method, coh=coh, pbase_thresh=pbase_thresh,ignore_def=ignore_def
      
    ; Plot the deformation velocity.
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    TLI_PLOT_LINEAR_DEF,hpapath+'vdh', workpath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.01,/minus,/no_clean
    ; Plot the DEM error.
    outputfile=hpapath+'vdh_dh'+(TLI_TIME(/STR))+'.jpg'
    TLI_PLOT_DEM_ERROR, hpapath+'vdh', workpath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.01,/minus,/no_clean
    
  ENDIF
  
  
  IF 0 THEN BEGIN  ; Test the results extracted from GAMMA.
    pdeffile=workpath+'pdef'
    pdhfile=workpath+'pdh'
    outputfile=hpapath+'vdh'
    plistfile=workpath+'pt'
    plistfileupdate=hpapath+'plistupdate_gamma'
    gamma_file=1
    TLI_PSUDOVDH, pdeffile,pdhfile=pdhfile, pmaskfile=pmaskfile,outputfile=outputfile,plistfile=plistfile,gamma_file=gamma_file
    FILE_COPY, plistfile, plistfileupdate,/overwrite
    
    ; Plot the deformation velocity.
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    TLI_PLOT_LINEAR_DEF,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.01,/minus,/no_clean
    ; Plot the DEM error.
    outputfile=hpapath+'vdh_dh'+(TLI_TIME(/STR))+'.jpg'
    TLI_PLOT_DEM_ERROR, hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,ptsize=0.01,/minus,/no_clean
  ENDIF
  
  ; Geocoding
  ; Using the given deformation rates and DEM errors.
  TLI_GEOCODING, workpath
  
  phgtfile=geopath+'pdem_final'
  kmlfile=hpapath+'vdh_'+method+'_'+STRCOMPRESS(coh,/remove_all)+'.kml'
  TLI_DEFINGOOGLE,pmapllfile, vdhfile, cptfile=cptfile, colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
    refine_data=refine_data,delta=delta,refined_data=refined_data,randomu=randomu,randomn=randomn,minus=minus
    
  ; I need to assess the results by comparing the coherence
  ; extracted by using both PSD and COCO.
  IF 0 THEN BEGIN
    psdfile=hpapath+'dvddh_PSD'
    cocofile=hpapath+'dvddh_COCO'
    
    psd=TLI_READTXT(psdfile,/easy)
    coco=TLI_READTXT(cocofile,/easy)
    
    result=[psd[[0,1,4],*], coco[[0,1,4], *]]
    
    TLI_WRITE, hpapath+'PSD_COCO.txt', result,/txt
  ENDIF
  
  void=DIALOG_MESSAGE('Main Pro Finished! Time: '+TLI_TIME(/str),/CENTER,/INFORMATION)
  
  
  
  
  
  
  ;-------------------------------------------------------------------------------------------
;  ; Find the available image number.
;  workpath='/mnt/data_tli/Data/Original_data/HK_TSX-StripMap-HK/'
;  
;  coslistfile=workpath+'coslist'
;  
;  coslist=TLI_READTXT(coslistfile, /txt)
;  
;  ncos=N_ELEMENTS(coslist)
;  
;  cosdate=STRARR(1, ncos)
;  
;  FOR i=0, ncos-1 DO BEGIN
;    
;    cosdate[i]=TLI_COSDATE(coslist[i])
;    
;  ENDFOR
;  
;  cosdate=LONG(cosdate)
;  
;  cosdate=cosdate[UNIQ(cosdate[SORT(cosdate)])]



END