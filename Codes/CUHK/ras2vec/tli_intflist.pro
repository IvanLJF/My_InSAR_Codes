PRO TLI_INTFLIST, sarlistfile, itabfile, interflistfile= interflistfile
  
  COMPILE_OPT idl2
  IF ~KEYWORD_SET(interflistfile) THEN BEGIN
    path= FILE_DIRNAME(itabfile)
    interflistfile= path+PATH_SEP()+'Interf.list'
  ENDIF
  
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(1, nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  nintf= FILE_LINES(itabfile)
  itab= LONARR(4, nintf)
  OPENR,lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  itab=itab[[2,0,1,3], *]
  
  OPENW, lun, interflistfile,/GET_LUN
  PrintF, lun, 'number of files = ', STRCOMPRESS(nslc)
  PrintF, lun, sarlist
  PrintF, lun, ''
  PrintF, lun, 'number of interferograms = ', STRCOMPRESS(nintf)
  PrintF, lun, STRCOMPRESS(itab)
  Free_lun, lun
  
  Print, 'Interferometric table is written successfully.'  
  

END