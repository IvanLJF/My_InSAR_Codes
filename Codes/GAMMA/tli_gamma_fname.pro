;-
;- Script that:
;-   Extract file name from a full path string
;-
;-   date: Only return date
;-   fname: Only return file name
;-   nopar: Return file name with '.par' eliminated.
;-   nosuffix: Return file name with suffix eliminated.
;-
FUNCTION TLI_GAMMA_FNAME, inputfile, date=date, fname=fname, nopar=nopar, nosuffix=nosuffix
  
  COMPILE_OPT idl2
  
  IF N_PARAMS(inputfile) NE 1 THEN Message, 'TLI_GAMMA_FNAME: Usage error.'
  
  pathsep= PATH_SEP()
  spos=STRPOS(inputfile, pathsep)
  IF spos[0] EQ -1 THEN BEGIN
    IF !D.name EQ 'WIN' THEN pathsep='/'
    IF !D.name EQ 'X' THEN pathsep='\'
    
  ENDIF
  
  IF KEYWORD_SET(date)+KEYWORD_SET(fname)+KEYWORD_SET(nopar)+KEYWORD_SET(nossufix) EQ 0 THEN date=1
  
  temp= STRSPLIT(inputfile,pathsep, /EXTRACT)
  temp_ele= N_ELEMENTS(temp)
  
  IF temp_ele EQ 1 THEN BEGIN
    filename= inputfile
  ENDIF ELSE BEGIN
    filename= temp[temp_ele-1]
  ENDELSE
  IF KEYWORD_SET(fname) THEN RETURN, filename
  
  temp= STRSPLIT(filename, '.',/EXTRACT)
  temp_ele= N_ELEMENTS(temp)
  
  IF temp_ele EQ 1 THEN BEGIN
    filedate= STRMID(filename, 8,/REVERSE_OFFSET)
  ENDIF ELSE BEGIN
    fname_no_suffix= temp[0]
    filedate= STRMID(fname_no_suffix, 8,/REVERSE_OFFSET)
  ENDELSE
  IF KEYWORD_SET(date) THEN RETURN, filedate
  IF KEYWORD_SET(nosuffix) THEN RETURN, fname_no_suffix
  
  IF KEYWORD_SET(nopar) THEN BEGIN
    ; Check the last suffix
    last_suffix= temp[temp_ele-1]
    IF last_suffix EQ 'par' OR last_suffix EQ 'PAR' THEN BEGIN
      fname_nopar= STRJOIN(temp[0:temp_ele-2],'.')
      RETURN, fname_nopar
    ENDIF ELSE BEGIN
      RETURN, filename
    ENDELSE
  ENDIF ELSE BEGIN
  
  ENDELSE
  

END