;
; Analyze the phase correlated point.
;
PRO TLI_ANALYZE_PCP

  ;-------------------------------------
  ; Define the input files.
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Airport'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'PCP'+PATH_SEP()
  
  plistfile=workpath+'pt'
  pdifffile=workpath+'pdiff0'
  itabfile=workpath+'itab'
  sarlistfile=workpath+'SLC_tab'
  
  file_sea=resultpath+'sea.corr'
  file_runway=resultpath+'runway.corr'
  file_bare=resultpath+'bare.corr'
  file_build=resultpath+'build.corr'
  file_hill=resultpath+'hill.corr'
  logfile=resultpath+'log.txt'
  
  ;----------------------------------------
  ; Define some parameters.
  pt_no=30
  npt_cls=pt_no^2
  corr_thresh=0.9
  
  ;-----------------------------------------
  ; Simulate the plist file.
  IF 0 THEN BEGIN
    pt_sea= INDEXARR(x=2100+FINDGEN(pt_no), y=1100+FINDGEN(pt_no)) & pt_sea=REFORM(pt_sea, pt_no^2)
    pt_runway= INDEXARR(x=1907+FINDGEN(pt_no), y=1538+FINDGEN(pt_no)) & pt_runway=REFORM(pt_runway, pt_no^2)
    pt_bare=INDEXARR(x=1938+FINDGEN(pt_no), y=2483+FINDGEN(pt_no)) & pt_bare=REFORM(pt_bare, pt_no^2)
    pt_build=INDEXARR(x=1336+FINDGEN(pt_no), y=3872+FINDGEN(pt_no)) & pt_build=REFORM(pt_build, pt_no^2)
    pt_hill=INDEXARR(x=1400+FINDGEN(pt_no), y=4744+FINDGEN(pt_no)) & pt_hill=REFORM(pt_sea, pt_no^2)
    
    pt_all=[pt_sea, pt_runway, pt_bare, pt_build, pt_hill]
    pt_all=REFORM(pt_all, N_ELEMENTS(pt_all))
    TLI_WRITE,plistfile, pt_all
    TLI_GAMMA2MYFORMAT_PLIST, plistfile,plistfile,/REVERSE
  ENDIF
  ;---------------------------------------------
  ; Extract the differential phase and correlation matrix.
  IF 0 THEN BEGIN
    npt=TLI_PNUMBER(plistfile)
    plist=TLI_READDATA(plistfile, samples=2, format='LONG',/swap_endian)
    pdiff=TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',/swap_endian)
    diffphi=ATAN(pdiff,/PHASE)
    ; Calculate the correlation matrix.
    FOR i=0D, 4D DO BEGIN
      Print, i
      temp=diffphi[npt_cls*i: npt_cls*(i+1)-1, *]
      result=TLI_CORRELATION_MATRIX(temp)
      
      Case i OF
        0: outfile=file_sea
        1: outfile=file_runway
        2: outfile=file_bare
        3: outfile=file_build
        4: outfile=file_hill
      ENDCASE
      TLI_WRITE,outfile, result
      result=TLI_STRETCH_DATA(result, [0, 255])
      Write_Image, outfile+'.bmp', 'BMP', result
    ENDFOR
  ENDIF
  ;--------------------------------------------
  ; Analyze the correlation matrix by thresholding.
  IF 0 THEN BEGIN
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Analyze the correlation matrix by thresholding.'
    TLI_LOG, logfile, 'Task started at:'+TLI_TIME(/str)
    FOR i=0D, 4D DO BEGIN
      Print, i
      
      Case i OF
        0: inputfile=file_sea
        1: inputfile=file_runway
        2: inputfile=file_bare
        3: inputfile=file_build
        4: inputfile=file_hill
      ENDCASE
      result=TLI_READDATA(inputfile, samples=npt_cls, format='FLOAT')
      ; Thresholding
      result[WHERE(result LT corr_thresh,n_lt_thresh, complement=temp)]=0
      result[temp]=1
      
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'Threshold:'+STRING(corr_thresh)
      TLI_LOG, logfile, 'Point pairs up the threshold:'+STRING((npt_cls^2D -n_lt_thresh)/2)
      TLI_LOG, logfile, 'Point pairs below the threshold:'+STRING((n_lt_thresh)/2)
      TLI_LOG, logfile, 'Available no. from the first point-pairs:'+STRING((npt_cls^2D -n_lt_thresh-pt_no^2)/2)
      TLI_LOG, logfile, 'Input file:'+inputfile
      result=TLI_STRETCH_DATA(result, [0, 255])
      Write_IMAGE, inputfile+'.thr.bmp', 'BMP', result
      
    ENDFOR
    
    TLI_LOG, logfile, 'Task ended at:'+TLI_TIME(/str)
  ENDIF
  
  ;-------------------------------------------------------------
  ; Analyze the points with ADI < 0.25
  IF 0 THEN BEGIN
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Analyze the points with ADI < 0.25'
    TLI_LOG, logfile, 'Task started at:'+TLI_TIME(/str)
    
    plistfile=workpath+'pt'
    pdifffile=workpath+'pdiff0'
    outfile=workpath+'corr_matrix_adi_lt_025'
    
    npt=TLI_PNUMBER(plistfile)
    pdiff=TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',/swap_endian)
    phi=ATAN(pdiff,/PHASE)
    result=TLI_CORRELATION_MATRIX(phi)
    TLI_WRITE, outfile, result
    result=TLI_STRETCH_DATA(result,[0,255])
    Write_image, outfile+'.bmp','BMP', result
    
    TLI_LOG, logfile, 'outputfile:'+outfile
    TLI_LOG, logfile, 'Task ended at:'+TLI_TIME(/str)
  ENDIF
  
  ;--------------------------------------------------
  ; Analyze the correlation matrix.
  plistfile=workpath+'pt'
  inputfile=workpath+'corr_matrix_adi_lt_025'
  
  npt=TLI_PNUMBER(plistfile)
  corr=TLI_READDATA(inputfile,samples=npt, format='float')
  
  corr_thresh=0.75
  corr[WHERE(corr LT corr_thresh, complement=comp)]=0
  corr[comp]=1
  corr=TLI_STRETCH_DATA(corr, [0,255])
  Write_image, inputfile+'_thr.bmp','bmp', corr
  
  DEVICE, DECOMPOSED=0
  LOADCT, 13
  
  WINDOW, xsize=npt/2, ysize=npt/2
  temp=CONGRID(corr, npt/2, npt/2)
  TVSCL, temp
  
END