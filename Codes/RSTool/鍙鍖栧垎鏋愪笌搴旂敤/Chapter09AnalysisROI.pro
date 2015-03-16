; Chapter09AnalysisROI.pro
PRO Chapter09AnalysisROI
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  img = READ_PNG(FILEPATH('mineral.png', $
    SUBDIRECTORY = ['examples', 'data']))
  dims = SIZE(img, /DIMENSIONS)
  WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
  TVSCL, img, 0
  threshImg = (img LT 50)
  strucElem = REPLICATE(1, 3, 3)
  threshImg = ERODE(DILATE(TEMPORARY(threshImg), strucElem), strucElem)
  CONTOUR, threshImg, LEVEL = 1, XMARGIN = [0, 0], YMARGIN = [0, 0], $
    /NOERASE, PATH_INFO = pathInfo, PATH_XY = pathXY, $
    XSTYLE = 5, YSTYLE = 5, /PATH_DATA_COORDS
  WINDOW, 2, XSIZE = dims[0], YSIZE = dims[1]
  TVSCL, img
  LOADCT, 12
  FOR I = 0, (N_ELEMENTS(pathInfo) - 1 ) DO BEGIN
    line=[LINDGEN(pathInfo(I).N), 0]
    oROI=OBJ_NEW('IDLanROI',(pathXY(*,pathInfo(I).OFFSET+line))[0,*],$
      (pathXY(*,pathInfo(I).OFFSET + line))[1, *])
    DRAW_ROI, oROI, COLOR = 80
    maskResult = oROI -> ComputeMask(DIMENSIONS = [dims[0], dims[1]])
    IMAGE_STATISTICS, img, MASK = maskResult, COUNT = maskArea
    ROIStats = oROI->ComputeGeometry(AREA=geomArea,PERIMETER=perimeter,$
    SPATIAL_SCALE = [1.2, 1.2, 1.0])
    PRINT, 'Region''s mask area =', FIX(maskArea), ' pixels'
    PRINT, 'Region''s geometric area =', FIX(geomArea), ' mm'
    PRINT, 'Region''s perimeter = ', FIX(perimeter), ' mm'
    OBJ_DESTROY, oROI
  ENDFOR
END