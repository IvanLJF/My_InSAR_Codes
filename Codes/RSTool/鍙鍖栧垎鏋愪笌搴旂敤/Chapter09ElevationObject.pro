; Chapter09ElevationObject.pro
PRO Chapter09ElevationObject
  imageFile = FILEPATH('elev_t.jpg', SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, imageFile, image
  demFile = FILEPATH('elevbin.dat', SUBDIRECTORY = ['examples', 'data'])
  dem = READ_BINARY(demFile, DATA_DIMS = [64, 64])
  dem = CONGRID(dem, 128, 128, /INTERP)
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  WINDOW, 0, TITLE = 'Elevation Data'
  SHADE_SURF, dem
  oModel = OBJ_NEW('IDLgrModel')
  oView = OBJ_NEW('IDLgrView')
  oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, COLOR_MODEL = 0)
  oSurface = OBJ_NEW('IDLgrSurface', dem, STYLE = 2)
  oImage = OBJ_NEW('IDLgrImage', image, INTERLEAVE = 0, /INTERPOLATE)
  oSurface -> GetProperty, XRANGE = xr, YRANGE = yr, ZRANGE = zr
  xs = NORM_COORD(xr)  &  xs[0] = xs[0] - 0.5
  ys = NORM_COORD(yr)  &  ys[0] = ys[0] - 0.5
  zs = NORM_COORD(zr)  &  zs[0] = zs[0] - 0.5
  oSurface -> SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD=zs
  oSurface -> SetProperty, TEXTURE_MAP = oImage, COLOR = [255, 255, 255]
  oModel -> Add, oSurface
  oView -> Add, oModel
  oModel -> ROTATE, [1, 0, 0], -90
  oModel -> ROTATE, [0, 1, 0], 30
  oModel -> ROTATE, [1, 0, 0], 30
  oWindow -> Draw, oView
  XOBJVIEW, oModel, /BLOCK, SCALE = 1
  OBJ_DESTROY, [oView, oImage]
END