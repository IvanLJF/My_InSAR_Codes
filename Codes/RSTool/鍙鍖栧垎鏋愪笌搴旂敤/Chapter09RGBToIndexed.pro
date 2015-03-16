; Chapter09RGBToIndexed.pro
PRO Chapter09RGBToIndexed
  elev_tFile = FILEPATH('elev_t.jpg',SUBDIRECTORY=['examples','data'])
  READ_JPEG, elev_tFile, elev_tImage
  elev_tSize = SIZE(elev_tImage, /DIMENSIONS)
  DEVICE, DECOMPOSED = 1
  WINDOW, 0,TITLE='elev_t.jpg',XSIZE=elev_tSize[1],YSIZE=elev_tSize[2]
  TV, elev_tImage, TRUE = 1
  DEVICE, DECOMPOSED = 0
  imageIndexed = COLOR_QUAN(elev_tImage, 1, red, green, blue)
  WRITE_PNG, 'elev_t.png', imageIndexed, red, green, blue
END