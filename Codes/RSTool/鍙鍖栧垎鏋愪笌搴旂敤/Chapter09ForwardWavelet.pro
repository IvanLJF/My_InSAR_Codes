; Chapter09ForwardWavelet.pro
PRO Chapter09ForwardWavelet
  imageSize = [64, 64]
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0, XSIZE = displaySize[0], $
  YSIZE = displaySize[1], TITLE = 'Original Image'
  TVSCL, CONGRID(image, displaySize[0], displaySize[1])
  waveletTransform = WTN(image, 20)
  WINDOW, 1, TITLE = 'Wavelet: Transform'
  SHADE_SURF, waveletTransform, /XSTYLE, /YSTYLE, $
    /ZSTYLE, TITLE = 'Transform of Image', XTITLE='Horizontal Number',$
    YTITLE = 'Vertical Number', ZTITLE = 'Amplitude', CHARSIZE = 1.5
  WINDOW, 2, TITLE = 'Wavelet: Transform (Closer Look)'
  SHADE_SURF, waveletTransform, /XSTYLE, /YSTYLE, $
    /ZSTYLE, TITLE = 'Transform of Image', XTITLE='Horizontal Number',$
    YTITLE = 'Vertical Number', ZTITLE = 'Amplitude',CHARSIZE = 1.5, $
ZRANGE = [0., 200.]
END