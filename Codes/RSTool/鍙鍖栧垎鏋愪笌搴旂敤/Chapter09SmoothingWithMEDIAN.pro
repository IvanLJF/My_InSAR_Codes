; Chapter09SmoothingWithMEDIAN.pro
PRO Chapter09SmoothingWithMEDIAN
  file = FILEPATH('rbcells.jpg', SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, file, image
  imageSize = SIZE(image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW,0,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Original Image'
  TV, image
  WINDOW, 1, TITLE = 'Original Image as a Surface'
  SHADE_SURF, image, /XSTYLE, /YSTYLE, CHARSIZE = 2., $
    XTITLE = 'Width Pixels', YTITLE = 'Height Pixels', $
    ZTITLE = 'Intensity Values', TITLE = 'Red Blood Cell Image'
  smoothedImage = MEDIAN(image, 5)
  WINDOW, 2, TITLE = 'Smoothed Image as a Surface'
  SHADE_SURF, smoothedImage, /XSTYLE, /YSTYLE, CHARSIZE = 2., $
    XTITLE = 'Width Pixels', YTITLE = 'Height Pixels', $
    ZTITLE = 'Intensity Values', TITLE = 'Smoothed Cell Image'
  WINDOW,3,XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='Smoothed Image'
  TV, smoothedImage
END