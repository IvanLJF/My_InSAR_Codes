; Chapter09RGBImageDirect.pro
PRO Chapter09RGBImageDirect
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
END