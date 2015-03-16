;
; Write data to specified file.
; 
; Parameters:
;   file          : The file to write.
;   array         : The given data.
; 
; Keywords:
;   txt           : Set this keyword to 1 to write the data in ASCII format.
;   swap_endian   : Set this keyword to 1 to swap bytes (only applicable when writting binary data).
;   format        : Format of the txt file. Not suggested if you do not know IDL familiar.
;   append        : Set this keyword to 1 to append the data to the end of the file.
;   string        : Set this keyword to 1 to write a string.
; 
; Written by:
;   T.LI @ SWJTU, 20140609
;
PRO TLI_WRITE, file,array,txt=txt,swap_endian=swap_endian, format=format,append=append,string=string
  COMPILE_OPT idl2
  ON_ERROR, 2
  IF KEYWORD_SET(txt) THEN BEGIN
    OPENW, lun, file,/GET_LUN,append=append
    IF NOT KEYWORD_SET(format) THEN BEGIN
      sz=SIZE(array, /DIMENSIONS)
      samples=sz[0]
      temp='('+STRJOIN(REPLICATE('A20', samples), ',')+')'
      PrintF, lun, STRCOMPRESS(array), format=temp
    ENDIF ELSE BEGIN
      PRINTF, lun, STRCOMPRESS(array),format=format
    ENDELSE
    FREE_LUN, lun
    RETURN
  ENDIF
  
  IF KEYWORD_SET(string) THEN BEGIN
    OPENW, lun, file,/GET_LUN,append=append
    PrintF, lun, array
    FREE_LUN, lun
    RETURN  
  ENDIF
  
  OPENW, lun, file,/GET_LUN,swap_endian=swap_endian,append=append
  WRITEU, lun, array
  FREE_LUN, lun
  
END