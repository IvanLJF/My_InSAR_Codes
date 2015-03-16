; Chapter09GroupROIMesh.pro
Pro Chapter09GroupROIMesh
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 5
  TVLCT, R, G, B, /GET
  file = FILEPATH('head.dat', SUBDIRECTORY = ['examples', 'data'])
  img = READ_BINARY(file, DATA_DIMS = [80,100,57])
  img = CONGRID(img, 200, 225, 57)
  oROIGroup = OBJ_NEW('IDLgrROIGroup')
  FOR i=0, 54, 5 DO BEGIN
    XROI, img[*, *,i], R, G, B, REGIONS_OUT = oROI, $
      /BLOCK, ROI_SELECT_COLOR = [255, 255, 255]
    oROI -> GetProperty, DATA = roiData
    roiData[2, *] = 2.2*i
    oRoi -> ReplaceData, roiData
    oRoiGroup -> Add, oRoi
  ENDFOR
  result = oROIGroup -> ComputeMesh(verts, conn)
  nImg = 57
  xymax = 200.0
  zmax = float(nImg)
  oModel = OBJ_NEW('IDLgrModel')
  oModel -> Scale, 1./xymax,1./xymax, 1.0/zmax
  oModel -> Translate, -0.5, -0.5, -0.5
  oModel -> Rotate, [1, 0, 0], -90
  oModel -> Rotate, [0, 1, 0], 30
  oModel -> Rotate, [1, 0, 0], 30
  oPoly = OBJ_NEW('IDLgrPolygon', verts, POLYGON = conn, $
    COLOR = [128, 128, 128], SHADING = 1)
  oModel -> Add, oPoly
  XOBJVIEW, oModel, /BLOCK
  OBJ_DESTROY, [oROI, oROIGroup, oPoly, oModel]
END