;
; Assess the cc file generated from GAMMA
;
; Parameters:
;   ccfile
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20140922
; 
PRO TLI_GAMMA_CC_ASSESS;, ccfile
  
  ccfile='/mnt/data_tli/ForExperiment/int_envisat_tibet/20041014-20041118.filt.cc'
  
  workpath=FILE_DIRNAME(ccfile)+PATH_SEP()
  
  logfile=workpath+'log.txt'
  
  parfiles=FILE_SEARCH(workpath+'*.rslc.par', count=nfiles)
  
  IF nfiles EQ 0 THEN Message, 'Error! No par file was found in the directory:'+STRING(13b)+workpath
  
  fpar=TLI_LOAD_SLC_PAR(parfiles[0])
  
  width=fpar.range_samples
  
  nlines=fpar.azimuth_lines
  
  ; Get the size of cc file.
  sz=TLI_IMAGE_SIZE(ccfile, samples=width, format='float')
  
  ; Read data
  cc=TLI_READDATA(ccfile, samples=width, format='float',/swap_endian)
  
  cc_thresh=0.3
  cc_flag=WHERE(cc GE cc_thresh, count)
  cc_per=double(count) / DOUBLE(sz[0]*sz[1])
  
  TLI_LOG, logfile, 'Percent of cc values greater than '+STRCOMPRESS(cc_thresh,/REMOVE_ALL)+' is:'+STRCOMPRESS(cc_per,/REMOVE_ALL),/PRT
  STOP
END