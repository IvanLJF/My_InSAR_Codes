;-
;- Purpose:
;-     Clip a raster file using clipfile. Clipfile is a text contains rectangular's coors.
PRO TLI_CLIP_RASTER, rasterfile, clipfile, outfile=outfile

  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 2 THEN Message, 'TLI_CLIP_RASTER: Usage Error!!'
  
  IF NOT KEYWORD_SET(outfile) THEN BEGIN
    temp= STRSPLIT(rasterfile, '.',/EXTRACT)
    IF N_ELEMENTS(temp) EQ 1 THEN BEGIN
      Message,'Error: Format not supported!'
    ENDIF ELSE BEGIN
      fbasename= temp[0:(N_ELEMENTS(temp)-2)]
      fsuffix= temp[N_ELEMENTS(temp)-1]
    ENDELSE
    outfile= fbasename+'cropped'+fsuffix
  ENDIF
  
  nlines= FILE_LINES(clipfile)
  IF nlines LE 2 THEN Message, 'Clipfile should contain at least 2 lines'
  
  clip= STRARR(nlines)
  OPENR, lun, clipfile,/GET_LUN
  READF, lun, clip
  FREE_LUN, lun
  
  cliprange=LONARR(2)
  FOR i=0, nlines-1 DO BEGIN
    temp= clip[i]
    temp= STRSPLIT(temp,/EXTRACT)
    IF N_ELEMENTS(temp) NE 2 THEN BEGIN
      Message, 'The clipfile should contain 2 columns.'
    ENDIF
    cliprange=[[cliprange], [LONG(temp)]]
  ENDFOR
  cliprange= cliprange[*, 1:*]
  
  ; Read image
  raster= READ_IMAGE(rasterfile)
  minx= MIN(raster[0, *])
  maxx= MAX(raster[0, *])
  miny= MIN(raster[1, *])
  maxy= MAX(raster[1, *])

  sz= SIZE(raster,/DIMENSIONS)
  subset= raster[*, minx:maxx, miny:maxy]
  
  Write_IMAGE, outfile, 'BMP', subset
  
  STOP
  
  
  
END