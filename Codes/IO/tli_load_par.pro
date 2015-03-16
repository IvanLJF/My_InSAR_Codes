;
; Load par file
;
; Parameters
;   parfile : Par file to load.
;
; Keywords
;   par_sep : seperator for par file.
;   keeptxt : Keep txt info, do not convert txt to double.
;
; Example:
;  parfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/geocode/dem_seg.par'
;  par_sep=':'
;  result= TLI_LOAD_PAR(parfile, par_sep=par_sep)
;
; Written by:
;  T.LI @ Sasmac.
;
FUNCTION TLI_LOAD_PAR, parfile, par_sep=par_sep, keeptxt=keeptxt

  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 1 THEN Message, 'Number of input params: ERROR!'
  IF ~KEYWORD_SET(par_sep) THEN par_sep=':'
  
  nlines= FILE_LINES(parfile)
  created=0
  OPENR, lun, parfile,/GET_LUN
  FOR i=0, nlines-1 DO BEGIN
    temp=''
    READF, lun, temp
    seppose= STRPOS(temp, par_sep)
    IF seppose[0] EQ -1 THEN BEGIN
      CONTINUE
    ENDIF
    temp= STRSPLIT(temp, par_sep,/EXTRACT)
    str_name= temp[0]
    str_val=temp[1]
    str_val= STRSPLIT(str_val,/EXTRACT)
    Case str_name OF
      'range_offset_polynomial': BEGIN
        IF KEYWORD_SET(keeptxt) THEN BEGIN
          str_val=str_val[0:*]
        ENDIF ELSE BEGIN
          str_val=DOUBLE(str_val[0:*])
        ENDELSE
      END
      'azimuth_offset_polynomial' :BEGIN
      IF KEYWORD_SET(keeptxt) THEN BEGIN
        str_val=str_val[0:*]
      ENDIF ELSE BEGIN
        str_val=DOUBLE(str_val[0:*])
      ENDELSE
    END
      'ellipsoid_name': BEGIN
        str_val=STRJOIN(str_val[0:*],' ')
      END
    ELSE: BEGIN
      IF KEYWORD_SET(keeptxt) THEN BEGIN
        str_val=str_val[0]
      ENDIF ELSE BEGIN
        str_val=DOUBLE(str_val[0])
      ENDELSE
    END
  ENDCASE
  
  IF created EQ 0 THEN BEGIN
    struct= CREATE_STRUCT(temp[0],temp[1])
    created=1
  ENDIF ELSE BEGIN
    struct= CREATE_STRUCT(struct, str_name, str_val)
  ENDELSE
ENDFOR
RETURN, struct

END