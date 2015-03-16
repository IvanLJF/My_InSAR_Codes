; Chapter09ReverseImage.pro
PRO Chapter09ReverseImage
  image = READ_DICOM (FILEPATH('mr_knee.dcm', $
    SUBDIRECTORY = ['examples', 'data']))
  imgSize = SIZE (image, /DIMENSIONS)
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  flipHorzImg = REVERSE(image, 1)
  flipVertImg = REVERSE(image, 2)
  WINDOW, 0, XSIZE = 2*imgSize[0], YSIZE = 2*imgSize[1], $
    TITLE = 'Original (Top) & Flipped Images (Bottom)'
  TV, image, 0
  TV, flipHorzImg, 2
  TV, flipVertImg, 3
END