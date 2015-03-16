; Chapter09PaddedImage.pro
PRO Chapter09PaddedImage
  earth = READ_PNG (FILEPATH ('avhrr.png', $
    SUBDIRECTORY = ['examples', 'data']), R, G, B)
  TVLCT, R, G, B
  maxColor = !D.TABLE_SIZE - 1
  TVLCT, 255, 255, 255, maxColor
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  earthSize = SIZE(earth, /DIMENSIONS)
  paddedEarth = REPLICATE(BYTE(maxColor), earthSize[0] + 20, $
  earthSize[1] + 40)
  paddedEarth [10,10] = earth
  WINDOW, 0, XSIZE = earthSize[0] + 20, YSIZE = earthSize[1] + 40
  TV, paddedEarth
  x = (earthSize[0]/2) + 10
  y = earthSize[1] + 15
  XYOUTS, x, y, 'World Map', ALIGNMENT = 0.5, COLOR = 0, /DEVICE

END