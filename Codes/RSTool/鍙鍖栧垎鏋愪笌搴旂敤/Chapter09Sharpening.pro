; Chapter09Sharpening.pro
PRO Chapter09Sharpening
  file = FILEPATH('mr_knee.dcm', SUBDIRECTORY = ['examples', 'data'])
  image = READ_DICOM(file)
  imageSize = SIZE(image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Original Knee MRI'
  TVSCL, image
  kernelSize = [3, 3]
  kernel = REPLICATE(-1./9., kernelSize[0], kernelSize[1])
  kernel[1, 1] = 1.
  filteredImage = CONVOL(FLOAT(image), kernel,/CENTER, /EDGE_TRUNCATE)
  WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Sharpen Filtered Knee MRI'
  TVSCL, filteredImage
  WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Sharpened Knee MRI'
  TVSCL, image + filteredImage
END