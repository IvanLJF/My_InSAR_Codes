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
PRO TLI_UPDATE_ITAB, inputfile, mask=mask, outputfile=outputfile
  
  COMPILE_OPT idl2
  
  itab=TLI_READTXT(inputfile,/easy)
  itab=LONG(itab)
  
  sz=SIZE(itab,/DIMENSIONS)
  nintf=sz[1]
  
  nintf_mask=N_ELEMENTS(mask)
  IF nintf_mask NE nintf THEN Message, 'Error! Dimensions are not consistent, please check the mask array.'
  
  itab[3,*]=mask
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile
  
  temp='('+STRJOIN(REPLICATE('A4', 4), ',')+')'
  TLI_WRITE, outputfile, itab,format=temp, /TXT

END