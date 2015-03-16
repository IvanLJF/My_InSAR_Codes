; Chapter09IndexImageObject.pro
PRO Chapter09IndexImageObject
  file = FILEPATH('avhrr.png', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_IMAGE(file, imageInfo)
  imageSize = imageInfo.dimensions
  image = READ_IMAGE(file, red, green, blue)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
                     DIMENSIONS = imageSize, TITLE = 'Index Image')
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oPalette = OBJ_NEW('IDLgrPalette', red, green, blue)
  oImage = OBJ_NEW('IDLgrImage', image, PALETTE = oPalette)
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  oCbWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = [256, 48], TITLE = 'Original Color Table')
  oCbView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0., 0., 256., 48.])
  oCbModel = OBJ_NEW('IDLgrModel')
  oColorbar = OBJ_NEW('IDLgrColorbar', PALETTE = oPalette, $
                       DIMENSIONS = [256, 16], SHOW_AXIS = 1)
  oCbModel -> Add, oColorbar
  oCbView -> Add, oCbModel
  oCbWindow -> Draw, oCbView
  variable = ''
  READ, variable, PROMP='Next Image!'
  oPalette -> LoadCT, 27
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'An Indexed Image')
  oWindow -> Draw, oView
  oCbWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
              DIMENSIONS = [256, 48], TITLE = 'EOS B Color Table')
  oCbWindow -> Draw, oCbView
  OBJ_DESTROY, oView
  OBJ_DESTROY, oCbView
  READ, variable, PROMP='ENTER TO DESTROY All!'
  OBJ_DESTROY, oCbWindow
END