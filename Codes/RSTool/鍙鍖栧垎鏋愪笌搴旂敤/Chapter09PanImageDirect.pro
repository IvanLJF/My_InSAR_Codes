; pro  Chapter09PanImageObject.pro
PRO Chapter09PanImageDirect
  file = FILEPATH('nyny.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [768, 512]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  SLIDE_IMAGE, image
END