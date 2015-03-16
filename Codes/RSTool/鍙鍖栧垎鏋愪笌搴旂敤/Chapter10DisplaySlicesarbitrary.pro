; Chapter10DisplaySlicesarbitrary.pro
PRO Chapter10DisplaySlicesarbitrary
  file = FILEPATH('head.dat', SUBDIRECTORY = ['examples', 'data'])
  volume = READ_BINARY(file, DATA_DIMS =[80, 100, 57])
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  sliceImage = EXTRACT_SLICE(volume, 110, 110, 40, 50, 28, 90.0, 90.0, 0.0, OUT_VAL = 0)
  bigImage = CONGRID(sliceImage, 400, 650, /INTERP)
  WINDOW, 0, XSIZE = 400, YSIZE = 650
  TVSCL, bigImage
END