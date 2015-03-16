;
; Simualation to test the combined long-and-short baseline analyses InSAR algorithm.
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ InSAR Team, SWJTU, 20140227
;   similar results can be found in '/mnt/ihiusa/Software/ForExperiment/sim'
;   The corresponding shell scripts are also in the same path.
;
; Written for:
;   Sister Honguo Jia.
;
; History:
;   20140609: Add baseline combination functions for Hongguo Jia.
;             by T.LI @ SWJTU
;
@tli_delaunay
@tli_linear_solve_gamma
@tli_hpa_1level
@tli_get_residuals

PRO TLI_DEDUPLICATE_VDHFILE, vdhfile,outputfile=outputfile
  ; Eliminate the duplicate records in vdh file.
  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=vdhfile+'_deduplicate'
  plist=COMPLEX(vdh[1, *], vdh[2, *])
  
  ind=SORT(plist)
  plist=plist[ind]
  vdh=vdh[*,ind]
  
  ind=UNIQ(plist)
  plist=plist[ind]
  vdh=vdh[*, ind]
  
  TLI_WRITE, outputfile, vdh
  
END

PRO TLI_CONVERT_RESIDUES, resfile, plistfile, outputfile=outputfile
  ; Convert the data in resfile.
  ; Format will be transferred from float to SLC.

  IF NOT KEYWORD_SET(outpuptfile) THEN outputfile=resfile+'.slc'
  npt=TLI_PNUMBER(plistfile)
  res=TLI_READDATA(resfile, samples=npt, format='double')
  res=res[*,3:*]
  result=COMPLEX(COS(res), SIN(res))
  
  TLI_WRITE, outputfile, result,/SWAP_ENDIAN
  
END

PRO TLI_REPORT_DVDDH, simlinfile, simherrfile, m_ind, s_ind

  simlin=TLI_READDATA(simlinfile, samples=1, format='DOUBLE')
  simherr=TLI_READDATA(simherrfile, samples=1, format='DOUBLE')
  
  result=[m_ind, s_ind, simlin[s_ind]-simlin[m_ind], simherr[s_ind]-simherr[m_ind], 1D, 0D]
  Print, result
END

