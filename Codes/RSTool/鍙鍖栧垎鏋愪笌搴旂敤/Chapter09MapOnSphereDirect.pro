; Chapter09MapOnSphereDirect.pro
PRO Chapter09MapOnSphereDirect
  file = FILEPATH('worldelv.dat', SUBDIRECTORY = ['examples', 'data'])
  image = READ_BINARY(file, DATA_DIMS = [360, 360])
  DEVICE, DECOMPOSED = 0
  LOADCT, 33
  TVLCT, 255, 255, 255, !D.TABLE_SIZE - 1
  WINDOW, 0, XSIZE = 360, YSIZE = 360
  TVSCL, image
  MESH_OBJ, 4, vertices, polygons, REPLICATE(0.25, 360, 360), /CLOSED
  WINDOW, 2, XSIZE = 512, YSIZE = 512
  SCALE3, XRANGE=[-0.25,0.25], YRANGE=[-0.25,0.25], ZRANGE=[-0.25,0.25],AX=0, AZ=-90
  SET_SHADING, LIGHT = [-0.5, 0.5, 2.0]
  !P.BACKGROUND = !P.COLOR
  TVSCL, POLYSHADE(vertices, polygons, SHADES = image, /T3D)
  !P.BACKGROUND = 0
END