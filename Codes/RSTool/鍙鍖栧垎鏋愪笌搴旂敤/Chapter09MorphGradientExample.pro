; Chapter09MorphGradientExample.pro
PRO Chapter09MorphGradientExample
; Prepare the display device
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0
; Select and read in the file.
file = FILEPATH('marsglobe.jpg', SUBDIRECTORY = ['examples', 'data'] )
READ_JPEG, file, image, /GRAYSCALE
; Get the image size, create a window and display the
; image.
dims = SIZE(image, /DIMENSIONS)
WINDOW, 0, XSIZE =2*dims[0], YSIZE = 2*dims[1], $
TITLE = 'Original and MORPH_GRADIENT Images'
TVSCL, image, 0
; Define the structuring element, apply the
; morphological operator and display the image.
radius = 1
strucElem = SHIFT(DIST(2*radius+1), $
radius, radius) LE radius
morphImg = MORPH_GRADIENT(image, strucElem)
TVSCL, morphImg, 2
; Display an inverse intesity histogram to determine
; stretch intensity value.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(1 - image)
; Display inverse of stretched gradient image.
WSET, 0
TVSCL, 1 - (morphImg < 87 ), 3
END