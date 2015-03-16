; Chapter09DetectingEdgesWithSOBEL.pro
PRO Chapter09DetectingEdgesWithSOBEL
  file = FILEPATH('nyny.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [768, 512]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  croppedSize = [96, 96]
  croppedImage = image[200:(croppedSize[0] - 1) + 200, $
    180:(croppedSize[1] - 1) + 180]
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  displaySize = [256, 256]
  WINDOW, 0, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Cropped New York Image'
  TVSCL, CONGRID(croppedImage, displaySize[0], displaySize[1])
  EdgedImage = SOBEL(croppedImage)
  WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Edged New York Image'
  TVSCL, CONGRID(EdgedImage, displaySize[0], displaySize[1])
END