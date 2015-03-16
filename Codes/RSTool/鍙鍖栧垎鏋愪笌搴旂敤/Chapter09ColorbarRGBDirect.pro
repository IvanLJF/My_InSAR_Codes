; Chapter09ColorbarRGBDirect.pro
PRO Chapter09ColorbarRGBDirect
  cosmicFile = FILEPATH('glowing_gas.jpg', $
  SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, cosmicFile, cosmicImage
  cosmicSize = SIZE(cosmicImage, /DIMENSIONS)
  DEVICE, DECOMPOSED = 1
  WINDOW, 0, TITLE = 'glowing_gas.jpg', $
  XSIZE = cosmicSize[1], YSIZE = cosmicSize[2]
  TV, cosmicImage, TRUE = 1
  red = BYTARR(8) & green = BYTARR(8) & blue = BYTARR(8)
  red[0] = 0 & green[0] = 0 & blue[0] = 0 ; black
  red[1] = 255 & green[1] = 0 & blue[1] = 0 ; red
  red[2] = 255 & green[2] = 255 & blue[2] = 0 ; yellow
  red[3] = 0 & green[3] = 255 & blue[3] = 0 ; green
  red[4] = 0 & green[4] = 255 & blue[4] = 255 ; cyan
  red[5] = 0 & green[5] = 0 & blue[5] = 255 ; blue
  red[6] = 255 & green[6] = 0 & blue[6] = 255 ; magenta
  red[7] = 255 & green[7] = 255 & blue[7] = 255 ; white
  fillColor = red + (256L*green) + ((256L^2)*blue)
  x = [5., 25., 25., 5., 5.]
  y = [5., 5., 25., 25., 5.] + 5.
  offset = 20.*FINDGEN(9) + 5.
  x_border = [x[0] + offset[0], x[1] + offset[7], $
    x[2] + offset[7], x[3] + offset[0], x[4] + offset[0]]
  FOR i = 0, (N_ELEMENTS(fillColor) - 1) DO POLYFILL, $
    x + offset[i], y, COLOR = fillColor[i], /DEVICE
  PLOTS, x_border, y, /DEVICE, COLOR = fillColor[7]
END