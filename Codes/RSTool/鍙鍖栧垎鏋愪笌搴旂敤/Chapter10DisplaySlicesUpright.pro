; Chapter10DisplaySlicesUpright.pro
PRO Chapter10DisplaySlicesUpright
  file = FILEPATH('head.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [80, 100, 57])
  LOADCT,5
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  WINDOW, 0, XSIZE = 800, YSIZE = 600
  FOR i = 0, 56, 1 DO TVSCL, 255b - image [*,*,i], /ORDER, i
  sliceImg = REFORM(image[40,*,*])
  sliceImg = CONGRID(sliceImg, 100, 100)
  TVSCL, 255b - sliceImg, 47
END