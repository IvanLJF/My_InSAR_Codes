;-
;- Extract the point information from the input datafile.
;-
;-   pind      : Indices to use.
;-   datafile  : input data file.
;-   sample  lines  format swap_endian: Keywords for TLI_READDATA.pro
;-   type      : Keyword for TLI_READMYFILES.pro
;-   itab_ind  : interferograms to use. Omitted is to use all.
;-   header_lines: Header lines to jump.
;-
;- Written by:
;-   T.LI @ ISEIS, 20130723
;

FUNCTION TLI_EXTRACT_PTINFO, pind, datafile, samples=samples, lines=lines, format=format, swap_endian=swap_endian, $
    type=type,itab_ind=itab_ind,header_lines=header_lines
    
  ; Check the input params.
  IF NOT KEYWORD_SET(header_lines) THEN BEGIN
    Print, 'Warning: Keyword is not set: header_lines'
    header_lines=0
  ENDIF
  IF KEYWORD_SET(type) THEN BEGIN
    data=TLI_READMYFILES(datafile, type=type)
  ENDIF ELSE BEGIN
    data=TLI_READDATA(datafile, samples=samples, lines=lines, format=format, swap_endian=swap_endian)
  ENDELSE
  
  data=data[*, (header_lines):*]
  sz=SIZE(data,/DIMENSIONS)
  samples=sz[0]
  lines=sz[1]
  IF samples LT 600 THEN BEGIN ; The number of columns is too small to be regarded as a normal pt file.
    result=data[*, pind]
  ENDIF ELSE BEGIN
  
    IF KEYWORD_SET(itab_ind) THEN BEGIN
      result=data[pind, itab_ind]
    ENDIF ELSE BEGIN
      result=data[pind, *]
    ENDELSE
  ENDELSE
  
  RETURN, result
  
END