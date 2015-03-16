; Chapter09ByteScaling.pro
PRO Chapter09ByteScaling
  file = FILEPATH('mr_brain.dcm', SUBDIRECTORY = ['examples', 'data'])
  image = READ_DICOM(file)
  imageSize = SIZE(image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0
  LOADCT, 5
  WINDOW,0,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Original Image'
  TV, image
  scaledImage = BYTSCL(image)
  WINDOW,1,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='ByteScaled Image'
  TV, scaledImage
END