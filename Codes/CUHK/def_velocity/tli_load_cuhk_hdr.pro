;-
;- Purpose:
;-     Load CUHK hdr file.
;-
FUNCTION TLI_LOAD_CUHK_HDR, cuhk_parfile

  COMPILE_OPT idl2
  
  IF NOT FILE_TEST(cuhk_parfile) THEN Message, 'File does not exists.'
  
  fstruct= CREATE_STRUCT('fname', cuhk_parfile)
  
  nlines=FILE_LINES(cuhk_parfile)
  
  OPENR, lun, cuhk_parfile,/GET_LUN
  
  FOR i=0, nlines-1 DO BEGIN
  
    temp=' '
    READF, lun, temp
    
    temp= STRSPLIT(temp, '=', /EXTRACT)
    ;    IF N_ELEMENTS(temp) GT 2 THEN Message, 'Error!! Wrong Input File.'
    
    IF N_ELEMENTS(temp) EQ 1 THEN BEGIN ; Useless line.
      ; Find if there is a '}' in this line
      result= STRPOS(temp, '}')
      IF N_ELEMENTS(result) GT 1 THEN BEGIN
        Message, 'Error!!! Wrong input file.'
      ENDIF
      IF N_ELEMENTS(result) EQ 1 THEN BEGIN
        CONTINUE
      ENDIF
    ENDIF ELSE BEGIN
    
      result= STRPOS(temp, '{') ; Find if there is a '{' in this line
      IF result[0] NE -1 THEN BEGIN ; Yes there is.
        name= temp[0]
        val= temp[1]
        val= STRSPLIT(val, '{', /EXTRACT)
        result= STRPOS(temp, '}')
        
        IF result[0] EQ -1 THEN BEGIN; bracket_end is not encoutered.
          bracket_end=0 ; bracket_end is not encoutered.
          WHILE ~bracket_end DO BEGIN
            temp=' '
            READF, lun, temp
            result= STRPOS(temp, '}'); Judge if there is a '}' in this line.
            IF result[0] EQ -1 THEN BEGIN ; Yes there is. The value is added to val. and set bracket_end to 1
              val= val+temp
              bracket_end=1
            ENDIF
          ENDWHILE
        ENDIF
        
        fstruct= CREATE_STRUCT(fstruct, name, val)
        CONTINUE
      ENDIF
    ENDELSE
    name= temp[0]
    val= temp[1]
    fstruct= CREATE_STRUCT(fstruct, temp[0], temp[1])

  ENDFOR
  FREE_LUN, lun
  
  RETURN, fstruct
  
END





