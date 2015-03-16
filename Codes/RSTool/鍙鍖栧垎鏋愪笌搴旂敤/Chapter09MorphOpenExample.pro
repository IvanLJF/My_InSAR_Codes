; Chapter09MorphOpenExample.pro
PRO Chapter09MorphOpenExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('r_seeberi.jpg', SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, file, image, /GRAYSCALE
  dims = SIZE(image, /DIMENSIONS)
  WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
    TITLE='Defining Shapes with the Opening Operator'
  TVSCL, image, 0
  radius = 7
  strucElem = SHIFT(DIST(2*radius+1), radius, radius) LE radius
  morphImg = MORPH_OPEN(image, strucElem, /GRAY)
  TVSCL, morphImg, 1
  WINDOW, 1, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(image)
  threshImg = image GE 160
  WSET, 0
  TVSCL, threshImg, 2
  morphThresh = MORPH_OPEN(threshImg, strucElem)
  TVSCL, morphThresh, 3

END