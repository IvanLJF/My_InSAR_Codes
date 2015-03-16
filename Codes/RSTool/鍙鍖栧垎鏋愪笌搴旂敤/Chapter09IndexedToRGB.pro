; Chapter09IndexedToRGB.pro
PRO Chapter09IndexedToRGB
  convecFile = FILEPATH('convec.dat',SUBDIRECTORY=['examples','data'])
  convecSize = [248, 248]
  convecImage = READ_BINARY(convecFile, DATA_DIMS = convecSize)
  DEVICE, DECOMPOSED = 0
  LOADCT, 27
  WINDOW, 0,TITLE = 'convec.dat',XSIZE=convecSize[0],YSIZE=convecSize[1]
  TV, convecImage
  TVLCT, red, green, blue, /GET
  imageRGB = BYTARR(3, convecSize[0], convecSize[1])
  ; 创建RGB颜色分量
  imageRGB[0, *, *] = red[convecImage]
  imageRGB[1, *, *] = green[convecImage]
  imageRGB[2, *, *] = blue[convecImage]
  WRITE_JPEG, 'convec.jpg', imageRGB, TRUE = 1, QUALITY = 100.
END