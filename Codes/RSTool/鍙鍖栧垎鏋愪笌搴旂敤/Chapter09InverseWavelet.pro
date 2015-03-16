; Chapter09InverseWavelet.pro
PRO Chapter09InverseWavelet
  imageSize = [64, 64]
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  waveletTransform = WTN(image, 20)
  powerSpectrum = ABS(waveletTransform)^2
  scaledPowerSpectrum = ALOG10(powerSpectrum)
  WINDOW, 0, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Power Spectrum Image'
  TVSCL, CONGRID(scaledPowerSpectrum, displaySize[0], displaySize[1])
  waveletInverse = WTN(waveletTransform, 20, /INVERSE)
  WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Wavelet: Inverse Transform'
  TVSCL, CONGRID(waveletInverse, displaySize[0], displaySize[1])
END