;
; Find all the procedures used in the main pro.
;
PRO TLI_RESOLVE_ALL
  
  origpath='/mnt/software/ISEIS'
  
  workpath='/mnt/backup/ExpGroup/Offset_tracking_codes'
  
  codelistfile=origpath+PATH_SEP()+'offset_tracking_codes'
  logfile=codelistfile+'.log'
  
  npros=FILE_LINES(codelistfile)
  codelist=STRARR(1, npros)
  OPENR, lun, codelistfile,/GET_LUN
  READF, lun, codelist
  FREE_LUN, lun
  
  TLI_LOG, logfile, 'Searching for all the procedures in the list file:'
  TLI_LOG, logfile, codelistfile
  
  FOR i=0, npros-1 DO BEGIN
    
    fname=codelist[i]+'.pro'
    
    result=FILE_SEARCH(origpath, fname, count=count)
    IF count EQ 0 THEN BEGIN
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'File not found:'+fname,/prt
    ENDIF ELSE BEGIN
      TLI_LOG, logfile, ''
      TLI_LOG, logfile, 'File source name:'+fname,/prt
      TLI_LOG, logfile, 'File destination:'+result
      
      FILE_COPY, result, workpath,/overwrite
    ENDELSE
    
  
  ENDFOR
   
  
  

END