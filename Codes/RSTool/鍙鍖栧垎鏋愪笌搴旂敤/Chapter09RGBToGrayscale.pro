; Chapter09RGBToGrayscale.pro
PRO Chapter09RGBToGrayscale
  file = FILEPATH('glowing_gas.jpg', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_JPEG(file, imageInfo)
  imageSize = imageInfo.dimensions
  READ_JPEG, file, image
  DEVICE, DECOMPOSED = 1
  WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Glowing Gas RGB Image'
  TV, image, TRUE = 1
  redChannel = REFORM(image[0, *, *])
  greenChannel = REFORM(image[1, *, *])
  blueChannel = REFORM(image[2, *, *])
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 1, XSIZE = 3*imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Red(×ó),Green(ÖÐ),and Blue(ÓÒ) Channels of the RGB Image'
  TV, redChannel, 0
  TV, greenChannel, 1
  TV, blueChannel, 2
  grayscaleImage = BYTE(0.299*FLOAT(redChannel) + $
    0.587*FLOAT(redChannel) + 0.114*FLOAT(blueChannel))
  WINDOW, 2,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Grayscale Image'
  TV, grayscaleImage
END