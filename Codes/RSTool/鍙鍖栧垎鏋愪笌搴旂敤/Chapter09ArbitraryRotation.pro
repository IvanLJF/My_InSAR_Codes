; Chapter09ArbitraryRotation.pro
PRO Chapter09ArbitraryRotation
  file = FILEPATH('m51.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [340, 440])
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  WINDOW, 0, XSIZE = 340, YSIZE = 440
  TVSCL, image
  arbitraryImg = ROT(image, 33, .5, /INTERP, MISSING = 127)
  WINDOW, 1, XSIZE = 340, YSIZE = 440
  TVSCL, arbitraryImg
END