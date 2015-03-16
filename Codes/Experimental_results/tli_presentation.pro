;+
; Show the functions of the codes.
;
; Params:
;
; Keywords:
;
; Written by:
;   T.LI @ SWJTU, 20140706
;
PRO TLI_PRESENTATION

  ;###########################################################
  ;###############   Step 0. Params Definition ###############
  ;###########################################################
  workpath='/mnt/data_tli/ForExperiment/Presentation'
  workpath=workpath+PATH_SEP()
  
  
  imlistfile=workpath+'im_list' 
  hpapath=workpath+'HPA'+PATH_SEP()
  logfile=hpapath+'log.txt'  
  plistfile=hpapath+'plist'
  sarlistfile=workpath+'SLC_tab'
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  adifile=workpath+'adi'

  ;---------------------------------------
  IF 0 THEN BEGIN  ; Select points using ADI
    TLI_SELECT_PS_ADI, imlistfile, adi=0.5, amp=0, plistfile=plistfile
    FILE_COPY, plistfile, FILE_DIRNAME(FILE_DIRNAME(plistfile))+'/pt',/overwrite
  ENDIF
  
  
  ;###########################################################
  ;###############   Step 1. Data Preparation ################
  ;###########################################################
  ; Step 1. Data preperation.
  ; Call PS_Data_Prepare.sh to
  ;   select PS
  ;   calculate differential phase.
  ;

  ;###########################################################
  ;########   Step 2. Linear Deformation Rate Extraction #####
  ;###########################################################
  ; Step 2.
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
  IF 1 THEN BEGIN
    ; Run tli_hpa_1level.pro
    mask_arc=0.8
    mask_pt_coh=0.8
    v_acc=3
    dh_acc=10
;    pbase_thresh=100
    coh=0.8
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
      method='ls', coh=coh, pbase_thresh=pbase_thresh
    hpapath=workpath+'HPA/'
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', workpath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',$
                        /show,/refine,ptsize=0.01,/minus,/no_clean,/los_to_v
  
  ENDIF
  
  STOP
  
  
  
  
  
  
  ;###########################################################
  ;###############Step 3. Nonlinear Deformation Extraction ###
  ;###########################################################
  
  hpapath=workpath+'HPA/'
  
  sarlistfilegamma= workpath+'SLC_tab'
  sarlistfile= hpapath+'sarlist_Linux'
  pdifffile= workpath+'pdiff0'
  plistfilegamma= workpath+'pt'
  plistfile= hpapath+'plist'
  itabfile= workpath+'itab'
  arcsfile=hpapath+'arcs'
  pbasefile=hpapath+'pbase'
  dvddhfile=hpapath+'dvddh'
  vdhfile= hpapath+'vdh'
  ptattrfile= hpapath+'ptattr'
  arcs_resfile= hpapath+'arcs_res' ; output file
  res_phasefile= hpapath+'res_phase'; output file
  time_series_linearfile= hpapath+'time_series_linear'; output file
  res_phase_slfile= hpapath+'res_phase_sl' ; output file
  res_phase_tlfile= hpapath+'res_phase_tl' ; output file
  final_resultfile= hpapath+'final_result'
  plafile=hpapath+'pla'
  
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  refind=1 ; Reference point's index for Kowloon
  aps= finfo.azimuth_pixel_spacing ; Azimuth pixel spacing
  rps= finfo.range_pixel_spacing ; Range pixel spacing
  R1=finfo.near_range_slc
  winsize= 1000 ; Window size.
  wavelength=TLI_C()/finfo.radar_frequency
  
  low_f=0.2  ; Low frequency for filtering
  high_f=0.25; High frequency for filtering
  
  lamda=0.031 ; Wavelength of TerraSAR-X, 3.1cm
  
  IF 1 THEN BEGIN
    ;---------------------------------------------------------
    Print, 'Retriving connectivities...'
    ;    TLI_RETR_ARCS, plistfile, ptattrfile, refind, arcs_resfile=arcs_resfile
    ;----------------------------------------------------------
    Print, 'Calculating residuals for each point...'
    TLI_GET_RESIDUALS, sarlistfile, plistfile, itabfile, pdifffile, pbasefile, plafile,vdhfile,refind, $
      res_phasefile= res_phasefile, time_series_linearfile= time_series_linearfile, $
      R1,rps, wavelength
      
    ;----------------------------------------------------------
    Print, 'Doing spatially low pass filtering...'
    TLI_SL_FILTER, plistfile, res_phasefile, res_phase_slfile= res_phase_slfile,$
      aps, rps, winsize
      
    ;----------------------------------------------------------
    Print, 'Doing temporally low pass filtering.'
    TLI_TL_FILTER,plistfile, res_phasefile, low_f, high_f, res_phase_tlfile= res_phase_tlfile
    
    
    ;----------------------------------------------------------
    Print, 'Sort out the results'
    Print, 'The results are organized as follows: index, x, y, time_series'
    TLI_SORTOUT_FINAL, plistfile, time_series_linearfile, res_phase_tlfile,lamda, final_resultfile= final_resultfile
    
    Print, 'Phase residuals are decomposed.'
  ENDIF
  
  ; Get the results for three points.
  p1_ind=872
  p2_ind=3054
  p3_ind=1489
  npt=TLI_PNUMBER(plistfile)
  nonfile=res_phase_tlfile
  non=TLI_READDATA(nonfile, samples=npt, format='double')
  p1_non=non[p1_ind, *]
  p2_non=non[p2_ind, *]
  p3_non=non[p3_ind, *]
  
  ; Get the temporal baselines
  tbase=TBASE_ALL(sarlistfile, itabfile)
  ind=SORT(tbase)
  tbase=tbase[*, ind]
  result=[p1_non[*, 3+ind], p2_non[*, 3+ind], p3_non[*, 3+ind]]/(4*!PI)*wavelength*1000
  result=[tbase*365D,result]
  
  TLI_WRITE, nonfile+'.txt', result,/txt
END