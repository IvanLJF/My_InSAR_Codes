; Chapter09ColorbarIndexedDirect.pro
PRO Chapter09ColorbarIndexedDirect
  worldtmpFile = FILEPATH('worldtmp.png', $
    SUBDIRECTORY = ['examples', 'demo', 'demodata'])
  worldtmpImage = READ_PNG(worldtmpFile)
  worldtmpSize = SIZE(worldtmpImage, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0
  LOADCT, 38
  WINDOW, 0, XSIZE = worldtmpSize[0], YSIZE = worldtmpSize[1], $
    TITLE = 'Average World Temperature'
  TV, worldtmpImage
  fillColor = BYTSCL(INDGEN(18))
  temperature = STRTRIM(FIX(((20.*fillColor)/51.) - 60), 2)
  x = [5., 40., 40., 5., 5.]
  y = [5., 5., 23., 23., 5.] + 5.
  offset = 18.*FINDGEN(19) + 5.
  FOR i = 0, (N_ELEMENTS(fillColor) - 1) DO BEGIN
    POLYFILL, x, y + offset[i], COLOR = fillColor[i], /DEVICE
    XYOUTS, x[0] + 5., y[0] + offset[i] + 5., $
      temperature[i], COLOR = 255*(fillColor[i] LT 255), /DEVICE
  ENDFOR
END