;
; Update itab file using the given mask array.
;
; Parameters:
;   inputfile  : Itab file to modify.
;
; Keywords:
;   mask       : Mask array to use.
;   outputfile : Output itab file, if not specified, the original file will be re-written.
;
; Written by:
;   T.LI @ SWJTU
;
PRO TLI_UPDATE_PDIFF, inputfile, plistfile, itabfile, mask=mask, outputfile=outputfile

  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+'_update'
  
  npt=TLI_PNUMBER(plistfile)
  itab=TLI_READMYFILES(itabfile, type='itab')
  
  IF NOT KEYWORD_SET(mask) THEN mask=itab.mask
  
  pdiff=TLI_READDATA(inputfile, samples=npt, format='FCOMPLEX',/swap_endian)
  
  sz=SIZE(pdiff,/DIMENSIONS)
  nintf_pdiff=sz[1]
  
  IF nintf_pdiff EQ itab.nintf THEN BEGIN
    pdiff=pdiff[*, WHERE(mask EQ 1)]
  ENDIF ELSE BEGIN
    IF nintf_pdiff NE itab.nintf_valid THEN BEGIN
      Message, 'Error! Number of records in pdiff file is not consistent with that in itab file.'
    ENDIF
  ENDELSE
  
  TLI_WRITE, outputfile, pdiff,/swap_endian
  
END