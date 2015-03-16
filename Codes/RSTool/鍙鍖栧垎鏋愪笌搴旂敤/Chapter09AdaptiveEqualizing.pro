; Chapter09AdaptiveEqualizing.pro
PRO Chapter09AdaptiveEqualizing
  file = FILEPATH('mineral.png', SUBDIRECTORY = ['examples', 'data'])
  image = READ_PNG(file, red, green, blue)
  imageSize = SIZE(image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0
  TVLCT, red, green, blue
  WINDOW,0,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Original Image'
  TV, image
  WINDOW, 1, TITLE = 'Histogram of Image'
  PLOT, HISTOGRAM(image), /XSTYLE, /YSTYLE, $
    TITLE = 'Mineral Image Histogram', $
    XTITLE = 'Intensity Value', YTITLE = 'Number of Pixels of That Value'
  equalizedImage = ADAPT_HIST_EQUAL(image)
  WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
    TITLE = 'Adaptive Equalized Image'
  TV, equalizedImage
  WINDOW, 3, TITLE = 'Histogram of Adaptive Equalized Image'
  PLOT, HISTOGRAM(equalizedImage), /XSTYLE, /YSTYLE, $
    TITLE = 'Adaptive Equalized Image Histogram', $
    XTITLE = 'Intensity Value', YTITLE = 'Number of Pixels of That Value'
END