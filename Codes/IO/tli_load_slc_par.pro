;- 
;- Purpose:
;-     Load GAMMA SLC PAR file.
;- Calling Sequence:
;-    Result= TLI_LOAD_SLC_PAR(par_file)
;- Inputs:
;-    par_file     :  SLC .par file.
;- Optional Input Parameters:
;-    None.
;- Keyword Input Parameters:
;-    None.
;- Outputs:
;-    Structure of input file.
;- Commendations:
;-    None.
;- Modification History:
;-    29/10/2012    : T.Li @ InSAR GROUP of CUHK & SWJTU.
;- Purpose:
;-   Load GAMMA SLC par
;- Example:
;-   par_file= '/mnt/software/ForExperiment/TSX_PS_Tianjin/piece/20091113.rslc.par'
;-   result= TLI_LOAD_SLC_PAR(par_file)
Function TLI_LOAD_SLC_PAR, par_file
  
  COMPILE_OPT idl2
  ON_ERROR, 2
  
  ; Judge if it is a gamma header file.
  temp=''
  OPENR, lun, par_file,/GET_LUN
  READF, lun, temp
  IF temp NE 'Gamma Interferometric SAR Processor (ISP) - Image Parameter File' THEN BEGIN
    FREE_LUN, lun
    Message, 'This is not a GAMMA parameters file.'
  ENDIF
  
  ; Create structure.
  nlines= FILE_LINES(par_file)
  nlines=nlines[0]
  svp= DBLARR(3); State vector position
  svv= DBLARR(3); State vector velocity
  For i =0, nlines-4 DO BEGIN ; two empty lines at the end of file
    temp=''
    IF i EQ 0 THEN BEGIN
      READF, lun, temp ; empty line
      READF, lun, temp
      temp= (STRSPLIT(temp, ':',/EXTRACT))
      struct= CREATE_STRUCT(temp[0],temp[1])
      struct=CREATE_STRUCT(struct, 'filename', FILE_DIRNAME(par_file)+PATH_SEP()+FILE_BASENAME(par_file,'.par'))
    ENDIF ELSE BEGIN
      IF i LE 46 THEN BEGIN
        READF, lun, temp
        temp= STRSPLIT(temp, ':',/EXTRACT)
        name= temp[0]
        val= temp[1]
        Case name OF
          'sensor': BEGIN
            struct= CREATE_STRUCT(struct, temp[0], STRCOMPRESS(temp[1],/REMOVE_ALL))
          END
          'date': BEGIN
            temp_val=''
            val=STRSPLIT(val,' ',/extract,count=count)
            FOR j=0, count-1 DO BEGIN
              temp_i=STRSPLIT(val[j],'.',/extract,count=count_i)
              IF STRLEN(temp_i[0]) LE 1 THEN BEGIN
                temp_i[0]='0'+STRCOMPRESS(temp_i[0],/REMOVE_ALL)
              ENDIF ELSE BEGIN
                temp_i[0]=STRCOMPRESS(temp_i[0],/REMOVE_ALL)
              ENDELSE
              
              IF count_i EQ 1 THEN BEGIN
                temp_val=temp_val+temp_i[0]
              ENDIF ELSE BEGIN
                temp_val=temp_val+temp_i[0]+'.'+temp_i[1]
              ENDELSE
              
            ENDFOR
            
            struct= CREATE_STRUCT(struct, temp[0], STRCOMPRESS(temp_val,/REMOVE_ALL))
            
          END
          'image_format': BEGIN
            struct= CREATE_STRUCT(struct, temp[0], STRCOMPRESS(temp[1],/REMOVE_ALL))
          END
          'image_geometry': BEGIN
            struct= CREATE_STRUCT(struct, temp[0], STRCOMPRESS(temp[1],/REMOVE_ALL))
          END
          'azimuth_deskew': BEGIN
            struct= CREATE_STRUCT(struct, temp[0], STRCOMPRESS(temp[1],/REMOVE_ALL))
          END
          ELSE: BEGIN
            val= STRSPLIT(val, '', /EXTRACT)
            IF N_ELEMENTS(val) EQ 1 THEN BEGIN
              struct= CREATE_STRUCT(struct, temp[0], DOUBLE(temp[1]))
            ENDIF ELSE BEGIN
              nval= N_ELEMENTS(val)/2
              val= DOUBLE(val[0:nval-1]) ; Multi value params.
              struct= CREATE_STRUCT(struct, temp[0], val)
            ENDELSE
          END
        ENDCASE
;      Print, 'Line'+STRING(i+3), temp
      ENDIF ELSE BEGIN
        name1= 'state_vector_position'
        name2= 'state_vector_velocity'
        IF ~(i MOD 2) THEN BEGIN ; even line.
          READF, lun, temp
          temp= STRSPLIT(temp,/EXTRACT)
          svp= [[svp], [DOUBLE(temp [1:3])]]
        ENDIF ELSE BEGIN ; odd line
          READF, lun, temp
          temp= STRSPLIT(temp,/EXTRACT)
          svv= [[svv], [DOUBLE(temp[1:3])]]
        ENDELSE
      ENDELSE
    ENDELSE
  ENDFOR
  struct= CREATE_STRUCT(struct, name1, svp, name2, svv)
  FREE_LUN, lun
  RETURN, struct
END