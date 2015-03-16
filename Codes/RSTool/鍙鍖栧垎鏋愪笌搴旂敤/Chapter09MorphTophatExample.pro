; Chapter09MorphTophatExample.pro
PRO Chapter09MorphTophatExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT,0
  file = FILEPATH('r_seeberi_spore.jpg',SUBDIRECTORY=['examples','data'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
  padImg [5,5] = img
  dims = SIZE(padImg, /DIMENSIONS)
  WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
  TITLE='Detecting Small Features with MORPH_TOPHAT'
  TVSCL, padImg, 0
  radius = 3
  strucElem = SHIFT(DIST(2*radius+1),radius,radius) LE radius
  tophatImg = MORPH_TOPHAT(padImg, strucElem)
  TVSCL, tophatImg , 1
  WINDOW, 2, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(padImg)
  WSET, 0
  stretchImg = tophatImg < 70
  TVSCL, stretchImg, 2
  threshImg = tophatImg GE 60
  TVSCL, threshImg, 3
END