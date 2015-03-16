; Chapter09RGBImageObject.pro
PRO Chapter09RGBImageObject
  file = FILEPATH('rose.jpg', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_IMAGE(file, imageInfo)
  imageSize = imageInfo.dimensions
  image = READ_IMAGE(file)
  imageDims = SIZE(image, /DIMENSIONS)
  interleaving = WHERE((imageDims NE imageSize[0]) AND $
                       (imageDims NE imageSize[1]))
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
                     DIMENSIONS = imageSize, TITLE = 'RGB Image')
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oModel = OBJ_NEW('IDLgrModel')
  oImage = OBJ_NEW('IDLgrImage', image, INTERLEAVE = interleaving[0])
  oModel -> Add, oImage
  oView -> Add, oModel
  oWindow -> Draw, oView
  OBJ_DESTROY, oView
END