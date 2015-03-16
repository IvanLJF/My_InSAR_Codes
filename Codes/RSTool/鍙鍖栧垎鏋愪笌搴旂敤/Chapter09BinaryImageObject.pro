; Chapter09BinaryImageObject.pro
PRO Chapter09BinaryImageObject
  file=FILEPATH('continent_mask.dat',SUBDIRECTORY=['examples','data'])
  imageSize = [360, 360]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, DIMENSIONS = imageSize,$
                   TITLE = 'Binary Image')
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', image)
  oModel -> Add, oImage
  oView -> Add, oModel
  oImage -> SetProperty, DATA = BYTSCL(image)
  oWindow -> Draw, oView
  OBJ_DESTROY, oView
END