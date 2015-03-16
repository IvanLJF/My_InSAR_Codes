; Chapter09MorphErodeDilate.pro
PRO Chapter09MorphErodeDilate
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('pollens.jpg', $
  SUBDIRECTORY = ['examples', 'demo', 'demodata'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  radius = 2
  strucElem = SHIFT(DIST(2*radius+1), radius, radius) LE radius
  PRINT, strucElem
  erodeImg = REPLICATE(MAX(img), dims[0]+2, dims[1]+2)
  erodeImg [1,1] = img
  dilateImg = REPLICATE(MIN(img), dims[0]+2, dims[1]+2)
  dilateImg [1,1] = img
  padDims = SIZE(erodeImg, /DIMENSIONS)
  WINDOW, 0, XSIZE = 3*padDims[0], YSIZE = padDims[1], $
    TITLE = "Original, Eroded and Dilated Grayscale Images"
  TVSCL, img, 0
  erodeImg = ERODE(erodeImg, strucElem, /GRAY)
  TVSCL, erodeImg, 1
  dilateImg = DILATE(dilateImg, strucElem, /GRAY)
  TVSCL, dilateImg, 2
  WINDOW, 1, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(img)
  img = img GE 120
  erodeImg = REPLICATE(1B, dims[0]+2, dims[1]+2)
  erodeImg [1,1] = img
  dilateImg = REPLICATE(0B, dims[0]+2, dims[1]+2)
  dilateImg [1,1] = img
  dims = SIZE(erodeImg, /DIMENSIONS)
  WINDOW, 2, XSIZE = 3*dims[0], YSIZE = dims[1], $
    TITLE = "Original, Eroded and Dilated Binary Images"
  TVSCL, img, 0
  erodeImg = ERODE(erodeImg, strucElem)
  TVSCL, erodeImg, 1
  dilateImg = DILATE(dilateImg, strucElem)
  TVSCL, dilateImg, 2
  STOP
END
