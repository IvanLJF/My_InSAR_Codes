; Chapter09MultiImageObject.pro
PRO Chapter09MultiImageObject
  file = FILEPATH('rose.jpg', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_IMAGE(file, imageInfo)
  imageSize = imageInfo.dimensions
  image = READ_IMAGE(file)
  redChannel = REFORM(image[0, *, *])
  greenChannel = REFORM(image[1, *, *])
  blueChannel = REFORM(image[2, *, *])
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = imageSize*[3, 1],TITLE='The Channels of an RGB Image')
;  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize])
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 3, 1])
  oModel = OBJ_NEW('IDLgrModel')
  oRedChannel = OBJ_NEW('IDLgrImage', redChannel)
  oGreenChannel = OBJ_NEW('IDLgrImage', greenChannel,$
                           LOCATION = [imageSize[0], 0])
  oBlueChannel = OBJ_NEW('IDLgrImage', blueChannel, $
                          LOCATION = [2*imageSize[0], 0])
  oModel -> Add, oRedChannel
  oModel -> Add, oGreenChannel
  oModel -> Add, oBlueChannel
  oView -> Add, oModel
  oWindow -> Draw, oView
  variable = ''
;  READ, variable, PROMP='Enter 垂直显示三色通道图像!'
  WAIT, 5
  OBJ_DESTROY, oWindow
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = imageSize*[1, 3],TITLE='The Channels of an RGB Image')
  oView -> SetProperty, $
           VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 1, 3]
  oGreenChannel -> SetProperty, LOCATION = [0, imageSize[1]]
  oBlueChannel -> SetProperty, LOCATION = [0, 2*imageSize[1]]
  oWindow -> Draw, oView
;  READ, variable, PROMP='Enter 对角显示三色通道图像!'
  WAIT, 5
  OBJ_DESTROY, oWindow
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = imageSize*[2, 2],TITLE='The Channels of an RGB Image')
  oView -> SetProperty, $
           VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 2, 2]
  oGreenChannel -> SetProperty, $
                   LOCATION = [imageSize[0]/2, imageSize[1]/2]
  oBlueChannel -> SetProperty, $
                   LOCATION = [imageSize[0], imageSize[1]]
  oWindow -> Draw, oView
;  READ, variable, PROMP='Enter 删除所有窗口!'
  WAIT, 5
  OBJ_DESTROY, oView
  OBJ_DESTROY, oWindow
END