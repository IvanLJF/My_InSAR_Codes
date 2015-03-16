; Chapter09RemoveBridges.pro
PRO Chapter09RemoveBridges
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  xsize = 768  &  ysize = 512
  img = READ_BINARY(FILEPATH('nyny.dat', $
    SUBDIRECTORY = ['examples', 'data']), DATA_DIMS = [xsize, ysize])
  ; 增强图像对比度，然后显示图像
  img = BYTSCL(img)  &  WINDOW, 0  &  TVSCL, img
  ; 创建阈值屏蔽图像
  maskImg = img LT 70
  ; 创建正方形结构元素
  side = 3
  strucElem = DIST(side) LE side
  maskImg = MORPH_OPEN(maskImg, strucElem)
  maskImg = MORPH_CLOSE(maskImg, strucElem)
  WINDOW, 1, title='Mask After Opening and Closing'
  TVSCL, maskImg
  ; 提取屏蔽图像区域
  labelImg = LABEL_REGION(maskImg)
  ; 移去所有背景和屏蔽图像区域
  regions = labelImg[WHERE(labelImg NE 0)]
  mainRegion = WHERE(HISTOGRAM(labelImg) EQ MAX(HISTOGRAM(regions)))
  maskImg = labelImg EQ mainRegion[0]
  ; 显示屏蔽图像
  Window, 3, TITLE = 'Final Masked Image'
  TVSCL, maskImg
  newImg = MORPH_OPEN(img, strucElem, /GRAY)
  newImg[WHERE(maskImg EQ 0)] = img[WHERE(maskImg EQ 0)]
  PRINT, 'Hit any key to end program.'
  WINDOW, 2, XSIZE = xsize, YSIZE = ysize, TITLE = 'Hit Any Key to End'
  ; 闪烁对比原图像和分割图像
  FLICK, img, newImg
END