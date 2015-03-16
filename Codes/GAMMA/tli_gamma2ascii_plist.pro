  
PRO TLI_GAMMA2ASCII_PLIST, plistfilegamma, outfile= outfile
  IF N_PARAMS() NE 1 THEN Message, 'TLI_GAMMA3MYFORMAT_PLIST: Usage Error!'
  
  IF ~KEYWORD_SET(outfile) THEN BEGIN
    outfile= plistfilegamma+'.txt'
  ENDIF
  
  ;Read Plist
  npt= TLI_PNUMBER(plistfilegamma)
  Print, 'Points number:', npt
  plist= LONARR(2,npt)
  OPENR, lun, plistfilegamma,/GET_LUN,/SWAP_ENDIAN
  READU, lun, plist
  FREE_LUN, lun
  ; Write Plist
  ind= FINDGEN(npt)
  result=[TRANSPOSE(ind), plist]
  OPENW, lun, outfile,/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun

END