
PRO TLI_GAMMA2MYFORMAT_PLIST, plistfilegamma, outfile, reverse=reverse
  
  COMPILE_OPT idl2
  ON_ERROR, 2
  
  IF N_PARAMS() NE 2 THEN Message, 'TLI_GAMMA3MYFORMAT_PLIST: Usage Error!'
  IF NOT KEYWORD_SET(reverse) THEN BEGIN
    ;Read Plist
    npt= TLI_PNUMBER(plistfilegamma)
    Print, 'Points number:', npt
    plist= LONARR(2,npt)
    OPENR, lun, plistfilegamma,/GET_LUN,/SWAP_ENDIAN
    READU, lun, plist
    FREE_LUN, lun
    ; Write Plist
    plist= COMPLEX(plist[0, *], plist[1, *])
    OPENW, lun, outfile,/GET_LUN
    WRITEU, lun, plist
    FREE_LUN, lun
  ENDIF ELSE BEGIN
    ; Read plist
    npt=TLI_PNUMBER(plistfilegamma)
    plist=TLI_READDATA(plistfilegamma, samples=1, format='FCOMPLEX')
    ; Write plist
    plist= [LONG(REAL_PART(plist)), LONG(IMAGINARY(plist))]
    OPENW, lun, outfile,/GET_LUN,/SWAP_ENDIAN
    WRITEU, lun, plist
    FREE_LUN, lun
  ENDELSE
  
END