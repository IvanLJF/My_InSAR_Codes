FUNCTION TLI_MINMAX, inputfile, sarlistfile=sarlistfile,samples=samples, lines=lines, swap_endian=swap_endian, format=format, $
    type=type,los_to_v=los_to_v, minus=minus
  COMPILE_OPT idl2
  ; Print MIN & MAX value in inputfile.
  ; Keywods samples+lines+swap_endian+format are set for TLI_READDATA
  
  IF ~KEYWORD_SET(inputfile) Then message, 'TLI_GAMMA_MINMAX: Usage Error!'
  
  IF KEYWORD_SET(type) THEN BEGIN
    IF type EQ 'vdh' THEN BEGIN
      data=TLI_READMYFILES(inputfile, type=type)
      v=data[3,*]
      minv=MIN(v, max=maxv)
      IF KEYWORD_SET(minus) THEN BEGIN
        minv=minv-maxv
        maxv=0
      ENDIF
      IF KEYWORD_SET(los_to_v) THEN BEGIN
        IF NOT KEYWORD_SET(sarlistfile) THEN Message, 'Error! Please specify the sarlistfile.'
        finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
        minv=minv/COS(DEGREE2RADIUS(finfo.incidence_angle))
        maxv=0
      ENDIF
      
      result=[minv, maxv]
      Print, 'Min Max value of the deformation values:', result
      RETURN, result
      
    ENDIF
  ENDIF
  
  IF KEYWORD_SET(type) THEN data=TLI_READMYFILES(inputfile,type=type) $
  ELSE data= TLI_READDATA(inputfile, samples=samples, lines=lines, swap_endian=swap_endian, format=format)
  
  ; Get the file size
  sz=SIZE(data,/DIMENSIONS)
  samples=sz[0]
  lines=sz[1]
  
  dir=samples<lines
  
  IF dir EQ samples THEN BEGIN
    Print, 'The record are stored each in one line.'
    Print, 'We count the information for each column.'
    
    result=DBLARR(samples, 2)
    
    FOR i=0, samples-1 DO BEGIN
      temp=data[i, *]
      minv=MIN(temp, max=maxv)
      result[*, i]=[minv, maxv]
    ENDFOR
    
  ENDIF ELSE BEGIN
    Print, 'The record are stored each in one column.'
    Print, 'We count the information for each line.'
    
    result=DBLARR(samples, 2)
    
    FOR i=0, lines-1 DO BEGIN
      temp=data[*, i]
      minv=MIN(temp, max=maxv)
      result[*, i]=[minv, maxv]
    ENDFOR
    
  ENDELSE
  Print, 'Inputfile:', inputfile
  Print, 'Dimensions of inputfile:', sz
  Print, '[Min Max] for each record:'
  Print, result
  RETURN, result
  
  
  
END