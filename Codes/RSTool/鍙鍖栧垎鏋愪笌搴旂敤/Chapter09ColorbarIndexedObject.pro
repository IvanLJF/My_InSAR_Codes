; Chapter09ColorbarIndexedObject.pro
PRO Chapter09ColorbarIndexedObject
  worldtmpFile = FILEPATH('worldtmp.png', $
  SUBDIRECTORY = ['examples', 'demo', 'demodata'])
  worldtmpImage = READ_PNG(worldtmpFile)
  worldtmpSize = SIZE(worldtmpImage, /DIMENSIONS)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = [worldtmpSize[0], worldtmpSize[1]], $
    TITLE = 'Average World Temperature')
  oView = OBJ_NEW('IDLgrView', $
    VIEWPLANE_RECT = [0, 0, worldtmpSize[0], worldtmpSize[1]])
  oModel = OBJ_NEW('IDLgrModel')
  oPalette = OBJ_NEW('IDLgrPalette')
  oPalette -> LoadCT, 38
  oImage = OBJ_NEW('IDLgrImage', worldtmpImage, PALETTE = oPalette)
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  fillColor = BYTSCL(INDGEN(18))
  temperature = STRTRIM(FIX(((20.*fillColor)/51.) - 60), 2)
  x = [5., 40., 40., 5., 5.]
  y = [5., 5., 23., 23., 5.] + 5.
  offset = 18.*FINDGEN(19) + 5.
  oPolygon = OBJARR(18)
  oText = OBJARR(18)
  FOR i = 0, (N_ELEMENTS(oPolygon) - 1) DO BEGIN
    oPolygon[i] = OBJ_NEW('IDLgrPolygon', x, $
      y + offset[i], COLOR = fillColor[i], PALETTE = oPalette)
    oText[i] = OBJ_NEW('IDLgrText', temperature[i], $
      LOCATIONS = [x[0] + 3., y[0] + offset[i] + 3.], $
      COLOR = 255*(fillColor[i] LT 255), PALETTE = oPalette)
  ENDFOR
  oModel -> Add, oPolygon
  oModel -> Add, oText
  oWindow -> Draw, oView
  OBJ_DESTROY, [oView, oPalette]
END