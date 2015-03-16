; Chapter09MultiImageDirect.pro
PRO Chapter09MultiImageDirect
  file = FILEPATH('rose.jpg', SUBDIRECTORY = ['examples', 'data'])
  queryStatus = QUERY_IMAGE(file, imageInfo)
  imageSize = imageInfo.dimensions
  image = READ_IMAGE(file)
  imageDims = SIZE(image, /DIMENSIONS)
  ; 检测并计算颜色交叉类型
  interleaving = WHERE((imageDims NE imageSize[0]) AND $
                       (imageDims NE imageSize[1])) + 1
  DEVICE, DECOMPOSED = 1
  WINDOW, 0, XSIZE=imageSize[0],YSIZE=imageSize[1],TITLE='RGB Image'
  TV, image, TRUE = interleaving[0]
  variable = ''
;  READ, variable, PROMP='Enter 水平显示三色通道图像!'
  ; 提取颜色通道
  redChannel = (image[0, *, *])
  greenChannel = (image[1, *, *])
  blueChannel = (image[2, *, *])
;    redChannel = REFORM(image[0, *, *])
;  greenChannel = REFORM(image[1, *, *])
;  blueChannel = REFORM(image[2, *, *])
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 1, XSIZE = 3*imageSize[0], YSIZE = imageSize[1], $
             TITLE = 'The Channels of an RGB Image'
  TV, redChannel, 0
  TV, greenChannel, 1
  TV, blueChannel, 2
;  READ, variable, PROMP='Enter 垂直显示三色通道图像!'
  WINDOW, 2, XSIZE = imageSize[0], YSIZE = 3*imageSize[1], $
             TITLE = 'The Channels of an RGB Image'
  TV, redChannel, 0, 0
  TV, greenChannel, 0, imageSize[1]
  TV, blueChannel, 0, 2*imageSize[1]
;  READ, variable, PROMP='Enter 对角显示三色通道图像!'
    WINDOW, 3, XSIZE = 2*imageSize[0], YSIZE = 2*imageSize[1], $
             TITLE = 'The Channels of an RGB Image'
  ERASE, !P.COLOR       ; 设置白色背景
  TV, redChannel, 0, 0
  TV, greenChannel, imageSize[0]/2, imageSize[1]/2
  TV, blueChannel, imageSize[0], imageSize[1]
;  READ, variable, PROMP='Enter 清除所有窗口!'
;  WDELETE, 0, 1, 2, 3
END
