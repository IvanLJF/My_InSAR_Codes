; Chapter09RemovingNoiseWithWavelet.pro
PRO Chapter09RemovingNoiseWithWavelet
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)
displaySize = 2*imageSize
DEVICE, DECOMPOSED = 0
LOADCT, 0
WINDOW, 0, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
TITLE = 'Original Image and Power Spectrum'
TVSCL, CONGRID(image, displaySize[0], displaySize[1]), 0
waveletTransform = WTN(image, 20)
TVSCL, CONGRID(ALOG10(ABS(waveletTransform^2)), $
displaySize[0], displaySize[1]), 1
croppedTransform = FLTARR(imageSize[0], imageSize[1])
croppedTransform[0, 0] = waveletTransform[0:(imageSize[0]/2), $
0:(imageSize[1]/2)]
WINDOW, 1, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
TITLE = 'Power Spectrum of Cropped Transform and Results'
TVSCL, CONGRID(ALOG10(ABS(croppedTransform^2)), $
displaySize[0], displaySize[1]), 0, /NAN
inverseTransform = WTN(croppedTransform, 20, /INVERSE)
TVSCL, CONGRID(inverseTransform, displaySize[0], displaySize[1]), 1
END