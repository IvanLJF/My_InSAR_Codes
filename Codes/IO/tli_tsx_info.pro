;
; Get basic information from xml file name.
;
; Parameters:
;   xmlfile    : XML file.
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150107
;
FUNCTION TLI_TSX_INFO, xmlfile
  COMPILE_OPT idl2
  inputfile=xmlfile
  inputfile=FILE_BASENAME(inputfile)
  IF STRLEN(inputfile) NE 63 THEN Message, 'Error! TLI_TSX_INFO: Please provide TSX XML file.'
  ; More information can be found in 'Level 1b product format specification, DLR'
  mission=(STRMID(inputfile, 0,4))[0] ;5   ; TSX1
  sensor=(STRMID(inputfile, 5, 4))[0] ;10  ; SAR_
  class=(STRMID(inputfile, 10, 3))[0] ;13 ; SSC, MGC, GEC, EEC
  sub_class=(STRMID(inputfile, 13, 4))[0]; 17 ; SE__, RE__
  mode=(STRMID(inputfile, 19, 2))[0]; 19, SM, SC, SL, HS
  pol=(STRMID(inputfile, 22, 1))[0];   20  ; S,D,T,Q
  receive=(STRMID(inputfile, 24, 3))[0]; 23; SRA, DRA
  start_time=(STRMID(inputfile, 28, 15))[0]; 38; UTC Start time
  end_time=(STRMID(inputfile, 44, 15))[0]  ; UTC end time
  
  xmlinfo=CREATE_STRUCT('mission', mission, $
                        'sensor', sensor, $
                        'class', class,$
                        'sub_class', sub_class,$
                        'mode', mode,$
                        'pol', pol,$
                        'receive', receive,$
                        'start_time', start_time,$
                        'end_time', end_time) 
  RETURN, xmlinfo
END