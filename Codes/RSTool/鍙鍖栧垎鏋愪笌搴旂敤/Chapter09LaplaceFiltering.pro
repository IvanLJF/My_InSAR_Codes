; Chapter09LaplaceFiltering.pro
PRO Chapter09LaplaceFiltering
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
  kernel = FLTARR(kernelSize[0], kernelSize[1])
  kernel[1, *] = -1.
  kernel[*, 1] = -1.
  kernel[1, 1] = 4.
  filteredImage=CONVOL(FLOAT(croppedImage),kernel,/CENTER,/EDGE_TRUNCATE)
  WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Laplace Filtered New York Image'
  TVSCL, CONGRID(filteredImage, displaySize[0], displaySize[1])
  PRINT, MIN(filteredImage), MAX(filteredImage)
  WINDOW, 2, XSIZE = displaySize[0], YSIZE = displaySize[1], $
  TITLE = 'Negative Values of Laplace Filtered New York Image'
  TVSCL, CONGRID(filteredImage < 0, displaySize[0], displaySize[1])
END