; Chapter09GreyImageObject.pro
PRO Chapter09GreyImageObject
  file = FILEPATH('convec.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [248, 248]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'Gray Image')
  oView = OBJ_NEW('IDLgrView', $
  VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', image, /GREYSCALE)
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  OBJ_DESTROY, oView
END