;-
;- Purpose:
;-     Change GAMMA's format to CUHK's inner format (time series).
;-     If you want to do the reverse change, please add keyword: /reverse 
PRO TLI_GAMMA2MYFORMAT_TS
  
  ; Input files
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
    pdifffile= workpath+'/pdiff0'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= workpath+'/testforCUHK/plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=workpath+'/testforCUHK/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=workpath+'/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    dvddhfile=workpath+'/testforCUHK/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= workpath+'/testforCUHK/vdh'
    atmfile= workpath+'/testforCUHK/atm'
    nonfile= workpath+'/testforCUHK/nonlinear'
    noisefile= workpath+'/testforCUHK/noise'
    time_seriesfile= workpath+'/testforCUHK/time_series'
    pt_gammafile= workpath+'/testforCUHK/pt_gamma'
    pt_maskfile= workpath+'/testforCUHK/pt_mask'
    pt_valfile= workpath+'/testforCUHK/pt_ts'
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    dvddhfile=TLI_DIRW2L(dvddhfile,/REVERSE)
    vdhfile=TLI_DIRW2L(vdhfile,/REVERSE)
  ENDELSE
  
  ; Read tsfile
  ;itab+3 means there is  x line,  y line,and a mask line.
  npt= TLI_PNUMBER(plistfile)
  ptts= TLI_READDATA(time_seriesfile, samples=npt, FORMAT='DOUBLE')
  
  pt_gamma= TRANSPOSE(LONG(ptts[*, 0:1]))
  pt_mask= BYTE(ptts[*, 2])
  pt_val= ptts[*, 3:*]
  
  OPENW, lun, pt_gammafile,/GET_LUN,/SWAP_ENDIAN
  WRITEU, lun, pt_gamma
  FREE_LUN, lun
  
  OPENW, lun, pt_maskfile,/GET_LUN,/SWAP_ENDIAN
  WRITEU, lun, pt_mask
  FREE_LUN, lun
  
  OPENW, lun, pt_valfile, /GET_LUN, /SWAP_ENDIAN
  WRITEU, lun, pt_val
  FREE_LUN, lun
  
  Print, 'Files written successfully.'
  
  STOP
  
  



END