@slc__define
@tli_crosscorrelate
FUNCTION TLI_OFFSETS_PART, array1, array2,win_r=win_r, win_azi=win_azi, ovsfactor=ovsfactor, $
    multilook_r=multilook_r, multilook_azi=multilook_azi, logfile=logfile
    
  ; Calculate the offsets for the input data sets.
  ;- Input params:
  ;-   Array1   : The input master partial data.
  ;-   Array2   : The input slave partial data.
  ;-
  ;- Input Keywords:
  ;-   win_r    : Window size in range direction.
  ;-   win_azi  : Window size in azimuth direction.
  ;-   ovsfactor: Over sampling factor.
  ;-   multilook_r: Multi look factor in range direction.
  ;-   multilook_azi: Multi look factor in azimuth direction.
  ;-
  ;- Output results:
  ;-   Three bands: offsets in range direction, offsets in azimuth direction, and coherence.
  ;-
  ;- Written by:
  ;-   T. LI @ ISEIS, 20131115
    
  mslc=array1
  sslc=array2
  
  IF NOT KEYWORD_SET(win_r) THEN win_r=32
  IF NOT KEYWORD_SET(win_azi) THEN win_azi=32
  IF NOT KEYWORD_SET(ovsfactor) THEN ovsfactor=8
  IF NOT KEYWORD_SET(multilook_r) THEN multilook_r=1
  IF NOT KEYWORD_SET(multilook_azi) THEN multilook_azi=1
  
  sz=SIZE(mslc,/DIMENSIONS)
  result=FLTARR(sz[0],sz[1], 3)   ; Three bands, range offsets, azimuth offsets, coh.
  
  ; Calculate the offset values for the input data.
  win_r_new=win_r*multilook_r
  win_azi_new=win_azi*multilook_azi
  border_r=CEIL(win_r_new/2D)
  border_azi=CEIL(win_azi_new/2D)
  
  samples=sz[0]
  lines=sz[1]
  all_pix=(samples-2*border_r)*(lines-2*border_azi)
  count=0.0
  FOR i=border_r, (samples-border_r) DO BEGIN
    Print, i
    start_r=i-border_r
    end_r=start_r+win_r_new-1
    FOR j=border_azi, (lines-border_azi) DO BEGIN
      IF NOT (count MOD 1000) THEN Print, STRCOMPRESS(count),'/', STRCOMPRESS(all_pix)
      
      count=count+1
      start_azi=j-border_azi
      end_azi=start_azi+win_azi_new-1
      m_tile=mslc[start_r:end_r, start_azi:end_azi]
      s_tile=sslc[start_r:end_r, start_azi:end_azi]
      
      IF multilook_r+multilook_azi GT 2 THEN BEGIN
        EXPAND, m_tile, win_r, win_azi, m_tile
        EXPAND, s_tile, win_r, win_azi, s_tile
      ENDIF
      
      search_win_r=2
      search_win_azi=2
      ;      offsets=TLI_CROSSCORRELATE(m_tile, s_tile, search_win_r, search_win_azi,ovsfactor=ovsfactor)
      ls_poly=0
      gauss=0
      offsets=TLI_CROSSCORRELATE(m_tile, s_tile, search_win_r, search_win_azi,ovsfactor=ovsfactor, ls_poly=ls_poly, gauss=gauss)
      IF offsets[0] LT 0.5 OR offsets[1] LT 0.5 OR offsets[2] LT 0.9 THEN BEGIN
        TLI_LOG, logfile, STRING(i)+STRING(j)
        TLI_LOG, logfile, STRJOIN(STRING(offsets))
        
      ENDIF
      result[i, j, *]=offsets
    ENDFOR
  ENDFOR
  RETURN, result
END

