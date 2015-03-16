;
; Select identical points from two plist files.
; 
; Params:
;   plistfile1   : The point list file 1. Format: fcomplex, 1 sample.
;   plistfile2   : The point list file 2.
; 
; Written by:
;   T.LI @ SWJTU, 20140331.
;
PRO TLI_IDENTITAL_POINTS, plistfile1, plistfile2,outputfile=outputfile
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=FILE_BASENAME(plistfile1)+FILE_BASENAME(plistfile2)+'_identical'
  ENDIF
  
  ; Compare the two plist files.
  TLI_COMPARE_PLIST, plistfile1, plistfile2, plistcommonfile=outputfile
  
END