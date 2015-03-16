; Chapter09ForwardFFT.pro
PRO Chapter09ForwardFFT
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)
displaySize = 2*imageSize
DEVICE, DECOMPOSED = 0
LOADCT, 0
WINDOW, 0, XSIZE = displaySize[0], $
YSIZE = displaySize[1], TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], displaySize[1])
ffTransform = FFT(image)
center = imageSize/2 + 1
fftShifted = SHIFT(ffTransform, center)
interval = 1.
hFrequency = INDGEN(imageSize[0])
hFrequency[center[0]] = center[0]-imageSize[0]+FINDGEN(center[0] - 2)
hFrequency = hFrequency/(imageSize[0]/interval)
hFreqShifted = SHIFT(hFrequency, -center[0])
vFrequency = INDGEN(imageSize[1])
vFrequency[center[1]] = center[1]-imageSize[1]+FINDGEN(center[1] - 2)
vFrequency = vFrequency/(imageSize[1]/interval)
vFreqShifted = SHIFT(vFrequency, -center[1])
WINDOW, 1, TITLE = 'FFT: Transform'
SHADE_SURF, fftShifted, hFreqShifted, vFreqShifted, $
/XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Transform of Image', $
XTITLE = 'Horizontal Frequency', YTITLE = 'Vertical Frequency', $
ZTITLE = 'Amplitude', CHARSIZE = 1.5
WINDOW, 2, TITLE = 'FFT: Transform (Closer Look)'
SHADE_SURF, fftShifted, hFreqShifted, vFreqShifted, $
/XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Transform of Image', $
XTITLE = 'Horizontal Frequency', YTITLE = 'Vertical Frequency', $
ZTITLE = 'Amplitude', CHARSIZE = 1.5, ZRANGE = [0., 5.]
END