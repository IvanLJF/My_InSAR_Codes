;
; Return the dimensions of the input file
; 
; Parameters:
;   inputfile    : Input file.
; 
; Keywords:
;   samples      : Samples of the file
;   lines        : Lines of the file.
;                  At least one of the keywords is needed.
;   format       : Data format.
;                  Supported formats are: int, long, float, double, scomplex, fcomplex, dcomplex
; Written by:
;   T.LI @ SASMAC, 20140729.
;   20101016     : Add supported format: alt_line_data and alt_sample_data
;
FUNCTION TLI_IMAGE_SIZE, inputfile, samples=samples, lines=lines, format=format
  
  IF NOT KEYWORD_SET(samples) AND NOT KEYWORD_SET(lines) THEN BEGIN
    Message, 'Please specify either samples or lines!'
  ENDIF
  
  IF KEYWORD_SET(samples) AND KEYWORD_SET(lines) THEN BEGIN
    result=[samples, lines]
    RETURN, result
  ENDIF
  
  finfo=FILE_INFO(inputfile)
  fsize=finfo.size
  
  format=STRLOWCASE(format)
  Case format OF
    'int'      : length=2
    'long'     : length=4
    'float'    : length=4
    'double'   : length=8
    'scomplex' : length=4
    'fcomplex' : length=8
    'dcomplex' : length=16
    'alt_line_data'    : length=8
    'alt_sample_data'  : length=8
  ENDCASE
  
  IF KEYWORD_SET(samples) THEN BEGIN
    lines=fsize/samples/length
    IF NOT TLI_ISINTEGER(lines,/CONVERT) THEN Message, 'Error: Samples of the input file is wrong.'+STRING(13b)+ $
                                              'File name: '+inputfile+STRING(13b)+ $
                                              'Samples:'+STRCOMPRESS(samples)
    result=[samples, lines]
    RETURN, result
  ENDIF
  
  IF KEYWORD_SET(lines) THEN BEGIN
    samples=fsize/lines/length
    IF NOT TLI_ISINTEGER(samples,/CONVERT) THEN Message, 'Error: Lines of the input file is wrong.'+STRING(13b)+ $
                                              'File name: '+inputfile+STRING(13b)+ $
                                              'Lines:'+STRCOMPRESS(Lines)
    result=[samples,lines]
    RETURN, result
  ENDIF
  
END