;
; Written for my Ph.D thesis.
;
; Written by:
;   T.LI @ SWJTU, 20140306.
;
PRO TLI_PHDTHESIS

  ;###########################################################
  ;###############      Nonlinear      ######################
  ;###########################################################

  workpath= '/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
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
  
  IF 0 THEN BEGIN
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
  STOP
  IF 0 THEN BEGIN
    workpath='/mnt/data_tli/ForExperiment/Thesis'
    workpath=workpath+PATH_SEP()
    
    
    
    ;###########################################################
    ;###############      Simulation      ######################
    ;###########################################################
    intslcfile=workpath+'interferogram.int'
    intpwrfile=workpath+'intpwr.pwr'
    plistfile=workpath+'plist'
    int_noisefile=workpath+'int_noise.int'
    
    vfile=workpath+'v.txt'
    
    samples=500D
    lines=500D
    noise_level=50
    ; Simulate a plist file.
    npt=10000
    
    
    IF NOT FILE_TEST(plistfile) THEN BEGIN
      x= LONG(RANDOMU(seed, 1, npt)*samples)
      y= LONG(RANDOMU(seed, 1, npt)*lines)
      ; Discard the duplicate points.
      plist=COMPLEX(x, y)
      plist=TLI_SORT_COMPLEX(plist)
      plist=plist[*, UNIQ(plist)]
      x=REAL_PART(plist)
      y=IMAGINARY(plist)
      plist=LONG([x,y])
      TLI_WRITE, plistfile, plist,/SWAP_ENDIAN
    ENDIF ELSE BEGIN
      plist=TLI_READDATA(plistfile,samples=2, format='long',/swap_endian)
      x=plist[0, *]
      y=plist[1, *]
    ENDELSE
    
    ; Creat a deformation field using point scatterers.
    simimg= SHIFT(DIST(samples), samples/2, lines/2)  ; Gaussian function
    simimg= -EXP(-(simimg/samples/4D)^2)
    simimg=TLI_STRETCH_DATA(simimg, [-10, 10]); Range: [-10, 10]
    result=simimg[x, y]
    TLI_WRITE, vfile, [x, y, result],/TXT
    
    ; Creat a noise file.
    simimg= RANDOMU(seed, samples, lines)
    simimg= TLI_STRETCH_DATA(simimg, [-10, 10]); Range: [-10, 10]
    
    simimg[x, y]=result
    
    coors=indexarr(x=LINDGEN(samples), y=LINDGEN(lines))
    
    simimg=REFORM(simimg, 1, samples*lines)
    coors=REFORM(coors, 1, N_ELEMENTS(coors))
    
    TLI_WRITE, vfile+'whole.txt',[real_part(coors), imaginary(coors), simimg],/txt
    
    
    
    ;*****************************Some finished experiments.***************************
    
    workpath='/mnt/data_tli/ForExperiment/TSX_HKAirport/rslc'
    workpath=workpath+PATH_SEP()
    
    diffpath=workpath+'diff'+PATH_SEP()
    
    mslcfile=workpath+'20090120.rslc'
    sslcfile=workpath+'20090131.rslc'
    hgtfile=diffpath+'20090120.hgt'
    
    IF 0 THEN BEGIN
      slc=TLI_READSLC(mslcfile)
      phi=ATAN(slc,/PHASE)
      slc=COMPLEX(COS(phi), SIN(phi))
      TLI_WRITE, mslcfile+'_false.rslc', slc,/swap_endian
      
      slc=TLI_READSLC(sslcfile)
      phi=ATAN(slc,/PHASE)
      slc=COMPLEX(COS(phi), SIN(phi))
      TLI_WRITE, sslcfile+'_false.rslc', slc,/swap_endian
    ENDIF
    
    finfo=TLI_LOAD_SLC_PAR(mslcfile+'.par')
    samples=finfo.range_samples
    hgt=TLI_READDATA(hgtfile, samples=samples, format='float',/swap_endian)
    
    hgt=hgt*0.0+0.1
    TLI_WRITE, hgtfile+'_pseudo',hgt,/SWAP_ENDIAN
    
    
    
    
    
    ;****************************Plot a sin figure*******************************************
    x=FINDGEN(1000)*0.1
    y=SIN(x)
    iplot, x, y
    ;******************************Plot a sin figure***************************************
    
    
    ;###########################################################
    ;###############      Test ADI        ######################
    ;###########################################################
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen'+PATH_SEP()
    sarlistfile=workpath+'SLC_tab'
    itabfile=workpath+'itab'
    adifile=workpath+'adi'
    plistfile=workpath+'plist'
    
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    ; Calculate the ADI image
    TLI_HPA_DA, sarlistfile,outputfile=adifile,/swap_endian
    ; Choose point with ADI < 0.25
    plist=TLI_PSSELECT_SINGLE(adifile, samples=finfo.range_samples,format='float',coef=0.25)
    
    TLI_WRITE, plistfile, plist
    TLI_WRITE, plistfile+'.txt', [REAL_PART(plist), finfo.azimuth_lines-1-IMAGINARY(plist)],/txt
    TLI_WRITE, workpath+'pt', [LONG(REAL_PART(plist)), LONG(IMAGINARY(plist))],/swap_endian
    ;###########################################################
    ;###############      Test StaMPS        ######################
    ;###########################################################
    ;  stampspath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen_StaMPS/INSAR_20091113/'
    ;  stampsptfile=stampspath+'ps_ij.txt'
    ;  stampspt=TLI_READTXT(stampsptfile,/easy)
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen_StaMPS/INSAR_20091113/20091011/'
    cintfile=workpath+'slave_res.slc'
    ;  cintfile=workpath+'cint.raw'
    cint=TLI_READDATA(cintfile, samples=finfo.range_samples, format='fcomplex')
    ;  cint_phase=ATAN(cint,/phase)
    cint_phase=ABS(cint)
    cint_phase=CONGRID(cint_phase, finfo.range_samples/5D, finfo.azimuth_lines/5D)
    cint_phase=ROTATE(cint_phase,7)
    window, xsize=500, ysize=500
    TVSCL, cint_phase^0.25
    STOP
    ;###########################################################
    ;###############      Test coherence        ######################
    ;###########################################################
    cc_wavefile='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/selsectpt_cc/cc_ave'
    cc_path=FILE_DIRNAME(cc_wavefile)+PATH_SEP()
    cc_wave=TLI_READDATA(cc_wavefile, samples=finfo.range_samples, format='float',/swap_endian)
    cc_thresh=0.8
    plist_ind=WHERE(cc_wave GE cc_thresh)
    Print, 'Points selected by using coherence > 0.8:', N_ELEMENTS(plist_ind)
    plist_coor=ARRAY_INDICES(cc_wave, plist_ind)
    TLI_WRITE, cc_path+'plist_cc_0.4.txt', [plist_coor[0,*], finfo.azimuth_lines-1-plist_coor[1,*]],/txt
    plist_coor=COMPLEX(plist_coor[0, *], plist_coor[1, *])
    TLI_WRITE, cc_path+'plist_cc_0.4', plist_coor
    STOP
    
    ;###########################################################
    ;###############     Phase analysis  between two points      #################
    ;###########################################################
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
    sarlistfile=workpath+'SLC_tab'
    itabfile=workpath+'itab'
    pdifffile=workpath+'pdiff0'
    plistfile=workpath+'plist'
    outputfile=workpath+'phase_two_points.txt'
    
    ; Read plist
    plist=TLI_READMYFILES(plistfile, type='plist')
    ; read pdiff
    npt=TLI_PNUMBER(plistfile)
    pdiff=TLI_READDATA(pdifffile, samples=npt, format='fcomplex',/swap_endian)
    ; Get diff phase for two points: 3946(ref, coor:967, 936), 5351(pt, coor: 1125, 1287)
    ref_ind=3946
    pt_ind=5351
    
    Print, plist[ref_ind], plist[pt_ind]
    diff_ref=pdiff[ref_ind, *]
    diff_pt=pdiff[pt_ind, *]
    diff_slc=diff_pt*CONJ(diff_ref)
    
    phi_ref=ATAN(diff_ref,/PHASE)
    phi_pt=ATAN(diff_pt, /PHASE)
    phi_diff=ATAN(diff_slc,/PHASE)
    ; Get t_base and date
    t_base=TBASE_ALL(sarlistfile, itabfile)*365
    t_name=TLI_GAMMA_INT(sarlistfile, itabfile, /onlyslave,/date)
    ; Sort the result
    t_ind=SORT(t_base)
    
    phi_ref_sort=phi_ref[t_ind]
    phi_pt_sort=phi_pt[t_ind]
    phi_diff_sort=phi_diff[t_ind]
    t_base_sort=t_base[t_ind]
    t_name_sort=t_name[t_ind]
    result=[[phi_ref_sort], [phi_pt_sort], [phi_diff_sort], [t_base_sort], [t_name_sort]]
    result=TRANSPOSE(result)
    TLI_WRITE, outputfile, result,/txt
    ;###########################################################
    ;###############      Plot network    ######################
    ;###########################################################
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
    bmpfile=workpath+'ave.ras_repair.jpg'
    plistfile=workpath+'plist'
    arcsfile=workpath+'arcs'
    sarlistfile=workpath+'SLC_tab'
    itabfile=workpath+'itab'
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    
    ; Create Denaunay triangulates
    arcs=TLI_DELAUNAY(plistfile, finfo.range_pixel_spacing, finfo.azimuth_pixel_spacing, outname=arcsfile)
    ; Convert format
    TLI_GMT_NETWORK, arcsfile, lines=finfo.azimuth_lines
    
  ;  TLI_PLOT_NETWORK, bmpfile, arcsfile, outputfile=outputfile, show=show
    
  ;################################################################
  ;##################Above are finished experiments################
  ;#################################################################
  END
  
  Print, 'Main pro finished: tli_phdthesis.pro'
END