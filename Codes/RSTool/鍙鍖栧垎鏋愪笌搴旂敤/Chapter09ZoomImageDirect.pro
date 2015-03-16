; Chapter09ZoomImageDirect.pro
PRO Chapter09ZoomImageDirect
  file = FILEPATH('convec.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [248, 248]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 1,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Grey Image'
  TV, image
  ZOOM, /NEW_WINDOW, FACT=2,XSIZE=imageSize[0],YSIZE=imageSize[1]
END