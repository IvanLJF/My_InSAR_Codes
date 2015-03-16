PRO TLI_TEST_RES_DECOMP

  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/testforCUHK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
    pdifffile= workpath+'/pdiff0'
    plistfilegamma= workpath+'/pt'
    plistfile= workpath+'/testforCUHK/plist'
    itabfile= workpath+'/itab'
    arcsfile=workpath+'/testforCUHK/arcs'
    pbasefile=workpath+'/pbase'
    dvddhfile=workpath+'/testforCUHK/dvddh'
    vdhfile= workpath+'/testforCUHK/vdh'
    ptattrfile= workpath+'/testforCUHK/ptattr'
    arcs_resfile= workpath+'/testforCUHK/arcs_res' ; output file
    res_phasefile= workpath+'/testforCUHK/res_phase'; output file
    time_series_linearfile= workpath+'/testforCUHK/time_series_linear'; output file
    res_phase_slfile= workpath+'/testforCUHK/res_phase_sl' ; output file
    res_phase_tlfile= workpath+'/testforCUHK/res_phase_tl' ; output file
    final_resultfile= workpath+'/testforCUHK/final_result'
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    outfile=TLI_DIRW2L(outfile,/reverse)
  ENDELSE
  
  ;  refind=17170 ; Reference point's index for TSX_PS_HK. A test area near MongKok.
;  refind=2244; Reference point's index set for TSX_PS_Tianjin20120925
  ;  refind=62186; Reference point's index for TSX_PS_Tianjin
  ;  refind=35702; Reference point's index for TSX_PS_Tianjin
  ;  refind=127700; Reference point's index for TSX_PS_Tianjin
   refind=81065 ; Reference point's index for Kowloon
  aps= 2.04 ; Azimuth pixel spacing
  rps= 0.9 ; Range pixel spacing
  winsize= 1000 ; Window size.
  
  
  low_f=0.2  ; Low frequency for filtering
  high_f=0.25; High frequency for filtering
  
  lamda=0.031 ; Wavelength of TerraSAR-X, 3.1cm
  
  IF 1 THEN BEGIN
    ;---------------------------------------------------------
    Print, 'Retriving connectivities...'
    TLI_RETR_ARCS, plistfile, ptattrfile, refind, arcs_resfile=arcs_resfile
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
    
  ENDIF
  ;----------------------------------------------------------
  Print, 'Sort out the results'
  Print, 'The results are organized as follows: index, x, y, time_series'
  TLI_SORTOUT_FINAL, plistfile, time_series_linearfile, res_phase_tlfile,lamda, final_resultfile= final_resultfile
  
  Print, 'Phase residuals are decomposed.'
  
END