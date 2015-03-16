; Chapter09ColorbarRGBObject.pro
PRO Chapter09ColorbarRGBObject
  cosmicFile = FILEPATH('glowing_gas.jpg', $
  SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, cosmicFile, cosmicImage
  cosmicSize = SIZE(cosmicImage, /DIMENSIONS)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = [cosmicSize[1], cosmicSize[2]], $
    TITLE = 'glowing_gas.jpg')
  oView = OBJ_NEW('IDLgrView', $
    VIEWPLANE_RECT = [0., 0., cosmicSize[1], cosmicSize[2]])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', cosmicImage, $
    INTERLEAVE = 0, DIMENSIONS = [cosmicSize[1], cosmicSize[2]])
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  fillColor = [[0, 0, 0], $ ; black
  [255, 0, 0], $ ; red
  [255, 255, 0], $ ; yellow
  [0, 255, 0], $ ; green
  [0, 255, 255], $ ; cyan
  [0, 0, 255], $ ; blue
  [255, 0, 255], $ ; magenta
  [255, 255, 255]] ; white
  x = [5., 25., 25., 5., 5.]
  y = [5., 5., 25., 25., 5.] + 5.
  offset = 20.*FINDGEN(9) + 5.
  x_border = [x[0] + offset[0], x[1] + offset[7], $
    x[2] + offset[7], x[3] + offset[0], x[4] + offset[0]]
  oPolygon = OBJARR(8)
  FOR i = 0, (N_ELEMENTS(oPolygon) - 1) DO oPolygon[i] = $
    OBJ_NEW('IDLgrPolygon', x + offset[i], y, COLOR = fillColor[*, i])
  z = [0.001, 0.001, 0.001, 0.001, 0.001]
  oPolyline = OBJ_NEW('IDLgrPolyline', x_border, y, z, $
    COLOR = [255, 255, 255])
  oModel -> Add, oPolygon
  oModel -> Add, oPolyline
  oWindow -> Draw, oView
  OBJ_DESTROY, oView
END