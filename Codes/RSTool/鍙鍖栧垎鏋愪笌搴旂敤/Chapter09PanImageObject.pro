; pro  Chapter09PanImageObject.pro
PRO Chapter09PanImageObject
  file = FILEPATH('nyny.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [768, 512]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  imageSize = [256, 256]
  image = CONGRID(image, imageSize[0], imageSize[1])
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'Grey Image')
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', image, /GREYSCALE)
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
            DIMENSIONS = imageSize, TITLE = 'Pan Image')
  viewplane = [0., 0., imageSize/2]
  oView -> SetProperty, VIEWPLANE_RECT = viewplane
  oWindow -> Draw, oView
  FOR i = 0, ((imageSize[0]/2) - 1) DO BEGIN
      viewplane = viewplane + [1., 0., 0., 0.]
      oView -> SetProperty, VIEWPLANE_RECT = viewplane
      oWindow -> Draw, oView
  ENDFOR
  OBJ_DESTROY, oView
END