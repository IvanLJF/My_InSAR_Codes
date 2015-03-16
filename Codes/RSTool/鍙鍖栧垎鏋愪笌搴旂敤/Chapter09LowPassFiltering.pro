; Chapter09LowPassFiltering.pro
PRO Chapter09LowPassFiltering
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
  kernelSize = [3, 3]
  kernel = REPLICATE((1./(kernelSize[0]*kernelSize[1])), $
    kernelSize[0], kernelSize[1])
  filteredImage=CONVOL(FLOAT(croppedImage),kernel,/CENTER,/EDGE_TRUNCATE)
  WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Low Pass Filtered New York Image'
  TVSCL, CONGRID(filteredImage, displaySize[0], displaySize[1])
  WINDOW, 2, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Low Pass Combined New York Image'
  TVSCL,CONGRID(croppedImage+filteredImage,displaySize[0],displaySize[1])

END