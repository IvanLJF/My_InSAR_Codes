; Chapter09FindingLinesWithHough.pro
PRO Chapter09FindingLinesWithHough
  file = FILEPATH('rockland.png', SUBDIRECTORY = ['examples', 'data'])
  image = READ_PNG(file)
  imageSize = SIZE(image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 1
  WINDOW,0,XSIZE=imageSize[1],YSIZE=imageSize[2],TITLE='Rockland, Maine'
  TV, image, TRUE = 1
  intensity = REFORM(image[1, *, *])
  intensitySize = SIZE(intensity, /DIMENSIONS)
  mask = intensity GT 240
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 1, XSIZE = intensitySize[0], $
    YSIZE = intensitySize[1], TITLE = 'Mask to Locate Power Lines'
  TVSCL, mask
  transform = HOUGH(mask, RHO = rho, THETA = theta)
  displaySize = [256, 256]
  offset = displaySize/3
  TVLCT, red, green, blue, /GET
  TVLCT, 255 - red, 255 - green, 255 - blue
  WINDOW, 2, XSIZE = displaySize[0] + 1.5*offset[0], $
    YSIZE = displaySize[1] + 1.5*offset[1], TITLE = 'Hough Transform'
  TVSCL, CONGRID(transform, displaySize[0],$
    displaySize[1]), offset[0], offset[1]
  PLOT, theta, rho, /XSTYLE, /YSTYLE, $
    TITLE = 'Hough Transform', XTITLE = 'Theta', $
    YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
    POSITION = [offset[0], offset[1], displaySize[0] + offset[0], $
  displaySize[1] + offset[1]], CHARSIZE = 1.5, COLOR = !P.BACKGROUND
  transform = (TEMPORARY(transform) - 85) > 0
  WINDOW, 3, XSIZE = displaySize[0] + 1.5*offset[0], $
  YSIZE = displaySize[1]+1.5*offset[1], TITLE = 'Scaled Hough Transform'
  TVSCL, CONGRID(transform, displaySize[0], $
    displaySize[1]), offset[0], offset[1]
  PLOT, theta, rho, /XSTYLE, /YSTYLE, $
    TITLE = 'Scaled Hough Transform', XTITLE = 'Theta', $
    YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
    POSITION = [offset[0], offset[1], displaySize[0] + offset[0], $
    displaySize[1] + offset[1]], CHARSIZE = 1.5, COLOR = !P.BACKGROUND
  backprojection = HOUGH(transform, /BACKPROJECT, $
    RHO = rho, THETA=theta,NX=intensitySize[0], NY=intensitySize[1])
  WINDOW, 4, XSIZE = intensitySize[0], YSIZE = intensitySize[1], $
    TITLE = 'Resulting Power Lines'
  TVSCL, backprojection
END
