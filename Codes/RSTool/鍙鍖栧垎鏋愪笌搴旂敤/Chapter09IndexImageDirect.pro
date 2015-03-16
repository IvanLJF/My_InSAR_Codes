; Chapter09IndexImageDirect.pro
PRO Chapter09IndexImageDirect
  file = FILEPATH('avhrr.png', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_IMAGE(file, imageInfo)
  imageSize = imageInfo.dimensions
  image = READ_IMAGE(file, red, green, blue)
  DEVICE, DECOMPOSED = 0
  TVLCT, red, green, blue
  WINDOW, 0,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Index Image'
  TV, image
  XLOADCT, /BLOCK
  variable = ''
  READ, variable, PROMP='Next Image!'
  LOADCT, 27
  TV, image
  XLOADCT, /BLOCK
  READ, variable, PROMP='Next Image!'
  LOADCT, 13
  TV, image
  XLOADCT, /BLOCK
END
