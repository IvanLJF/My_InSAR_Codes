;
; Automatically rename the input file(s) by using the imaging date (YYYYMMDD).
;
; Parameters:
;   dir   : Directory containing all the files.
; 
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20140912
;
@tli_load_slc_par
PRO TLI_GAMMA_AUTORENAME, inputfile
  ; Get the imaging date.
  fpar=inputfile+'.par'
  IF NOT FILE_TEST(fpar) THEN BEGIN
    Message, 'Error! Par file is not found:'+STRING(13b)+fpar
    Return
  ENDIF ELSE BEGIN
    workpath=FILE_DIRNAME(inputfile)+PATH_SEP()
    finfo=TLI_LOAD_SLC_PAR(fpar)
    date=finfo.date
    date=STRCOMPRESS(date,/REMOVE_ALL)
    date=STRMID(date, 0, 8)
    fname=date+'.slc'
    goon=1
    outputfile=workpath+fname
    i=1
    WHILE goon DO BEGIN
      IF outputfile EQ inputfile THEN BEGIN
        Break
      ENDIF
      IF NOT FILE_TEST(outputfile) THEN BEGIN
        FILE_MOVE, inputfile, outputfile
        FILE_MOVE, inputfile+'.par', outputfile+'.par'
        Print, 'File was converted: ', inputfile+'(.par)',' -> ', outputfile+'(.par)'
        goon=0
      ENDIF ELSE BEGIN
        outputfile=workpath+date+'_'+STRCOMPRESS(i,/REMOVE_ALL)+'.slc'
        i=i+1
      ENDELSE    
    ENDWHILE    
  ENDELSE
  
END

PRO TLI_GAMMA_AUTORENAME_ALL

  dir='/mnt/data_tli/Data/SLCs/TSX_HK_SLC/slc_GAMMA'
;  dir='/mnt/software/ForExperiment/selectpt_cc/slc'
  
  dir=dir+PATH_SEP()
  files=FILE_SEARCH(dir+'*.slc',count=nfiles)
  FOR i=0, nfiles-1 DO BEGIN
    TLI_GAMMA_AUTORENAME, files[i]
  
  ENDFOR
  Print, 'The mission has been accomplished.'
END