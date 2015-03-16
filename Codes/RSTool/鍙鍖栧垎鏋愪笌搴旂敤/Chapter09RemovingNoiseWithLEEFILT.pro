; Chapter09RemovingNoiseWithLEEFILT.pro
PRO Chapter09RemovingNoiseWithLEEFILT
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [64, 64]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0, XSIZE = displaySize[0], $
    YSIZE = displaySize[1], TITLE = 'Original Image'
  TVSCL, CONGRID(image, displaySize[0], displaySize[1])
  filteredImage = LEEFILT(image, 1)
  WINDOW, 1, XSIZE = displaySize[0], $
    YSIZE = displaySize[1], TITLE = 'Lee Filtered Image'
  TVSCL, CONGRID(filteredImage, displaySize[0], displaySize[1])
END