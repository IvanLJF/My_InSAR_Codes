PRO TLI_DS_DETECT

  workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin_AOI4_Beichen/'
  sarlistfile=workpath+'SLC_tab'
  itabfile=workpath+'itab'
  diffpath=workpath+'diff_all/'  ; Please use diff_single_pair.sh and diff_all.sh to generate diffs.
  dspath=workpath+'DS_20/'
  logfile=dspath+'log.txt'
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  dslistfile=dspath+'dslist'
  dscmaskfile=dspath+'dsc.mask'
  dsdifffile=dspath+'ds.diff'
  dsgammafile=dspath+'ds.gamma'
  
  plistfile=workpath+'plist'
  pdifffile=workpath+'pdiff0'
  
  ; Filter each differntial intferogram.
  ;
  ; Get the file names of the int. pairs.
  sdate=TLI_GAMMA_INT(sarlistfile, itabfile, /date,/onlyslave)
  diff_basename=TLI_GAMMA_INT(sarlistfile, itabfile, /pair,/date)
  diff_basename=STRCOMPRESS(diff_basename[0,*], /REMOVE_ALL)+'-'+STRCOMPRESS(diff_basename[1,*], /REMOVE_ALL)
  difffiles=diffpath+STRCOMPRESS(TRANSPOSE(sdate),/REMOVE_ALL)+PATH_SEP()+diff_basename+'.diff.int'
  ndiff=N_ELEMENTS(difffiles)
  
  samples=finfo.range_samples
  lines=finfo.azimuth_lines
  format='fcomplex'
  swap_endian=1
  
  ;-----------------------------------------------
  ; Filter all the differential images.
  IF 0 THEN BEGIN
    ; For loops
    FOR i=0, ndiff-1 DO BEGIN
      inputfile=difffiles[i]
      outputfile=dspath+FILE_BASENAME(inputfile)+'.ds_filter'
      IF NOT FILE_TEST(inputfile) THEN BEGIN
        TLI_LOG,logfile,  'ERROR: File does not exist:'+inputfile,/prt
        CONTINUE
      ENDIF
      
      TLI_DS_FILTER, inputfile, dspath, outputfile=outputfile, logfile=logfile, discard_nonds=discard_nonds, $
        samples=samples, lines=lines, format=format, swap_endian=swap_endian
        
    ENDFOR
  ENDIF
  
  ;-----------------------------------------------------
  ; Determine the GAMMA value for each point
  ; Calculate using the phase differences between the non-filtered and filtered DInSAR images.
  ; For loops
  
  ; I donot want to use the standard procedures proposed by Ferretti, 2011.
  ; It is impossible to process 100s of images using my laptop.
  
  ; To get the gamma value for each DSC, I have to filter the images once again.
  IF 0 THEN BEGIN
    ; For loops
    FOR i=0, ndiff-1 DO BEGIN
      inputfile=difffiles[i]
      inputfile=dspath+FILE_BASENAME(inputfile)+'.ds_filter'
      outputfile=inputfile+'.ds_filter'
      IF NOT FILE_TEST(inputfile) THEN BEGIN
        TLI_LOG,logfile,  'ERROR: File does not exist:'+inputfile,/prt
        CONTINUE
      ENDIF
      
      TLI_DS_FILTER, inputfile, dspath, outputfile=outputfile, logfile=logfile, discard_nonds=discard_nonds, $
        samples=samples, lines=lines, format=format, swap_endian=swap_endian
        
    ENDFOR
  ENDIF
  
  ; I believe it is applicable to calculate the GAMMA value for each point
  ; using the re-filtered images.
  IF 0 THEN BEGIN
    inputfile=difffiles
    filterfile1=dspath+FILE_BASENAME(inputfile)+'.ds_filter'
    filterfile2=filterfile1+'.ds_filter'
    
    result=FLTARR(finfo.range_samples, finfo.azimuth_lines)
    gamma_slc=COMPLEXARR(finfo.range_samples, finfo.azimuth_lines)
    FOR i=0, ndiff-1 DO BEGIN
      Print, 'Calculating the GAMMA value for each DSC...', STRCOMPRESS(i),'/', STRCOMPRESS(ndiff-1)
      diff_origfile=filterfile1[i]
      diff_filterfile=filterfile2[i]
      diff_orig=TLI_READDATA(diff_origfile, samples=finfo.range_samples, format='fcomplex',/swap_endian)
      diff_filter=TLI_READDATA(diff_filterfile, samples=finfo.range_samples, format='fcomplex',/swap_endian)
      
      gamma_slc=gamma_slc+(diff_filter*CONJ(diff_orig))  ; See Ferretti et al. 2011.
      
    ENDFOR
    gamma_slc=gamma_slc/double(ndiff)
    gamma_abs=ABS(gamma_slc)
    
    ; Update gamma_abs
    dscmask=TLI_READDATA(dscmaskfile,samples=finfo.range_samples, format='byte')
    dsc_ind=WHERE(dscmask EQ 1, complement=nondsc_ind)
    gamma_abs[nondsc_ind]=0
    
    maxgamma=MAX(gamma_abs, min=mingamma)
    
    Print, mingamma, maxgamma
    TLI_WRITE, dsgammafile, gamma_abs
  ENDIF
  
  ;---------------------------------------------
  ; Write DS list.
  IF 0 THEN BEGIN
    gamma_abs=TLI_READDATA(dsgammafile, samples=finfo.range_samples, format='double')
    Print, 'Max gamma:'+STRCOMPRESS(MAX(gamma_abs))
    
    
    plist=TLI_READMYFILES(plistfile, type='plist')
    
    
    gamma_abs[REAL_PART(plist), IMAGINARY(plist)]=0
    
    
    ; Determin the gamma threshold using percent keyword.
    percent=4D
    gamma_sort=gamma_abs[WHERE(gamma_abs NE 0)]
    gamma_sort=gamma_sort[REVERSE(SORT(gamma_sort))]
    nds=N_ELEMENTS(gamma_sort)
    percent=double(percent)
    percent_pos=nds*percent/100D
    gamma_thresh=gamma_sort[percent_pos]
    Print, gamma_thresh
    STOP
    
    ds_ind=WHERE(gamma_abs GE gamma_thresh)
    Print, 'DS detected:', N_ELEMENTS(ds_ind)
    ds_coor=ARRAY_INDICES(gamma_abs, ds_ind)
    ds_x=ds_coor[0, *]
    ds_y=ds_coor[1, *]
    TLI_WRITE, dslistfile+'.gamma', ds_coor,/swap_endian
    TLI_WRITE, dslistfile+'.txt', [ds_x, finfo.azimuth_lines-1-ds_y],/txt
    TLI_WRITE, dslistfile, COMPLEX(ds_x, ds_y)
    
    cmd=dspath+'plot_ds.sh'
    cd, dspath
    SPAWN, cmd
  ENDIF
  ;--------------------------------------------------
  ; Extract the diff values for DSCs.
  IF 0 THEN BEGIN
    dslist=TLI_READMYFILES(dslistfile, type='plist')
    ds_x=REAL_PART(dslist)
    ds_y=IMAGINARY(dslist)
    OPENW, lun, dsdifffile, /GET_LUN
    FOR i=0, ndiff-1 DO BEGIN
      Print, 'Calculating the differential value for each DS...', STRCOMPRESS(i),'/', STRCOMPRESS(ndiff-1)
      diff_origimg=difffiles[i]
      
      diff_filterimg=dspath+FILE_BASENAME(diff_origimg)+'.ds_filter'
      
      diff_filter=TLI_READDATA(diff_filterimg, samples=finfo.range_samples, format='fcomplex',/swap_endian)
      dsdiff=diff_filter[ds_x, ds_y]
      WRITEU, lun, dsdiff
    ENDFOR
    
    FREE_LUN, lun
  ENDIF
  
  ;--------------------------------------------------
  ; Merge the two plist and pdiff file
  IF 0 THEN BEGIN
    workpath=workpath
    pslistfile=workpath+'plist_adi025'
    psdifffile=workpath+'pdiff0_adi025'
    
    dslistfile=dspath+'dslist'
    dsdifffile=dspath+'ds.diff'
    
    nps=TLI_PNUMBER(pslistfile)
    nds=TLI_PNUMBER(dslistfile)
    
    plistfile_merge=dspath+'ps_dslist'
    pdifffile_merge=plistfile_merge+'.pdiff0'
    ; Process the plist files
    FILE_COPY, pslistfile, plistfile_merge,/overwrite
    dslist=TLI_READMYFILES(dslistfile, type='plist')
    TLI_WRITE, plistfile_merge, dslist,/APPEND
    
    TLI_GAMMA2MYFORMAT_PLIST, plistfile_merge, plistfile_merge+'_gamma',/reverse 
    
    ; Process the diff files
    psdiff=TLI_READDATA(psdifffile, samples=nps, format='fcomplex',/swap_endian)
    dsdiff=TLI_READDATA(dsdifffile, samples=nds, format='fcomplex')
    pdiff=[psdiff, dsdiff]
    TLI_WRITE, pdifffile_merge, pdiff,/swap_endian
  ENDIF
  
  ; Call HPA to calculate the deformation rate map.
  mask_arc=0.8
  mask_pt_coh=0.8
  v_acc=3
  dh_acc=10
  pbase_thresh=100
  coh=0.6
  hpapath=workpath+'HPA/'
;  TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc,/ls,$
;    method='ls', coh=coh, pbase_thresh=pbase_thresh
  outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
  tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',cpt='tli_def',/show,/refine,ptsize=0.01,/minus,/no_clean
  
END