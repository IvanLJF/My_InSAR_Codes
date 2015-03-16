PRO TLI_SIM_TXT, ptfile,sarlistfile, itabfile,pdatafile, outpath=outpath,format=format, swap_endian=swap_endian
  
  COMPILE_OPT idl2
  
  ; Check input
  IF ~KEYWORD_SET(outpath) THEN BEGIN
    filedir= FILE_DIRNAME(pdatafile)
    outpath= filedir+PATH_SEP()+'pdatatxt'
  ENDIF
  
  IF ~KEYWORD_SET(format) THEN BEGIN
    format='FCOMPLEX'
  ENDIF
  
  ; Create file dir
  IF FILE_TEST(outpath,/DIRECTORY) THEN BEGIN
    FILE_DELETE, outpath,/RECURSIVE
  ENDIF
  FILE_MKDIR, outpath
  ; Get interferometric pairs
  intf=TLI_GAMMA_INT(sarlistfile, itabfile,/date)
  ; Read pdata
  nintf= FILE_LINES(itabfile)
  pdata=TLI_READDATA(pdatafile, lines=nintf, format=format,/swap_endian)
  pdata= ATAN(pdata,/PHASE)
  
  ; Read plist
  plist= TLI_READDATA(ptfile, samples=2, format='LONG',/SWAP_ENDIAN)
  ; Write files
  FOR i=0, nintf-1 DO BEGIN
    fname= STRCOMPRESS(intf[0,i],/REMOVE_ALL)+'-'+STRCOMPRESS(intf[1,i],/REMOVE_ALL)
    fname= outpath+PATH_SEP()+fname+'.txt'
    result= [plist, TRANSPOSE(pdata[*, i])]
    OPENW, lun, fname,/GET_LUN
    PRINTF, lun, result
    FREE_LUN, lun
  ENDFOR
  
END