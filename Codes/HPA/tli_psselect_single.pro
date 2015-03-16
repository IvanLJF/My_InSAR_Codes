;-
;- choose points according to a single image layer.
;-
;- inputfile       : inputfile to use
;- mskfile         : mask file
;- coef            : coefficient to choose the points.
;- samples         : samples of the input file
;- format          : format of the input file
;- swap_endian     : swap_endian or not
; amplitude        : the input file is an amplitude file.
; 
; Written by:
;   T.LI @ SWJTU, 20140317.
; 

FUNCTION TLI_PSSELECT_SINGLE,inputfile, mskfile=mskfile, coef=coef, samples=samples, format=format,swap_endian=swap_endian, amplitude=amplitude

  ; Choose the points to analyze.
  ; Just use a single image, i.e, SLC or DA, this is not at all important.
  COMPILE_OPT idl2
;  ON_ERROR, 2
  
  IF KEYWORD_SET(samples)+KEYWORD_SET(format) NE 2 THEN Message, 'You must define the keywords: samples, format'
  IF NOT KEYWORD_SET(coef) THEN coef=0.5
  
  data=TLI_READDATA(inputfile, samples=samples, format=format,swap_endian=swap_endian)
  IF KEYWORD_SET(mskfile) THEN BEGIN
    msk= TLI_READDATA(mskfile, samples= samples, format='BYTE')
  ENDIF ELSE BEGIN
    msk= BYTARR(SIZE(data,/DIMENSIONS))
  ENDELSE
  sz=SIZE(data[0],/TYPE)
  IF sz EQ 6 OR sz EQ 9 THEN BEGIN ; Complex or double-complex
  
    data= ABS(data)*(1-msk)
    meanslc=MEAN(data)
    IF N_ELEMENTS(coef) EQ 1 THEN BEGIN
      pt= WHERE(data GT meanslc*coef, npt)
    ENDIF ELSE BEGIN
      pt= WHERE(data GT meanslc*coef[0] AND data LT meanslc*coef[1],npt)
    ENDELSE
    
  ENDIF ELSE BEGIN ; double or float
    data=data*[1-msk]
    
    IF NOT KEYWORD_SET(amplitude) THEN BEGIN ; DA
      IF N_ELEMENTS(coef) EQ 1 THEN BEGIN
        pt=WHERE(data LT coef and data NE 0,npt)
      ENDIF ELSE BEGIN
        pt=WHERE(data GT coef[0] AND data LT coef[1],npt)
      ENDELSE
          
    ENDIF ELSE BEGIN  ; Amplitude
      IF N_ELEMENTS(coef) EQ 1 THEN BEGIN
        pt=WHERE(data GT coef*MEAN(data), npt)
      ENDIF ELSE BEGIN
        pt=WHERE(data GT coef[0] AND data LT coef[1],npt)
      ENDELSE
    ENDELSE
    
  ENDELSE
  Print, 'Points selected:'+STRCOMPRESS(npt)
  IF pt[0] EQ -1 THEN BEGIN
    Print, 'Warning: No points were found.'
    RETURN, -1
  ENDIF
  ;  pt= mslc[pt]
  pt= COMPLEX((pt MOD samples), FLOOR(pt/samples))
  data=0
  RETURN, TRANSPOSE(pt)
END