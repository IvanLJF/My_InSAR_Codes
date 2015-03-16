; Chapter09MorphHitorMissExample.pro
PRO Chapter09MorphHitorMissExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('r_seeberi.jpg', SUBDIRECTORY=['examples','data'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
  padImg[5, 5] = img
  dims = SIZE(padImg, /DIMENSIONS)
  WINDOW, 0, XSIZE=3*dims[0], YSIZE=2*dims[1], $
    TITLE='Displaying Hit-or-Miss Matches'
  TVSCL, padImg, 0
  radstr = 7
  strucElem = SHIFT(DIST(2*radstr+1), radstr, radstr) LE radstr
  openImg = MORPH_OPEN(padImg, strucElem, /GRAY)
  TVSCL, openImg, 1
  WINDOW, 2, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(openImg)
  threshImg = openImg GE 150
  WSET, 0  &  TVSCL, threshImg, 2
  radhit = 7  &  radmiss = 23
  hit = SHIFT(DIST(2*radhit+1), radhit, radhit) LE radhit
  miss = SHIFT(DIST(2*radmiss+1), radmiss, radmiss) GE radmiss
  matches = MORPH_HITORMISS(threshImg, hit, miss)
  dmatches = DILATE(matches, hit)
  TVSCL, dmatches, 3
  padImg [WHERE (dmatches EQ 1)] = 1
  TVSCL, padImg, 4
END