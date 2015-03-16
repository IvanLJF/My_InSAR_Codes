; Chapter09ScaleMaskObject.pro
PRO Chapter09ScaleMaskObject
  file= FILEPATH('md5290fc1.jpg', SUBDIRECTORY = ['examples', 'data'])
  READ_JPEG, file, img, /GRAYSCALE
  dims = SIZE(img, /DIMENSIONS)
  XROI, img, REGIONS_OUT = ROIout, /BLOCK
  ROIout -> GetProperty, DATA = ROIdata
  x = ROIdata[0,*]  &  y = ROIdata[1,*]
  ROIout -> SetProperty, COLOR = [255,255,255], THICK = 2
  oImg = OBJ_NEW('IDLgrImage', img,DIMENSIONS = dims)
  oWindow = OBJ_NEW('IDLgrWindow', DIMENSIONS = dims, $
    RETAIN = 2, TITLE = 'Selected ROI')
  viewRect = [0, 0, dims[0], dims[1]]
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = viewRect)
  oModel = OBJ_NEW('IDLgrModel')
  oModel -> Add, oImg
  oModel -> Add, ROIout
  oView -> Add, oModel
  oWindow -> Draw, oView
  maskResult = ROIout -> ComputeMask( DIMENSIONS = dims)
  IMAGE_STATISTICS, img, MASK = MaskResult, COUNT = count
  PRINT, 'area of mask = ', count,' pixels'
  mask = (maskResult GT 0)
  maskImg = img*mask
  cropImg = maskImg[min(x):max(x), min(y): max(y)]
  cropDims = SIZE(cropImg, /DIMENSIONS)
  oMaskImg = OBJ_NEW('IDLgrImage', cropImg, DIMENSIONS = dims)
  oMaskWindow = OBJ_NEW('IDLgrWindow',DIMENSIONS=2*cropDims,RETAIN=2,$
    TITLE = 'Magnified ROI', LOCATION = dims)
  oMaskView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = viewRect)
  oMaskModel = OBJ_NEW('IDLgrModel')
  oMaskModel -> Add, oMaskImg
  oMaskView -> Add, oMaskModel
  OMaskWindow -> Draw, oMaskView
  OBJ_DESTROY, [oView, oMaskView, ROIout]
END