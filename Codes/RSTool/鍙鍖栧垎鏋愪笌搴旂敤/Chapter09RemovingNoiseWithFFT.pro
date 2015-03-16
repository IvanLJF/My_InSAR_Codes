; Chapter09RemovingNoiseWithFFT.pro
PRO Chapter09RemovingNoiseWithFFT
  imageSize = [64, 64]
  file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  displaySize = 2*imageSize
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Original Image and Power Spectrum'
  TVSCL, CONGRID(image, displaySize[0], displaySize[1]), 0
  ffTransform = FFT(image)
  center = imageSize/2 + 1
  fftShifted = SHIFT(ffTransform, center)
  interval = 1.
  hFrequency = INDGEN(imageSize[0])
  hFrequency[center[0]]=center[0] - imageSize[0]+FINDGEN(center[0]-2)
  hFrequency = hFrequency/(imageSize[0]/interval)
  hFreqShifted = SHIFT(hFrequency, -center[0])
  vFrequency = INDGEN(imageSize[1])
  vFrequency[center[1]]=center[1] - imageSize[1]+FINDGEN(center[1]-2)
  vFrequency = vFrequency/(imageSize[1]/interval)
  vFreqShifted = SHIFT(vFrequency, -center[1])
  powerSpectrum = ABS(fftShifted)^2
  scaledPowerSpect = ALOG10(powerSpectrum)
  TVSCL, CONGRID(scaledPowerSpect, displaySize[0], displaySize[1]), 1
  scaledPS0 = scaledPowerSpect - MAX(scaledPowerSpect)
  WINDOW, 1, TITLE = 'Power Spectrum Scaled to a Zero Maximum'
  SHADE_SURF, scaledPS0, hFreqShifted, vFreqShifted, $
    /XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Zero Maximum Power Spectrum', $
    XTITLE = 'Horizontal Frequency', YTITLE = 'Vertical Frequency', $
    ZTITLE = 'Max-Scaled(Log(Power Spectrum))', CHARSIZE = 1.5
  mask = REAL_PART(scaledPS0) GT -5.25
  maskedTransform = fftShifted*mask
  WINDOW, 2, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
    TITLE = 'Power Spectrum of Masked Transform and Results'
  TVSCL, CONGRID(ALOG10(ABS(maskedTransform^2)), $
    displaySize[0], displaySize[1]), 0, /NAN
  maskedShiftedTrans = SHIFT(maskedTransform, -center)
  inverseTransform = REAL_PART(FFT(maskedShiftedTrans, /INVERSE))
  TVSCL, CONGRID(inverseTransform, displaySize[0], displaySize[1]), 1
  STOP
END