;
; Output info to logfile.
; Parameters:
;   logfile   : Output file.
;   info      : Information to print.
; Keywords:
;   prt       : Set this keyword to print messages in the command line.
; Written by:
;   T.LI @ ISEIS
;   Add the keyword prt, 20140106
;

PRO TLI_LOG, logfile, info, prt=prt
  COMPILE_OPT idl2
  
  finfo=FILE_INFO(logfile)
  mtime=finfo.mtime
  thistime=SYSTIME(/SECONDS)
  dt=thistime-mtime
  
  IF keyword_set(prt) THEN Print, info
  
  IF NOT FILE_TEST(logfile) THEN BEGIN
    OPENW, lun, logfile,/GET_LUN
  ENDIF ELSE BEGIN
    OPENW, lun, logfile,/GET_LUN,/APPEND
  ENDELSE
  IF dt GE 60 THEN BEGIN
    PRINTF, lun, '******************************************************'
    PRINTF, lun, '**************'+TLI_TIME(/str)+'*****************'
    PRINTF, lun, '******************************************************'
  ENDIF
  
  PRINTF, lun, info
  FREE_LUN,lun
END