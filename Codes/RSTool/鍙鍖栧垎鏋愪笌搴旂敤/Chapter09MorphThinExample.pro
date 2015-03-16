; Chapter09MorphThinExample.pro
PRO Chapter09MorphThinExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('pollens.jpg', $
    SUBDIRECTORY = ['examples', 'demo', 'demodata'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
    TITLE = 'Original, Binary and Thinned Images'
  TVSCL, img, 0
  binaryImg = img GE 140
  TVSCL, binaryImg, 1
  h0 = [[0b, 0, 0], [0, 1, 0], [1, 1, 1]]
  m0 = [[1b, 1, 1], [0, 0, 0], [0, 0, 0]]
  h1 = [[0b, 0, 0], [1, 1, 0], [1, 1, 0]]
  m1 = [[0b, 1, 1], [0, 0, 1], [0, 0, 0]]
  h2 = [[1b, 0, 0], [1, 1, 0], [1, 0, 0]]
  m2 = [[0b, 0, 1], [0, 0, 1], [0, 0, 1]]
  h3 = [[1b, 1, 0], [1, 1, 0], [0, 0, 0]]
  m3 = [[0b, 0, 0], [0, 0, 1], [0, 1, 1]]
  h4 = [[1b, 1, 1], [0, 1, 0], [0, 0, 0]]
  m4 = [[0b, 0, 0], [0, 0, 0], [1, 1, 1]]
  h5 = [[0b, 1, 1], [0, 1, 1], [0, 0, 0]]
  m5 = [[0b, 0, 0], [1, 0, 0], [1, 1, 0]]
  h6 = [[0b, 0, 1], [0, 1, 1], [0, 0, 1]]
  m6 = [[1b, 0, 0], [1, 0, 0], [1, 0, 0]]
  h7 = [[0b, 0, 0], [0, 1, 1], [0, 1, 1]]
  m7 = [[1b, 1, 0], [1, 0, 0], [0, 0, 0]]
  bCont = 1b
  iIter = 1
  thinImg = binaryImg
  WHILE bCont EQ 1b DO BEGIN
    PRINT,'Iteration: ', iIter
    inputImg = thinImg
    thinImg = MORPH_THIN(inputImg, h0, m0)
    thinImg = MORPH_THIN(thinImg, h1, m1)
    thinImg = MORPH_THIN(thinImg, h2, m2)
    thinImg = MORPH_THIN(thinImg, h3, m3)
    thinImg = MORPH_THIN(thinImg, h4, m4)
    thinImg = MORPH_THIN(thinImg, h5, m5)
    thinImg = MORPH_THIN(thinImg, h6, m6)
    thinImg = MORPH_THIN(thinImg, h7, m7)
    TVSCL, thinImg, 2
    WAIT, 1
    bCont = MAX(inputImg - thinImg)
    iIter = iIter + 1
  ENDWHILE
  TVSCL, 1 - thinImg, 3
END