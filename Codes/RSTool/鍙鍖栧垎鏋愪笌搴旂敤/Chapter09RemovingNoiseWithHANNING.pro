; Chapter09RemovingNoiseWithHANNING.pro
PRO Chapter09RemovingNoiseWithHANNING
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [64, 64]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW,0,XSIZE=displaySize[0],YSIZE=displaySize[1],TITLE='Original Image'
  TVSCL, CONGRID(image, displaySize[0], displaySize[1])
  transform = SHIFT(FFT(image), (imageSize[0]/2), (imageSize[1]/2))
  WINDOW, 1, TITLE = 'Surface of Forward FFT'
  SHADE_SURF, (2.*ALOG10(ABS(transform))), $
    /XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Power Spectrum', $
    XTITLE = 'Mode', YTITLE = 'Mode', ZTITLE='Amplitude',CHARSIZE=1.5
  mask = HANNING(imageSize[0], imageSize[1])
  maskedTransform = transform*mask
  WINDOW, 2, TITLE = 'Surface of Filtered FFT'
  SHADE_SURF, (2.*ALOG10(ABS(maskedTransform))), $
    /XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Masked Power Spectrum', $
    XTITLE = 'Mode', YTITLE = 'Mode', ZTITLE='Amplitude',CHARSIZE=1.5
  inverseTransform = FFT(SHIFT(maskedTransform, $
    (imageSize[0]/2), (imageSize[1]/2)), /INVERSE)
  WINDOW, 3, XSIZE = displaySize[0], $
    YSIZE = displaySize[1], TITLE = 'Hanning Filtered Image'
  TVSCL, CONGRID(REAL_PART(inverseTransform), $
    displaySize[0], displaySize[1])
END