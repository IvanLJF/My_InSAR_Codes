;
; Update definitions
;
; Parameters
;
; Keywords
;
; Written by
;   T.LI @ Sasmac, 20141230
;
PRO TLI_SMC_DEFINITIONS_UPDATE, inputfile=inputfile

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; Judge if the input file is single file or int file.
  
  temp=TLI_FNAME(inputfile, /remove_all_suffix)
  temp=STRSPLIT(temp, '-',/extract,count=ncount)
  
  workpath=FILE_DIRNAME(inputfile)+PATH_SEP()
  config.workpath=workpath
  Case ncount OF
    1: BEGIN
      config.inputfile=inputfile
      config.dem_seg=workpath+'dem_seg'
      
      infofile=inputfile+'.par'
    END
    
    2: BEGIN
    
      config.m_date=temp[0]
      config.s_date=temp[1]
      config.rslcpath=workpath
      config.inputfile=inputfile
      m_rslc=workpath+config.m_date+'.rslc'
      IF NOT FILE_TEST(m_rslc) THEN m_rslc=workpath+config.m_date+'.slc'
      config.m_rslc=m_rslc
      config.m_rslcpar=m_rslc+'.par'
      config.s_rslc=workpath+config.s_date+'.rslc'
      config.s_rslcpar=workpath+config.s_date+'.rslc.par'
      config.dem_seg=workpath+'dem_seg'
      config.int_date=config.m_date+'-'+config.s_date
      infofile=workpath+config.m_date+'.rslc.par'
    END
    ELSE: Dialog_message, 'Error, file names are in wrong format.'+STRING(10b)+inputfile
    
  ENDCASE
  IF file_test(infofile) THEN finfo=TLI_LOAD_SLC_PAR(infofile)
  
END