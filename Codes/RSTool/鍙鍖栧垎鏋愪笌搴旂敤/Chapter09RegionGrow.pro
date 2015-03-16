; Chapter09RegionGrow.pro
PRO Chapter09RegionGrow
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('md1107g8a.jpg', SUBDIRECTORY = ['examples','data'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  img = REBIN(BYTSCL(img), dims[0]*2, dims[1]*2)
  dims = 2*dims
  WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], $
    TITLE = 'Click on Image to Select Point of ROI'
  TVSCL, img
  CURSOR, xi, yi, /DEVICE
  x = LINDGEN(10*10) MOD 10 + xi
  y = LINDGEN(10*10) / 10 + yi
  roiPixels = x + y * dims[0]
  WDELETE, 0
  topClr = !D.TABLE_SIZE - 1
  TVLCT, 255, 0, 0, topClr
  regionPts = BYTSCL(img, TOP = (topClr - 1))
  regionPts[roiPixels] = topClr
  WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], TITLE = 'Original Region'
  TV, regionPts
  newROIPixels = REGION_GROW(img, roiPixels, THRESHOLD = [215,255])
  regionImg = BYTSCL(img, TOP = (topClr - 1))
  regionImg[newROIPixels] = topClr
  WINDOW, 2, XSIZE = dims[0], YSIZE = dims[1], $
    TITLE = 'THRESHOLD Grown Region'
  TV, regionImg
  stddevPixels = REGION_GROW(img, roiPixels, STDDEV_MULTIPLIER = 7)
  WINDOW, 3, XSIZE = dims[0], YSIZE = dims[1], $
    TITLE = "STDDEV_MULTIPLIER Grown Region"
  regionImg2 = BYTSCL(img, TOP = (topClr - 1))
  regionImg2[stddevPixels] = topClr
  TV, regionImg2
END