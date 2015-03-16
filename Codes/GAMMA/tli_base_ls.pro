;
;  Modify basefile by copying the initial baseline as precision baseline.
;
;  Params:
;    inputfile  : Basefile created by GAMMA software.
;  
;  Keywords:
;    outputfile : Output file name. Using inputfile if not specified.
;
;  Written by:
;    T.LI @ Sasmac, 20141031
;
PRO TLI_BASE_LS,inputfile, outputfile=outputfile
  
  IF NOT FILE_TEST(inputfile) THEN BEGIN
    Message, 'Error! Input file not exist:'+basefile
  ENDIF
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=inputfile
  ENDIF
  
  base=TLI_READTXT( inputfile,/txt)
  
  base=TLI_STRSPLIT(base, pattern=':')
  
  base[1, 2:3]=base[1, 0:1]
  
  OPENW, lun, outputfile,/GET_LUN
  
  FOR i=0,5 DO BEGIN
    IF i NE 5 THEN BEGIN
      PrintF, lun, base[0, i]+':'+base[1, i]
    ENDIF ELSE BEGIN
      PrintF, lun, ''
    ENDELSE
  ENDFOR
  
  FREE_LUN, lun
  
END