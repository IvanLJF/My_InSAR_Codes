; Chapter09MagnifyImage.pro
PRO Chapter09MagnifyImage
  file = FILEPATH('convec.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [248, 248])
  LOADCT, 28
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  WINDOW, 0, XSIZE = 248, YSIZE = 248
  TV, image
  magnifiedImg = CONGRID(image, 600, 300, /INTERP)
  WINDOW, 1, XSIZE = 600, YSIZE = 300
  TV, magnifiedImg
END