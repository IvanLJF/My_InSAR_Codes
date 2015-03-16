;-
;- Add prefix or suffix to each line of the input txt.
;-
;- Example:
;   inputfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/integral_paths/plot_path.sh'
;   prefix='PrintF, lun, ''
;   suffix='''
;   TLI_FIX_TXT, inputfile, prefix=prefix, suffix=suffix, outputfile=outputfile

PRO TLI_FIX_TXT, inputfile, prefix=prefix, suffix=suffix, outputfile=outputfile
  COMPILE_OPT idl2
  IF NOT KEYWORD_SET(inputfile) THEN BEGIN
    Message, 'Number of input parameters: ERROR!'
  ENDIF
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=inputfile+'.changed'
  ENDIF
  
  OPENR,inlun, inputfile,/GET_LUN
  OPENW, outlun, outputfile,/GET_LUN
  
  nlines=FILE_LINES(inputfile)
  file= STRARR(1, nlines)
  READF, inlun, file
  IF KEYWORD_SET(prefix) THEN BEGIN
    file=prefix+file
  ENDIF
  IF KEYWORD_SET(suffix) THEN BEGIN
    file= file+suffix
  ENDIF
  PRINTF, outlun, file
  
  FREE_LUN, inlun
  FREE_LUN, outlun

END