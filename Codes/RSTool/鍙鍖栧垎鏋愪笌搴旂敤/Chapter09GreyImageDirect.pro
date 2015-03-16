; Chapter09GreyImageDirect.pro
PRO Chapter09GreyImageDirect
  file = FILEPATH('convec.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [248, 248]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Grey Image'
  TV, image
END