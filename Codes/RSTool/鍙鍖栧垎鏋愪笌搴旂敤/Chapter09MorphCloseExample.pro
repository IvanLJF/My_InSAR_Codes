; Chapter09MorphCloseExample.pro
PRO Chapter09MorphCloseExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('mineral.png', SUBDIRECTORY=['examples', 'data'])
  img = READ_PNG(file)
  dims = SIZE(img, /DIMENSIONS)
  padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
  padImg [5, 5] = img
  dims = SIZE(padImg, /DIMENSIONS)
  WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
    TITLE = 'Extracting Shapes with the Closing Operator'
  TVSCL, padImg, 0
  side = 3
  strucElem = DIST(side) LE side
  PRINT, strucElem
  closeImg = MORPH_CLOSE(padImg, strucElem, /GRAY)
  TVSCL, closeImg, 1
  WINDOW, 2, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(closeImg)
  binaryImg = padImg LE 160
  WSET, 0
  TVSCL, binaryImg, 2
  binaryClose = closeImg LE 160
  TVSCL, binaryClose, 3
END