; Chapter09RotateImage.pro
PRO Chapter09RotateImage
  file = FILEPATH('galaxy.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [256, 256])
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 4
  WINDOW, 0, XSIZE = 256, YSIZE = 256
  TVSCL, image
  rotateImg = ROTATE(image, 3)
  WINDOW, 1, XSIZE = 256, YSIZE = 256
  TVSCL, rotateImg
END