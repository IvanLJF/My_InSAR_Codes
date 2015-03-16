;
; Check the quality of the simulation.
;
; Parameters:
;   workpath: The workpath containing all of the required information.
;
; Return values:
;   A structure consisting of all useful params.
;
; Please be informed that the full filenames are fixed.
; 
; Written by:
;   T.LI @ SWJTU, 20140610
;
FUNCTION TLI_SIM_ASSESSMENT, workpath

  hpapath=workpath+'HPA/'
  ; Check the dvddh file.
  dvddhfile=hpapath+'dvddh'
  simlinfile=workpath+'simlin'
  simherrfile=workpath+'simherr'
  lookupfile=hpapath+'plist.lookup'
  dvddhupdatefile=hpapath+'dvddh_update'
  vdhfile=hpapath+'vdh'
  logfile=workpath+'log.txt'
  
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Quality assessment for simulation.'
  ; Result structure
  result=CREATE_STRUCT('workpath', workpath)                   ; Prepare result
  
  simlin=TLI_READDATA(simlinfile, samples=1, format='double')
  simherr=TLI_READDATA(simherrfile, samples=1, format='double')
  
  dvddh=TLI_READMYFILES(dvddhfile, type='dvddh')
  
  s_ind=dvddh[0, *]
  e_ind=dvddh[1, *]
  dv=dvddh[2, *]
  ddh=dvddh[3, *]
  coh=dvddh[4, *]
  sigma=dvddh[5, *]
  coh_thresh=0.8
  
  dv_sim=simlin[*, e_ind]-simlin[*, s_ind]
  ddh_sim=simherr[*,e_ind]-simherr[*, s_ind]
  
  coh_mask=WHERE(coh GE coh_thresh)
  dv_sim=dv_sim[*, coh_mask]
  dv=dv[*, coh_mask]
  ddh_sim=ddh_sim[*, coh_mask]
  ddh=ddh[*, coh_mask]
  
  maxdv=MAX(dv)
  maxddh=MAX(ddh)
  result=CREATE_STRUCT(result, 'maxdv', maxdv, 'maxddh', maxddh)   ; Update result
  
  temp=dv[SORT(ABS(dv))]
  n=N_ELEMENTS(temp)
  n_cutoff=LONG(n*0.999)
  temp=temp[0:n_cutoff]  
  maxdv=MAX(temp,min=mindv)
  
  temp=ddh[SORT(ABS(ddh))]
  n=N_ELEMENTS(temp)
  n_cutoff=LONG(n*0.999)
  temp=temp[0:n_cutoff]
  maxddh=MAX(temp, min=minddh)
  
  TLI_LOG,logfile, 'Max dv:'+STRCOMPRESS(maxdv),/prt
  TLI_LOG, logfile, 'Max ddh:'+STRCOMPRESS(maxddh),/prt
  
  result=CREATE_STRUCT(result, 'maxdv_999', maxdv, 'maxddh_999', maxddh)    ; Update result
  
  
  dv_sigma=MAX(ABS(dv_sim-dv))
  ddh_sigma=MAX(ABS(ddh_sim-ddh))
  TLI_LOG, logfile, 'Maximum relative deformation rate error (dvddh):'+STRING(dv_sigma),/prt
  TLI_LOG, logfile, 'Pairs with relative deformation rate error greater than 0.1:'$
    +STRING(N_ELEMENTS(WHERE(ABS(dv_sim-dv) GT 0.1))),/prt
  TLI_LOG, logfile, 'Pairs with relative deformation rate error greater than 1:'$
    +STRING(N_ELEMENTS(WHERE(ABS(dv_sim-dv) GT 1))),/prt
  TLI_LOG, logfile, 'Maximum relative DEM error (dvddh):' + STRING(ddh_sigma),/prt
  TLI_LOG, logfile, 'Pairs with relative DEM error greater than 1:'$
    +STRING(N_ELEMENTS(WHERE(ABS(ddh_sim-ddh) GT 1))),/prt
  
  dv_rmse=TLI_RMSE(dv_sim, y=dv)
  ddh_rmse=TLI_RMSE(ddh_sim, y=ddh)
  result=CREATE_STRUCT(result, 'rmse_dv', dv_rmse, 'rmse_ddh', ddh_rmse)   ; Update result
  ;------------------------------------------------------------------------------------
  ; Check the vdhfile
  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  ind=vdh[0,*]
  v=vdh[3, *]
  dh=vdh[4, *]  

  lookup=TLI_READDATA(lookupfile, samples=2, format='DOUBLE')
  
  lookup_inverse=lookup[*, SORT(lookup[1,*])]
  lookup_inverse=lookup_inverse[*, 1:*]
  ind_true=lookup_inverse[0, ind]
  
  ; Before validation, the LS result have to be corrected.
  interceptv= simlin[0]-v[0]
  v_ls=v+interceptv
  
  interceptdh= simherr[0]-dh[0]
  dh_ls=dh+interceptdh
  
  result=CREATE_STRUCT(result, $
                       'intercept_v', interceptv, $
                       'intercept_dh', interceptdh)                 ; Update result
  
  ; And the simulated points have to be re-ordered with reference to plist.lookup
  lookup=TLI_READDATA(lookupfile, samples=2, format='double')
  lookup=lookup[*, WHERE(lookup[1, *] NE -1)]
  lookup_inverse=lookup[*, SORT(lookup[1, *])]
  updated_ind=lookup_inverse[0, *]
  v_sim=simlin[*,updated_ind]
  dh_sim=simherr[*, updated_ind]
  
  ; Count the differences.
  dif_v= v_ls-v_sim
  dif_dh=dh_ls-dh_sim
  
  ; Histogram
  temp=HISTOGRAM(dif_v, NBINS=50, min=min_difv, max=max_difv,locations=hist_x)
  TLI_WRITE, hpapath+'hist_sim_inv_v.txt', TRANSPOSE([[hist_x], [temp]]),/txt
  temp=HISTOGRAM(dif_dh, NBINS=50, min=min_difv, max=max_difv,locations=hist_x)
  TLI_WRITE, hpapath+'hist_sim_inv_dh.txt', TRANSPOSE([[hist_x], [temp]]),/txt
  
  TLI_LOG, logfile, 'Maximum absolute differences between simulated data and calculated data:',/prt
  TLI_LOG, logfile, 'Deformation rates:'+STRCOMPRESS(MAX(ABS(dif_v))),/prt
  TLI_LOG, logfile, 'DEM error:'+STRCOMPRESS(MAX(ABS(dif_dh))),/prt
  TLI_LOG, logfile, 'Points with deformation rates greater than 1:'+STRCOMPRESS(N_ELEMENTS(WHERE(ABS(dif_v) GT 1))-1),/prt
  TLI_LOG, logfile, 'Points with deformation rates greater than 0.1:'+STRCOMPRESS(N_ELEMENTS(WHERE(ABS(dif_v) GT 0.1))-1),/prt
  TLI_LOG, logfile, 'Points with DEM error greater than 1:'+STRCOMPRESS(N_ELEMENTS(WHERE(ABS(dif_dh) GT 1))-1),/prt
  TLI_LOG, logfile, 'Deformation rates RMSE:'+STRCOMPRESS(SQRT(MEAN(dif_v^2))),/PRT
  TLI_LOG, logfile, 'DEM error RMSE:'+STRCOMPRESS(SQRT(MEAN(dif_dh^2))),/PRT
  
  result=CREATE_STRUCT(result, $
                       'max_dif_v', MAX(ABS(dif_v)), $
                       'max_dif_dh', MAX(ABS(dif_dh)), $
                       'rmse_v', SQRT(MEAN(dif_v^2)), $
                       'rmse_dh', SQRT(MEAN(dif_dh^2)))
  RETURN, result
END