PRO TLI_SIMULATION_LEMON_GG

  ; Define some params
  sim_flag=0     ; Simulation flag
  sim_pt_flag=1   ; Simulating point coordinates flag. Set this to fix the coordinates.
  sim_lin_flag=1  ; Simulating linear deformation rate flag.
  sim_herr_flag=1 ; Simualting DEM error flag.
  noise_level=15  ; Noise to be added. In unit: degree, not radians. See Kampes, 2004.
  
  sim_inv_flag=1 ; Simulation inversion flag.
  sim_val_flag=1 ; Simulation validation flag.
  
  ; Specify the working directory.
  simfrompath= '/mnt/data_tli/ForExperiment/Lemon_gg/TSX_PS_SH_OP'
  simfrompath= simfrompath+PATH_SEP()
  sarlistfile= simfrompath+'SLC_tab'
  itabfile= simfrompath+'itab'
  simbasepath= simfrompath+'HPA/base'
  baselistfile=simfrompath+'base.list'
  
  workpath=FILE_DIRNAME(simfrompath)+PATH_SEP()
  logfile= workpath+'log.txt'
  ptfile= workpath+'pt'
  deffile= workpath+'def'
  maskfile= workpath+'mask'
  simlinfile= workpath+'simlin'  ; simulated linear deformation v
  simherrfile= workpath+'simherr'
  simph_unwfile= workpath+'simph_unw' ; Simulated unwrapped phase.
  simphfile= workpath+'simph.slc'  ; simulated differential phase
  pbasefile= workpath+'pbase'
  plafile= workpath+'pla'
  pdifffile=workpath+'pdiff0'
  
  
  hpapath=workpath+'HPA'+PATH_SEP()
  plistfile=hpapath+'plist'
  plistfile_update=plistfile+'update'
  lookupfile=hpapath+'plist.lookup'
  vdhfile=hpapath+'vdh'
  
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  ;  ;--------------------------------------------------
  ;  ; Parames to use.
  ;  ;
  ;  TLI_LOG, logfile, 'Define the ranges for parameters.'
  ;  ; We assume that the minimum perpendicular baseline is used.
  ;  TLI_AMBIGUITIES, sarlistfile, baselistfile, dv=0, ddh=ddh,int_index=15
  ;  TLI_LOG, logfile, 'The height ambiguity is:'+STRCOMPRESS(ddh),/PRT
  
  
  ;---------------------------------------------------------------------
  ; Define the parames
  ;
  simlin_range=[-10,10]
  simherr_range=[-30,30]; Simulated height error.
  coh=0.8
  method='ls'  ; Three choices: 'ls', 'psd' or 'coco'
  ; some params
  e= TLI_E()
  c= 299792458D ; Speed light
  samples=finfo.range_samples
  lines=finfo.azimuth_lines
  ;----------------------------------------------------------------------------------------------
  TLI_LOG, logfile, '**************************************************************************'
  TLI_LOG, logfile, 'Simulation for sister Guozi. Task started at:'+TLI_TIME(/str)
  TLI_LOG, logfile, 'sim_flag='+STRING(sim_flag)+'      ; Simulation flag'
  TLI_LOG, logfile, 'sim_pt_flag='+STRING(sim_pt_flag)+'   ; Simulating point coordinates flag. Set this to fix the coordinates.'
  TLI_LOG, logfile, 'sim_lin_flag='+STRING(sim_lin_flag)+'  ; Simulating linear deformation rate flag.'
  TLI_LOG, logfile, 'sim_herr_flag='+STRING(sim_herr_flag)+' ; Simualting DEM error flag.'
  TLI_LOG, logfile, 'noise_level='+STRING(noise_level)+'   ; Noise to be added. In unit: degree, not radians. See Kampes, 2004.'
  TLI_LOG, logfile, 'sim_inv_flag='+STRING(sim_inv_flag)+'  ; Simulation inversion flag.'
  TLI_LOG, logfile, 'sim_val_flag='+STRING(sim_val_flag)+'  ; Simulation validation flag.'
  TLI_LOG, logfile, 'coh='+STRING(coh)
  TLI_LOG, logfile, 'Relative deformation extraction using:'+method
  
  IF NOT FILE_TEST(hpapath,/DIRECTORY) THEN FILE_MKDIR, hpapath
  
  ;****************************************************************************
  ;***************SIMULATION***************************************************
  ;****************************************************************************
  IF sim_flag EQ 1 THEN BEGIN
    ; Load master image info
    finfo= TLI_LOAD_MPAR(sarlistfile,itabfile)
    
    TLI_LOG, logfile, 'Task started at :'+TLI_TIME(/str)
    TLI_LOG, logfile, 'Workpath:'+workpath
    
    area='urban'
    
    ; First sim a plist file. Uniformly distributed.
    IF sim_pt_flag EQ 1 THEN BEGIN
      TLI_LOG, logfile, ' '
      TLI_LOG, logfile, 'Simulated point list: '+ptfile
      TLI_LOG, logfile, 'Start at time:'+TLI_TIME(/str)
      Case area OF
        'urban': BEGIN
          percent_l=1/100D  ;low percentage ;Colesanti, Ferretti, etc, SAR monitoring of progressive...
          percent_h=3.2/100D  ;high percentage
        END
        'rural': BEGIN
          percent_l=0.12/100D  ;low percentage
          percent_h=0.4/100D  ;high percentage
        END
        ELSE: BEGIN
          percent_l=1/100D  ;low percentage
          percent_h=3.2/100D  ;high percentage
        END
      ENDCASE
      percent= ABS(RANDOMN(seed))
      percent= percent_l+(percent_h-percent_l)*percent
      percent= 0.02
      TLI_LOG, logfile,'Percent of PSs:'+STRCOMPRESS(percent),/prt
      
      npt= LONG(samples*lines*percent)
      
      x= LONG(RANDOMU(seed, 1, npt)*samples)
      y= LONG(RANDOMU(seed, 1, npt)*lines)
      ; Discard the duplicate points.
      pt=COMPLEX(x, y)
      pt=TLI_SORT_COMPLEX(pt)
      pt=pt[*, UNIQ(pt)]
      x=REAL_PART(pt)
      y=IMAGINARY(pt)
      pt=LONG([x,y])
      
      TLI_WRITE, ptfile, pt,/SWAP_ENDIAN
      TLI_WRITE, ptfile+'.txt', [x, y],/txt
      TLI_WRITE, workpath+'HPA/plist', [x,y]
      
      npt=TLI_PNUMBER(ptfile)
      mask= BYTARR(npt,npt)
      mask[x, y]=1
      TLI_WRITE, maskfile, mask
      TLI_LOG, logfile, 'Number of PSs:'+strcompress(npt),/prt
    ENDIF ELSE BEGIN
      pt=TLI_READDATA(ptfile, samples=2, format='LONG',/SWAP_ENDIAN)
      x=pt[0, *]
      y=pt[1, *]
      npt=TLI_PNUMBER(ptfile)
      mask=TLI_READDATA(maskfile, samples=npt, format='byte')
    ENDELSE
    
    
    ;------------------------------------------------------------
    IF sim_lin_flag EQ 1 THEN BEGIN
      ; Simulate a deformation velocity field.
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'Simulate a deformation field: '+simlinfile
      
      IF 0 THEN BEGIN
        TLI_LOG, logfile, 'We use a second-order polynomial to do simulation'
        TLI_LOG, logfile, 'Coefficents are[x2, y2, xy, x,y,1]'
        coefs=[1,1,1,1,1,1]
        TLI_LOG, logfile,coefs
        xt= TRANSPOSE(x)  ; n samples * 1 line
        yt= TRANSPOSE(y)
        loc= [[xt^2],[yt^2], [xt*yt], [xt], [yt], [1+FINDGEN(N_ELEMENTS(xt))]]
        simlin= coefs##(loc)
      ENDIF ELSE BEGIN
        TLI_LOG, logfile, 'Use a Gaussian function to do simulation'
        simlin= SHIFT(DIST(samples), samples/2, lines/2)  ; Gaussian function
        simlin= EXP(-(simlin/samples/4D)^2)
        simlin= simlin[x, y]
        simlin= -TRANSPOSE(simlin)
      ENDELSE
      ;  simlin_range=[-50,55] ; simulated linear deformation vel. range
      
      simlin= TLI_STRETCH_DATA(simlin, simlin_range)
      
      ;  simlin= DBLARR(npt)  ; Do not simulate a deformation velocity field
      TLI_WRITE, simlinfile, simlin
      TLI_WRITE, simlinfile+'.txt', [x, y, TRANSPOSE(simlin)],/txt
      ; Call gmt to plot def. field.
      CD, workpath
      cmd=workpath+'plot_linear_sim.sh'
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'Plot deformation field using '+cmd
      TLI_LOG, logfile, ''
      
      SPAWN, cmd
    ENDIF ELSE BEGIN
      IF FILE_TEST(simlinfile) THEN BEGIN
        simlin=TLI_READDATA(simlinfile, samples=1, format='double')
      ENDIF ELSE BEGIN
        simlin=DBLARR(1, npt)
      ENDELSE
      simlin=TRANSPOSE(simlin)
    ;      simlin=DBLARR( npt)
    ;      TLI_WRITE, simlinfile, simlin
    ;      TLI_WRITE, simlinfile+'.txt', [x, y, TRANSPOSE(simlin)],/txt
    ; Do not plot the figure
    END
    
    
    ;------------------------------------------------------------------
    IF sim_herr_flag EQ 1 THEN BEGIN
    
      IF 1 THEN BEGIN
        ; Simulate height error using random data.
        simherr= RANDOMN(seed, 1, npt)
      ENDIF ELSE BEGIN
        ; Simulate height error using Gauss function.
        ; This is not rational. But applicable to facilitate
        ; the model assessment.
        simherr= SHIFT(DIST(samples), samples/2, lines/2)  ; Gaussian function
        simherr= EXP(-(simherr/samples/4D)^2)
        simherr= -simherr[x, y]
      ENDELSE
      
      simherr= TLI_STRETCH_DATA(simherr, simherr_range)
      
      TLI_WRITE, simherrfile, simherr
      TLI_WRITE, simherrfile+'.txt', [x, y, simherr],/TXT
      cd , workpath
      cmd= workpath+'plot_herr_sim.sh'
      SPAWN, cmd
      
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'Plot height error using '+cmd
      TLI_LOG, logfile, ''
    ENDIF ELSE BEGIN
      simherr=TLI_READDATA(simherrfile, samples=1, format='double')
    ;      TLI_LOG, logfile, 'Did not simulate the height error.'
    ;      simherr= DBLARR(1, npt)  ; Do not simulate height error.
    ;      TLI_WRITE, simherrfile, simherr
    ;      TLI_WRITE, simherrfile+'.txt', simherr,/TXT
    ENDELSE
    
    
    ;------------------------------------------------------------
    ; Get pbase and pla.
    slctabfile= sarlistfile
    basepath=simbasepath
    TLI_GAMMA_BP_LA_FUN, ptfile, itabfile, slctabfile, basepath, pbasefile, plafile,/force,/GAMMA
    nintf= FILE_LINES(itabfile)
    ;----------------------------------------
    ; Simulate pdiff
    ; First calculate phase of each point
    pla= TLI_READDATA(plafile,samples=npt, FORMAT='DOUBLE')
    pbase= TLI_READDATA(pbasefile,samples=npt, format='DOUBLE')
    bt=TBASE_ALL(sarlistfile, itabfile)
    
    wavelength= c/finfo.radar_frequency
    ref_r= finfo.near_range_slc+finfo.range_pixel_spacing*x
    sinla= SIN(pla)
    
    K1= -4*(!PI)/(wavelength*ref_r*sinla)
    K2= -4*(!PI)/(wavelength*1000)
    
    coefs_v=K2*bt
    coefs_dh= pbase*REBIN(TRANSPOSE(K1), npt, nintf)
    
    simph_unw= coefs_v##simlin+coefs_dh*REBIN(TRANSPOSE(simherr),npt, nintf)
    
    ;--------------------------------------------------------------------
    IF noise_level NE 0 THEN BEGIN
      ; Simulate noise
      noise= RANDOMN(seed, npt, nintf)
      ; Change the mean value to 15 degrees, dev to 5 degrees.
      noise= noise*DEGREE2RADIANS(noise_level)
    ENDIF ELSE BEGIN
      noise=DBLARR(npt, nintf) ; Do not simulate noise
    ENDELSE
    
    ; Add noise
    simph_unw= simph_unw+noise
    
    TLI_WRITE, simph_unwfile, simph_unw
    ;-----------------------------------------------------
    ; Wrap the phase
    simph=TLI_WRAP_PHASE(simph_unw)
    simph_slc= COMPLEX(cos(simph), sin(simph))
    
    TLI_WRITE, simphfile, simph_slc,/SWAP_ENDIAN
    
    ;    TLI_WRITE, simphfile+'.txt',[x, y, TRANSPOSE(simph)], /txt
    
    ;    IF 1 THEN BEGIN
    ;      ; Plot all diff figures.
    ;      Print, 'Plotting all diff images...'
    ;      cmd= workpath+'plot_simph.sh'
    ;      CD, workpath
    ;      SPAWN, cmd
    ;      TLI_LOG, logfile, 'Formats are referred to GAMMA.'
    ;      TLI_LOG, logfile, 'All .jpg are put into plotdata folder.'
    ;    ENDIF
    
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Simulation ended at time:'+TLI_TIME(/str),/prt
  ENDIF
  
  
  
  
  
  
  IF 1 THEN BEGIN
    ;-----------------------------------------------------------------------------------------------------------------------
    ; inversion
    ; Step 1.1.0 Use [10, 50] as def. rate thresh. and DEM err. thresh.
    itabfile=workpath+'itab'
    method='coco'
    dv_thresh=0D
    ddh_thresh=0D
    ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
      dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask)
    IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
    TLI_UPDATE_ITAB, itabfile, mask=mask,outputfile=workpath+'itab'
    TLI_UPDATE_PDIFF, workpath+'simph.slc', plistfile, itabfile, outputfile=workpath+'simph.slc.update'
    
    ; Step 1.1.1 Use the updated itab file to calculate deformation rate map and DEM error map.
    ; This is a preliminary result.
    FILE_COPY, workpath+'simph.slc.update', workpath+'pdiff0',/OVERWRITE
    itabfile=workpath+'itab'
    sarlistfile=workpath+'SLC_tab'
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    mask_arc=0.7
    mask_pt_coh=0.7
    v_acc=3
    dh_acc=10
    coh=0.9
    pbase_thresh=100
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
      /ls, method=method, coh=coh
      
    ; Step 1.1.2. Quality assessment.
    assess=TLI_SIM_ASSESSMENT(workpath)
    dv_thresh=assess.maxdv
    ddh_thresh=assess.maxddh
    TLI_LOG, logfile, 'RMSE of deformation rates:'+STRCOMPRESS(assess.rmse_v),/prt
    TLI_LOG, logfile, 'RMSE of DEM error:'+STRCOMPRESS(assess.rmse_dh),/prt
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Parameters to determine next baseline combinations:',/prt
    TLI_LOG, logfile, '    dv_thresh:'+STRCOMPRESS(dv_thresh),/prt
    TLI_LOG, logfile, '    ddh_thresh:'+STRCOMPRESS(ddh_thresh),/prt
    ;  ; Plot the two figures
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt, intercept=assess.intercept_v
      
    tli_plot_dem_error,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt,intercept=assess.intercept_dh
      
  ENDIF
  
  STOP
  
  
  
  
  
  
  
  ;------------------------------------------------------------------------------------------------------------------------
  IF 0 THEN BEGIN
    ;********************************************************************
    ;*********SIMULATION INVERSION USING BASELINE COMBINATION************
    ;********************************************************************
  
    ;----------------------------------------------------------------------------------------
    ; Step 1. Use the short baseline combinations to extract deformation params.
  
    ; Step 1.1. Determine short baseline thresholds.
    IF 1 THEN BEGIN
      ; Step 1.1.0 Use [10, 50] as def. rate thresh. and DEM err. thresh.
      dv_thresh=10D
      ddh_thresh=30D
      ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
        dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask)
      IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
      TLI_UPDATE_ITAB, itabfile, mask=mask,outputfile=workpath+'itab'
      itabfile=workpath+'itab'
      TLI_UPDATE_PDIFF, workpath+'simph.slc', plistfile, itabfile, outputfile=workpath+'simph.slc.update'
      
      ; Step 1.1.1 Use the updated itab file to calculate deformation rate map and DEM error map.
      ; This is a preliminary result.
      FILE_COPY, workpath+'simph.slc.update', workpath+'pdiff0',/OVERWRITE
      itabfile=workpath+'itab'
      sarlistfile=workpath+'SLC_tab'
      finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
      mask_arc=0.7
      mask_pt_coh=0.7
      v_acc=3
      dh_acc=10
      coh=0.7
      
      TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
        /ls, method=method, coh=coh
      ; Step 1.1.2. Use the true relative deformation params to determine baseline combination.
      assess=TLI_SIM_ASSESSMENT(workpath)
      dv_thresh=assess.maxdv
      ddh_thresh=assess.maxddh
      ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
        dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask)
      IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
      TLI_UPDATE_ITAB, itabfile, mask=mask
      TLI_UPDATE_PDIFF, workpath+'simph.slc', plistfile, itabfile, outputfile=workpath+'simph.slc.update'
      
      ; Step 1.1.3. For the second time, use the updated itab file to calculate deformation rate map and DEM error map.
      ; This is final result for step 1.
      FILE_COPY, workpath+'simph.slc.update', workpath+'pdiff0',/OVERWRITE
      itabfile=workpath+'itab'
      sarlistfile=workpath+'SLC_tab'
      finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
      mask_arc=0.7
      mask_pt_coh=0.7
      v_acc=3
      dh_acc=10
      coh=0.7
      TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
        /ls, method=method, coh=coh
      FILE_COPY, vdhfile, vdhfile+'_step1',/overwrite
    ENDIF
    
    ;  TLI_ADD_VDHFILES, '/mnt/data_tli/ForExperiment/Lemon_gg/simvdh_dedu', $
    ;                    '/mnt/data_tli/ForExperiment/Lemon_gg/HPA/vdh',/minus, $
    ;                    outputfile=vdhfile
    
    ; Step 1.1.4. Quality assessment.
    assess=TLI_SIM_ASSESSMENT(workpath)
    dv_thresh=assess.maxdv
    ddh_thresh=assess.maxddh
    TLI_LOG, logfile, 'RMSE of deformation rates:'+STRCOMPRESS(assess.rmse_v),/prt
    TLI_LOG, logfile, 'RMSE of DEM error:'+STRCOMPRESS(assess.rmse_dh),/prt
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Parameters to determine next baseline combinations:',/prt
    TLI_LOG, logfile, '    dv_thresh:'+STRCOMPRESS(dv_thresh),/prt
    TLI_LOG, logfile, '    ddh_thresh:'+STRCOMPRESS(ddh_thresh),/prt
    ;  ; Plot the two figures
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt,/minus;, intercept=assess.intercept_v
      
    tli_plot_dem_error,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt;,intercept=assess.intercept_dh
      
    ; Step 1.1.5. Extract the phase residues with deformation information removed.
    pdifffile=simphfile
    res_phasefile=hpapath+'residues.phase'
    res_slcfile=hpapath+'residues.slc'
    TLI_GET_RESIDUALS, sarlistfile, plistfile, itabfile, pdifffile, pbasefile, plafile,vdhfile,refind, $
      res_phasefile= res_phasefile, time_series_linearfile= time_series_linearfile, $
      R1,rps, wavelength,/ignore_refind,/swap_endian
      
    ; Convert residues file.
    TLI_CONVERT_RESIDUES, res_phasefile, plistfile, outputfile=res_slcfile
    
    ;************************This is the end of Second iteration*****************************
    
    ;------------------------------------------------------------------------------------------------
    ; Step 2.1.0 Calculate deformation params using the last assessment results.
    ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
      dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask)
    IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
    
    ;  nintf_this=N_ELEMENTS(ind)
    ;  IF nintf_this LE nintf_last THEN BEGIN
    ;    TLI_LOG, logfile, 'Convergence encountered. No. of interferograms begin to decrease.',/prt
    ;    iter_end=1
    ;  ENDIF ELSE BEGIN
    ;    nintf_last=nintf_this
    ;  ENDELSE
    
    TLI_UPDATE_ITAB, itabfile, mask=mask,outputfile=workpath+'itab'
    
    
    IF 0 THEN BEGIN
    
      TLI_UPDATE_PDIFF, res_slcfile, plistfile, itabfile, outputfile=workpath+'simph.slc.update'
      
    ENDIF ELSE BEGIN
    
      TLI_UPDATE_PDIFF, workpath+'simph.slc', plistfile, itabfile, outputfile=workpath+'simph.slc.update'
      
    ENDELSE
    
    ; Step 2.1.1 Use the updated itab file to calculate deformation rate map and DEM error map.
    FILE_COPY, workpath+'simph.slc.update', workpath+'pdiff0',/OVERWRITE
    itabfile=workpath+'itab'
    sarlistfile=workpath+'SLC_tab'
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    mask_arc=0.7
    mask_pt_coh=0.7
    v_acc=3
    dh_acc=10
    coh=0.7
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
      /ls, method=method, coh=coh
      
    ; Step 2.1.2. Quality assessment.
    assess=TLI_SIM_ASSESSMENT(workpath)
    dv_thresh=assess.maxdv
    ddh_thresh=assess.maxddh
    ;  tli_plot_linear_def,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
    ;    /no_clean,cpt='tli_def', /fliph_pt,/minus, intercept=assess.intercept_v,outputfile=outputfile
    ;  tli_plot_dem_error,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
    ;    /no_clean,cpt='tli_def', /fliph_pt,intercept=assess.intercept_dh,outputfile=outputfile
    ;  TLI_LOG, logfile, 'RMSE of deformation rates:'+STRCOMPRESS(assess.rmse_v)
    ;  TLI_LOG, logfile, 'RMSE of DEM error:'+STRCOMPRESS(assess.rmse_dh)
    ;  TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Parameters to determine next baseline combinations:'
    TLI_LOG, logfile, '    dv_thresh:'+STRCOMPRESS(dv_thresh)
    TLI_LOG, logfile, '    ddh_thresh:'+STRCOMPRESS(ddh_thresh)
    ;--------------------------------------------------------------------------------------
    ; Step 2.2.0,   Calculate deformation params using the last assessment results.
    ind=TLI_USB_COMBINATION(sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
      dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask)
    IF ind[0] EQ -1 THEN Message, 'Error! No eligible interferograms!'
    
    ;  nintf_this=N_ELEMENTS(ind)
    ;  IF nintf_this LE nintf_last THEN BEGIN
    ;    TLI_LOG, logfile, 'Convergence encountered. No. of interferograms begin to decrease.',/prt
    ;    iter_end=1
    ;  ENDIF ELSE BEGIN
    ;    nintf_last=nintf_this
    ;  ENDELSE
    
    TLI_UPDATE_ITAB, itabfile, mask=mask
    TLI_UPDATE_PDIFF, res_slcfile, plistfile, itabfile, outputfile=workpath+'simph.slc.update'
    
    ; Step 2.2.1 Use the updated itab file to calculate deformation rate map and DEM error map.
    FILE_COPY, workpath+'simph.slc.update', workpath+'pdiff0',/OVERWRITE
    itabfile=workpath+'itab'
    sarlistfile=workpath+'SLC_tab'
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    mask_arc=0.7
    mask_pt_coh=0.7
    v_acc=3
    dh_acc=10
    coh=0.7
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
      /ls, method=method, coh=coh
    FILE_COPY, vdhfile, vdhfile+'_step2',/overwrite
    ; Step 2.2.2. Add the residual deformation rates and the DEM errors into
    ; the parameters calculated from Step 1.
    TLI_ADD_VDHFILES, vdhfile+'_step1', vdhfile+'_step2', outputfile=vdhfile+'_step1+2'
    FILE_COPY, vdhfile+'_step1+2', vdhfile,/OVERWRITE
    
    ; Step 2.2.3. Quality assessment.
    assess=TLI_SIM_ASSESSMENT(workpath)
    dv_thresh=assess.maxdv
    ddh_thresh=assess.maxddh
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt,/minus, intercept=assess.intercept_v,outputfile=outputfile
    tli_plot_dem_error,hpapath+'vdh', hpapath+'ave_white.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      /no_clean,cpt='tli_def', /fliph_pt,intercept=assess.intercept_dh,outputfile=outputfile
    TLI_LOG, logfile, 'RMSE of deformation rates:'+STRCOMPRESS(assess.rmse_v)
    TLI_LOG, logfile, 'RMSE of DEM error:'+STRCOMPRESS(assess.rmse_dh)
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Parameters to determine next baseline combinations:'
    TLI_LOG, logfile, '    dv_thresh:'+STRCOMPRESS(dv_thresh)
    TLI_LOG, logfile, '    ddh_thresh:'+STRCOMPRESS(ddh_thresh)
  END
  ;-----------------------------------------------------------------------------------------------------------------------
  
  
  
  
  
  
  
  
  
  STOP
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  IF 0 THEN BEGIN
    ;********************************************************************
    ;*******************SIMULATION INVERSION*****************************
    ;********************************************************************
    IF sim_inv_flag EQ 1 THEN BEGIN
    
      ;----------------Prepare Files--------------------------------
    
      FILE_COPY, workpath+'simph.slc', workpath+'pdiff0',/OVERWRITE
      
      itabfile=workpath+'itab'
      sarlistfile=workpath+'SLC_tab'
      ; Run tli_hpa_1level.pro
      finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
      mask_arc=0.7
      mask_pt_coh=0.7
      v_acc=3
      dh_acc=10
      coh=0.7
      TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,$
        /ls, method=method, coh=coh, pbase_thresh=1000
    ;    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    ;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.03,$
    ;      /no_clean,cpt='tli_def', /fliph_pt,/refine,/minus,/los_to_v,/noframe
    ENDIF
    ;******************************************************************
    ;***************Validation*****************************************
    ;******************************************************************
    
    IF sim_val_flag EQ 1 THEN BEGIN
    
      ;-------------------------
      ; Plot the two figures
      ;    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.03,$
      ;      /no_clean,cpt='tli_def', /fliph_pt,/refine,/minus,/noframe, intercept=9
      ;        tli_plot_dem_error,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.01,$
      ;          /no_clean,cpt='tli_def', /fliph_pt,/refine,/minus,/noframe
    
      scr='/mnt/data_tli/ForExperiment/Lemon_gg/HPA/plot_vdh.sh'
      CD, FILE_DIRNAME(scr)
      SPAWN, scr
      ;----------------------------------------
      ; Check the dvddh file.
      dvddhfile=hpapath+'dvddh'
      simlinfile=workpath+'simlin'
      simherrfile=workpath+'simherr'
      lookupfile=hpapath+'plist.lookup'
      dvddhupdatefile=hpapath+'dvddh_update'
      vdhfile=hpapath+'vdh'
      
      simlin=TLI_READDATA(simlinfile, samples=1, format='double')
      simherr=TLI_READDATA(simherrfile, samples=1, format='double')
      
      dvddh=TLI_READMYFILES(dvddhfile, type='dvddh')
      
      s_ind=dvddh[0, *]
      e_ind=dvddh[1, *]
      dv=dvddh[2, *]
      ddh=dvddh[3, *]
      coh=dvddh[4, *]
      sigma=dvddh[5, *]
      
      dv_sim=simlin[*, e_ind]-simlin[*, s_ind]
      ddh_sim=simherr[*,e_ind]-simherr[*, s_ind]
      
      dv_sigma=MAX(ABS(dv_sim-dv))
      ddh_sigma=MAX(ABS(ddh_sim-ddh))
      TLI_LOG, logfile, 'Maximum relative deformation rate error (dvddh):'+STRING(dv_sigma),/prt
      TLI_LOG, logfile, 'Pairs with relative deformation rate error greater than 0.1:'$
        +STRING(N_ELEMENTS(WHERE(ABS(dv_sim-dv) GT 0.1))),/prt
      TLI_LOG, logfile, 'Maximum relative DEM error (dvddh):' + STRING(ddh_sigma),/prt
      TLI_LOG, logfile, 'Pairs with relative DEM error greater than 1:'$
        +STRING(N_ELEMENTS(WHERE(ABS(ddh_sim-ddh) GT 1))),/prt
      ;---------------------------------------------------------------------------------
      ; Check the updated dvddh file.
      dvddhupdate=TLI_READMYFILES(dvddhupdatefile, type='dvddh')
      lookup=TLI_READDATA(lookupfile, samples=2, format='DOUBLE')
      
      s_ind=dvddhupdate[0, *]
      e_ind=dvddhupdate[1, *]
      dv=dvddhupdate[2, *]
      ddh=dvddhupdate[3, *]
      coh=dvddhupdate[4, *]
      sigma=dvddhupdate[5, *]
      
      lookup_inverse=lookup[*, SORT(lookup[1,*])]
      lookup_inverse=lookup_inverse[*, 1:*]
      npt=(SIZE(lookup_inverse,/DIMENSIONS))[1]
      PRINT, TOTAL(ABS(lookup_inverse[1,*]-FINDGEN(npt)))
      
      s_ind_true=lookup_inverse[0, s_ind]
      e_ind_true=lookup_inverse[0, e_ind]
      dv_sim=simlin[*, e_ind_true]-simlin[*, s_ind_true]
      ddh_sim=simherr[*,e_ind_true]-simherr[*, s_ind_true]
      
      dv_sigma=MAX(ABS(dv_sim-dv))
      ddh_sigma=MAX(ABS(ddh_sim-ddh))
      TLI_LOG, logfile, 'Maximum relative deformation rate error (updated dvddh):'+STRING(dv_sigma),/prt
      TLI_LOG, logfile, 'Pairs with relative deformation rate error greater than 0.1 (updated dvddh):'$
        +STRING(N_ELEMENTS(WHERE(ABS(dv_sim-dv) GT 0.1))),/prt
      TLI_LOG, logfile, 'RMSE of relative deformation rates:'+STRING(SQRT(MEAN((dv_sim-dv)^2))),/prt
      TLI_LOG, logfile, 'Maximum relative DEM error (updated dvddh):' + STRING(ddh_sigma),/prt
      TLI_LOG, logfile, 'Pairs with relative DEM error greater than 0.1 (updated dvddh):'$
        +STRING(N_ELEMENTS(WHERE(ABS(ddh_sim-ddh) GT 1))),/prt
      TLI_LOG, logfile, 'RMSE of relative DEM error:'+STRING(SQRT(MEAN((ddh_sim-ddh)^2))),/prt
      ;------------------------------------------------------------------------------------
      ; Check the vdhfile
      vdh=TLI_READMYFILES(vdhfile, type='vdh')
      ind=vdh[0,*]
      v=vdh[3, *]
      dh=vdh[4, *]
      
      ind_true=lookup_inverse[0, ind]
      
      ; Before validation, the LS result have to be corrected.
      interceptv= simlin[0]-v[0]
      v_ls=v+interceptv
      
      interceptdh= simherr[0]-dh[0]
      dh_ls=dh+interceptdh
      
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
      TLI_LOG, logfile, 'Maximum absolute differences between simulated data and calculated data:',/prt
      TLI_LOG, logfile, 'Deformation rates:'+STRCOMPRESS(MAX(ABS(dif_v))),/prt
      TLI_LOG, logfile, 'DEM error:'+STRCOMPRESS(MAX(ABS(dif_dh))),/prt
      TLI_LOG, logfile, 'Points with deformation rates greater than 1:'+STRCOMPRESS(N_ELEMENTS(WHERE(ABS(dif_v) GT 1))-1),/prt
      TLI_LOG, logfile, 'Points with DEM error greater than 1:'+STRCOMPRESS(N_ELEMENTS(WHERE(ABS(dif_dh) GT 1))-1),/prt
      TLI_LOG, logfile, 'Deformation rates RMSE:'+STRCOMPRESS(SQRT(MEAN(dif_v^2))),/PRT
      TLI_LOG, logfile, 'DEM error RMSE:'+STRCOMPRESS(SQRT(MEAN(dif_dh^2))),/PRT
      
      
    ;    temp=v_sim-v_true
    ;    v_sigma=MAX(ABS(temp))
    ;    dh_sigma=MAX(ABS(dh_sim-dh))
    ;
    ;    Print, N_ELEMENTS(WHERE(temp GT 1))
    ;    Print, MAX(ABS(temp))
    ;    STOP
    ;    ;    IF v_sigma > 0.1 THEN Message, 'Error!!!!!!'
    ;    TLI_LOG, logfile, 'Maximum deformation rate error (vdh):'+STRING(v_sigma),/prt
    ;    TLI_LOG, logfile, 'Maximum DEM error (vdh):' + STRING(dh_sigma),/prt
    ;
    ;    TLI_WRITE, vdhfile+'.txt', vdh,/txt
    ;    pt=TLI_READDATA(ptfile, samples=2, format='LONG',/swap_endian)
    ;
    ;    npt=TLI_PNUMBER(ptfile)
    ;    result=[FLTARR(1, npt), pt, simlin, simherr]
    ;    TLI_WRITE, vdhfile+'sim.txt', result,/txt
    ;
    ;    dvddh=TLI_READMYFILES(dvddhfile, type='dvddh')
    ;    dvddh_update=TLI_READMYFILES(dvddhupdatefile, type='dvddh')
    ;    TLI_WRITE, dvddhfile+'.txt',dvddh,/txt
    ;    TLI_WRITE, dvddhupdatefile+'.txt', dvddh_update,/txt
    ;
    ;    plist=TLI_READMYFILES(plistfile, type='plist') & TLI_WRITE, plistfile+'.txt',plist,/txt
    ;    plistupdate=TLI_READMYFILES(plistfile_update, type='plist') & TLI_WRITE, plistfile_update+'.txt',plistupdate,/txt
    ;    STOP
      
    ENDIF
  ENDIF
  
  Print, 'Main pro finished.'+TLI_TIME(/str)
END