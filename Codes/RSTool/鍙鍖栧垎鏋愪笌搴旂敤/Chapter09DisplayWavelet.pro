; Chapter09DisplayWavelet.pro
PRO Chapter09DisplayWavelet
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
  powerSpectrum = ABS(waveletTransform)^2
  scaledPowerSpect = ALOG10(powerSpectrum)
  WINDOW, 1, TITLE = 'Wavelet Power Spectrum: Logarithmic Scale (surface)'
  SHADE_SURF, scaledPowerSpect, /XSTYLE, /YSTYLE, /ZSTYLE, $
    TITLE='Log-scaled Power Spectrum ',XTITLE = 'Horizontal Number', $
    YTITLE='Vertical Number',ZTITLE='Log(Abs(Amplitude^2))',CHARSIZE=1.5
  WINDOW, 2, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Wavelet Power Secptrum: Logarithmic Scale (image)'
  TVSCL, CONGRID(scaledPowerSpect, displaySize[0], displaySize[1])
END