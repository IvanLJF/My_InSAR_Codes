; Chapter09ShiftImageOffset.pro
PRO Chapter09ShiftImageOffset
  file=FILEPATH('shifted_endocell.png',SUBDIRECTORY=['examples','data'])
  image = READ_PNG(file, R, G, B)
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  TVLCT, R, G, B
  HELP, image
  imageSize = SIZE(image, /DIMENSIONS)
  WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
  TITLE = 'Original Image'
  TV, image
  image = SHIFT(image, -imageSize[0]/4, -imageSize[1]/3)
  WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
  TITLE = 'Shifted Image'
  TV, image
END