;-
;- Read txt file. Only support matrix
;-
;- T.LI @ ISEIS , 20130326
;- Add Keyword: easy
;- Add function tli_size_txt
;- T.LI @ ISEIS, 20130626
FUNCTION TLI_SIZE_TXT, inputfile,sep=sep
  
  IF NOT KEYWORD_SET(sep) THEN sep=' '
  lines=FILE_LINES(inputfile)
  temp=''
  OPENR, lun, inputfile,/GET_LUN
  READF, lun,temp
  FREE_LUN, lun
  temp=STRSPLIT(temp, sep, count=samples,/EXTRACT)
  IF N_ELEMENTS(temp) EQ 1 THEN BEGIN
    temp=STRSPLIT(temp, STRING(9B), count=samples,/EXTRACT)
  ENDIF
  samples=samples
  sz=[samples, lines]
  RETURN, sz
END


FUNCTION TLI_READTXT, inputfile,header_lines=header_lines, header_samples=header_samples,end_lines=end_lines,easy=easy,txt=txt
  ON_ERROR, 2
  IF NOT FILE_TEST(inputfile) THEN Message, 'File not exist!!!'
  IF NOT KEYWORD_SET(header_lines) THEN header_lines=0
  IF NOT KEYWORD_SET(header_samples) THEN header_samples=0
  IF NOT KEYWORD_SET(end_lines) THEN end_lines=0
  
  IF KEYWORD_SET(txt) THEN BEGIN
    nlines=FILE_LINES(inputfile)
    result=STRARR(1, nlines-end_lines)
    OPENR, lun, inputfile,/GET_LUN
    READF, lun, result
    FREE_LUN, lun
    RETURN, result[*, header_lines:*]
  ENDIF
  
  IF KEYWORD_SET(easy) THEN BEGIN
    sz=TLI_SIZE_TXT(inputfile)
    result=DBLARR(sz[0],sz[1]-header_lines-end_lines)
    OPENR, lun, inputfile,/GET_LUN
    READF, lun, result
    FREE_LUN, lun
    RETURN, result
  ENDIF
  
  nlines= FILE_LINES(inputfile)
  OPENR, lun, inputfile,/GET_LUN
  IF header_lines NE 0 THEN BEGIN
    IF header_lines LT 0 THEN Message, 'Error! Header lines can not be less than 0.'
    FOR i=0, header_lines-1 DO BEGIN
      temp=''
      READF, lun, temp
    ENDFOR
  ENDIF
  
  FOR i=0D,nlines-1D -header_lines-end_lines DO BEGIN
  
    temp=''
    READF, lun,temp
    IF temp EQ '' THEN CONTINUE
    temp= (STRSPLIT(temp,/EXTRACT))
    temp= temp[header_samples:*]
    samples_new= N_ELEMENTS(temp)
    IF i EQ 0 THEN BEGIN
      samples_old=samples_new
      result= DBLARR(samples_new, nlines-header_lines-end_lines)
    ENDIF
    
    IF samples_old NE samples_new THEN BEGIN
      FREE_LUN, lun
      Message, 'Format Error!Only support matrix!'
    ENDIF
    
    result[*, i]=temp
  ENDFOR
  FREE_LUN, lun
  
  RETURN, result
END