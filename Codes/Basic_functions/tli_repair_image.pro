PRO TLI_REPAIR_IMAGE, inputfile, outputfile=outputfile,overwrite=overwrite, fliph=fliph, flipv=flipv,compress=compress, percent=percent
  ; Repair the input raster image. Remove the speckle points in the raster.

  IF ~KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=inputfile+'_repair.ras'
  ENDIF
  IF FILE_TEST(outputfile) THEN BEGIN
    IF NOT KEYWORD_SET(overwrite) THEN RETURN
  ENDIF
  
  
  image=READ_IMAGE(inputfile)
  
  IF KEYWORD_SET(compress) THEN BEGIN
    IF NOT KEYWORD_SET(percent) THEN BEGIN
      percent_n=0.2
    ENDIF ELSE BEGIN
      percent_n=percent
    ENDELSE
    sz=SIZE(image,/DIMENSIONS)
    sz_n=sz*percent_n
    image=CONGRID(image, sz_n[0],sz_n[1])
    
  ENDIF
  
  image=MEDIAN(image,3)
  
  IF KEYWORD_SET(fliph) THEN BEGIN
    image=ROTATE(image, 5)
  ENDIF
  IF KEYWORD_SET(flipv) THEN BEGIN
    image=ROTATE(image, 7)
  ENDIF
  
  WRITE_IMAGE, inputfile+'.bmp','BMP',image
  scr='convert -flip '+inputfile+'.bmp '+outputfile ; I don't know why there should be a flip.
  SPAWN, scr
  FILE_DELETE, inputfile+'.bmp'
END