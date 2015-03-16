; Chapter09WatershedExample.pro
PRO Chapter09WatershedExample
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  file = FILEPATH('meteor_crater.jpg',SUBDIRECTORY=['examples','data'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  WINDOW, 0, XSIZE = 3*dims[0], YSIZE = 2*dims[1], $
    TITLE = 'Defining Boundaries with WATERSHED'
  TVSCL, img, 0
  XYOUTS, 50, 444, 'Original Image',Alignment=.5,/DEVICE, COLOR = 255
  smoothImg = SMOOTH(img, 7, /EDGE_TRUNCATE)
  TVSCL, smoothImg, 1
  XYOUTS, (60 + dims[0]), 444, 'Smoothed Image', $
    ALIGNMENT = .5, /DEVICE, COLOR = 255
  radius = 3
  strucElem = SHIFT(DIST(2*radius+1), radius, radius) LE radius
  tophatImg = MORPH_TOPHAT(smoothImg, strucElem)
  TVSCL, tophatImg, 2
  XYOUTS, (60 + 2*dims[0]), 444, 'Top-hat Image', $
    ALIGNMENT = .5, /DEVICE, COLOR = 255
  WINDOW, 2, XSIZE = 400, YSIZE = 300
  PLOT, HISTOGRAM(smoothImg)
  tophatImg = tophatImg < 70
  WSET, 0
  TVSCL, tophatImg
  XYOUTS, 75, 210, 'Stretched Top-hat Image', $
    ALIGNMENT = .5, /DEVICE, COLOR = 255
  watershedImg = WATERSHED(tophatImg, CONNECTIVITY = 8)
  TVSCL, watershedImg, 4
  XYOUTS, (70 + dims[0]), 210, 'Watershed Image', $
    ALIGNMENT = .5, /DEVICE, COLOR = 255
  img [WHERE (watershedImg EQ 0)] = 0
  TVSCL, img, 5
  XYOUTS, (70 + 2*dims[0]), 210, 'Watershed Overlay', $
    ALIGNMENT = .5, /DEVICE, COLOR = 255
END