PRO TLI_OFFSET_TRACKING



  IF 0 THEN BEGIN  ; Test the algorithm using data provided by LI Gang.
    ; The input params
    workpath='/mnt/backup/ExpGroup/ASAR_offset_tracking/Offset_tracking'
    IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
    mfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc/20080713.rslc'
    mpar=mfile+'.par'
    ;  sfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc/20080713.rslc'
    sfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc/20050724.rslc'
    spar=sfile+'.par'
    
    outputfile_base=workpath+TLI_GAMMA_FNAME(sfile,/date)+'-'+TLI_GAMMA_FNAME(mfile,/date)
    outputfile_offs=outputfile_base+'.offsets'
    outputfile_r=outputfile_base+'_r.offsets'
    outputfile_azi=outputfile_base+'_azi.offsets'
    outputfile_coh=outputfile_base+'_offsets.coh'
    
    logfile=outputfile_base+'.log'
    win_r=64
    win_azi=64
    ovsfactor=2
    ;  range=[0,4200,44700,15000]  ; [roff, nr, loff, nl] Here locats an iceberg.
    range=[0, 4200, 44700, 4200]
    multilook_r=1
    multilook_azi=5
  END
  
  IF 0 THEN BEGIN  ; Test the algorithm using multi-looked pwr data generated from LI Gang's rslc images.
  
    ; The input params
    workpath='/mnt/backup/ExpGroup/ASAR_offset_tracking/Offset_tracking_ml'
    IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
    mfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc_multi_look/20050724.pwr'
    mpar=mfile+'.par'
    ;  sfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc/20080713.rslc'
    sfile='/mnt/backup/ExpGroup/ASAR_offset_tracking/rslc_multi_look/20080713.pwr'
    ;    sfile=mfile
    
    spar=sfile+'.par'
    
    outputfile_base=workpath+TLI_GAMMA_FNAME(sfile,/date)+'-'+TLI_GAMMA_FNAME(mfile,/date)
    outputfile_offs=outputfile_base+'.offsets'
    outputfile_r=outputfile_base+'_r.offsets'
    outputfile_azi=outputfile_base+'_azi.offsets'
    outputfile_coh=outputfile_base+'_offsets.coh'
    
    logfile=outputfile_base+'.log'
    win_r=64
    win_azi=64
    ovsfactor=32
    ;  range=[0,4200,44700,15000]  ; [roff, nr, loff, nl] Here locats an iceberg.
    range=[0, 4200, 0, 3000]
    multilook_r=1
    multilook_azi=1
    
    
  ENDIF
  
  
  
  IF 1 THEN BEGIN  ;Test the algorithm using the TSX data.
    ; The input params
    workpath='/mnt/backup/ExpGroup/TSX_offset_tracking'
    IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
    mfile='/mnt/backup/ExpGroup/TSX_offset_tracking/images/20090327.rslc'
    mpar=mfile+'.par'
    sfile='/mnt/backup/ExpGroup/TSX_offset_tracking/images/20090328.rslc'
    ;    sfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/piece/20090327.rslc'
    spar=sfile+'.par'
    
    outputfile_base=workpath+TLI_GAMMA_FNAME(sfile,/date)+'-'+TLI_GAMMA_FNAME(mfile,/date)
    outputfile_offs=outputfile_base+'.offsets'
    outputfile_r=outputfile_base+'_r.offsets'
    outputfile_azi=outputfile_base+'_azi.offsets'
    outputfile_coh=outputfile_base+'_offsets.coh'
    
    logfile=outputfile_base+'.log'
    win_r=64
    win_azi=64
    ovsfactor=16
    ;  range=[0,4200,44700,15000]  ; [roff, nr, loff, nl] Here locats an iceberg.
    range=[0, 500, 0, 500]
    multilook_r=1
    multilook_azi=1
  END
  
  
  ; Trying to deal with large input data.
  ; We suppose that the two SLCs have already been co-registered.
  ;-------------------------------------------------------------------------
  ; Load the two images
  mslc=OBJ_NEW('SLC')
  mslc->SET, mfile
  mfinfo=mslc->GET()
  
  sslc=OBJ_NEW('SLC')
  sslc->SET, sfile
  sfinfo=sslc->GET()
  
  ;-------------------------------------------------------------------------
  ; If range is set, process the subset of the image.
  ; Read the data
  IF KEYWORD_SET(range) THEN BEGIN
    TLI_LOG, logfile, 'Offset Tracking. Task started at:'+TLI_TIME(/str)
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Parameters for offset tracking:'
    TLI_LOG, logfile, 'Input master file:'+mfile
    TLI_LOG, logfile, 'Input slave file:'+sfile
    TLI_LOG, logfile, 'Image part to process:'+STRJOIN(STRCOMPRESS(range), ' -')
    TLI_LOG, logfile, 'Window size in range direction:'+STRCOMPRESS(win_r)
    TLI_LOG, logfile, 'Window size in azimuth direction:'+STRCOMPRESS(win_azi)
    TLI_LOG, logfile, 'Oversampling factor:'+STRCOMPRESS(ovsfactor)
    TLI_LOG, logfile, ''
    
    roff=range[0]
    nr=range[1]
    loff=range[2]
    nl=range[3]
    mdata=mslc->READ( roff=roff, nr=nr, loff=loff, nl=nl)
    sdata=sslc->READ( roff=roff, nr=nr, loff=loff, nl=nl)
    
    ; For validation purpose, add some offsets to sdata. All errors are given in their orders.
    ; Add [0, 1].
    ;    sdata=SHIFT(sdata, 0, 1)  ; Error = [0.0001, 0.01]
    ; Add [1, 1]
    ;        sdata=SHIFT(sdata, 1, 1)  ; Error = [0.01, 0.01]
    ; The maximum offsets can be detected: winsize/2
    ; Add [20, 20]
    ;        sdata=SHIFT(sdata, 20,20) ; Error=[0.1, 0.1]
    ; It seems to maintain the relationship as: error=offset/100
    
    ;-------------------------------------------------------------------------
    ;Calculate the offsets for the input pieces of data
    
    result=TLI_OFFSETS_PART( mdata, sdata,win_r=win_r, win_azi=win_azi, ovsfactor=ovsfactor, $
      multilook_r=multilook_r, multilook_azi=multilook_azi, logfile=logfile)
      
    TLI_WRITE, outputfile_offs, ABS(COMPLEX(result[*,*,0], result[*,*,1])) ; Offsets.
    TLI_WRITE, outputfile_r, result[*,*,0]   ; Offsets in range direction
    TLI_WRITE, outputfile_azi, result[*,*,1] ; Offsets in azi direction
    TLI_WRITE, outputfile_coh, result[*,*,2] ; Coherece
    
  ENDIF ELSE BEGIN
  
  
  ENDELSE
  
  
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Offset tracking. Task ended at:'+TLI_TIME(/str)
  TLI_LOG, logfile, ''
  
  
  
  OBJ_DESTROY, mslc
  OBJ_DESTROY, sslc
  
  
  
  
END