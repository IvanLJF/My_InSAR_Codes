; Chapter09MapOnSphereObject.pro
PRO Chapter09MapOnSphereObject
  file = FILEPATH('worldelv.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [360, 360])
  MESH_OBJ, 4, vertices, polygons, REPLICATE(0.25, 101, 101)
  oModel = OBJ_NEW('IDLgrModel')
  oPalette = OBJ_NEW('IDLgrPalette')
  oPalette -> LoadCT, 33
  oPalette -> SetRGB, 255,255,255,255
  oImage = OBJ_NEW('IDLgrImage', image, PALETTE = oPalette)
  vector = FINDGEN(101)/100.
  texure_coordinates = FLTARR(2, 101, 101)
  texure_coordinates[0, *, *] = vector # REPLICATE(1., 101)
  texure_coordinates[1, *, *] = REPLICATE(1., 101) # vector
  oPolygons = OBJ_NEW('IDLgrPolygon', SHADING = 1, $
    DATA = vertices, POLYGONS = polygons, COLOR = [255,255,255], $
    TEXTURE_COORD=texure_coordinates,TEXTURE_MAP=oImage,/TEXTURE_INTERP)
  oModel -> ADD, oPolygons
  oModel -> ROTATE, [1, 0, 0], -90
  oModel -> ROTATE, [0, 1, 0], -90
  XOBJVIEW, oModel, /BLOCK
  OBJ_DESTROY, [oModel, oImage, oPalette]
END