; Chapter09InverseFFT.pro
PRO Chapter09InverseFFT
  imageSize = [64, 64]
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  ffTransform = FFT(image)
  center = imageSize/2 + 1
  fftShifted = SHIFT(ffTransform, center)
  powerSpectrum = ABS(fftShifted)^2
  scaledPowerSpect = ALOG10(powerSpectrum)
  WINDOW, 0, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Power Spectrum Image'
  TVSCL, CONGRID(scaledPowerSpect, displaySize[0], displaySize[1])
  fftInverse = REAL_PART(FFT(ffTransform, /INVERSE))
  WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'FFT: Inverse Transform'
  TVSCL, CONGRID(fftInverse, displaySize[0], displaySize[1])
END