; Chapter09BinaryImageDirect.pro
PRO Chapter09BinaryImageDirect
  file=FILEPATH('continent_mask.dat',SUBDIRECTORY=['examples','data'])
  imageSize = [360, 360]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 2,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Binary Image'
  TVSCL, image
END