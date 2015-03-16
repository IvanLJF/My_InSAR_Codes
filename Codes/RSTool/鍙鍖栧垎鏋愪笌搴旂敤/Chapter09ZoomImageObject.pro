; Chapter09ZoomImageObject.pro
PRO Chapter09ZoomImageObject
  file = FILEPATH('convec.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [248, 248]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'Grey Image')
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', image, /GREYSCALE)
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'Enlarged Area')
  oView -> SetProperty, VIEWPLANE_RECT = [0., 0., imageSize/2]
  oWindow -> Draw, oView
  OBJ_DESTROY, oView
END