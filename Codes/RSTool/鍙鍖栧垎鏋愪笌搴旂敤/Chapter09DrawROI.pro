; Chapter09DrawROI.pro
PRO Chapter09DrawROI
  DEVICE, DECOMPOSED = 0, RETAIN = 2
  LOADCT, 0
  kneeImg = READ_DICOM(FILEPATH('mr_knee.dcm',$
    SUBDIRECTORY = ['examples','data']))
  dims = SIZE(kneeImg, /DIMENSIONS)
  kneeImg = ROTATE(BYTSCL(kneeImg), 2)
  XROI, kneeImg, REGIONS_OUT = femurROIout, $
    ROI_GEOMETRY = femurGeom,STATISTICS = femurStats, /BLOCK
  XROI, kneeImg, REGIONS_OUT = tibiaROIout, $
    ROI_GEOMETRY = tibiaGeom, STATISTICS = tibiaStats, /BLOCK
  WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
  TVSCL, kneeImg
  LOADCT, 12
  DRAW_ROI, femurROIout, /LINE_FILL, COLOR = 80, SPACING = 0.1, $
    ORIENTATION = 315, /DEVICE
  DRAW_ROI, tibiaROIout, /LINE_FILL, COLOR = 42, SPACING = 0.1, $
    ORIENTATION = 30, /DEVICE
  PRINT, 'FEMUR Region Geometry and Statistics'
  PRINT, 'area =',femurGeom.area, ' population=',femurStats.count,$
    ' perimeter = ',femurGeom.perimeter
  PRINT, 'TIBIA Region Geometry and Statistics'
  PRINT, 'area =',tibiaGeom.area, ' population=',tibiaStats.count,$
    ' perimeter = ',tibiaGeom.perimeter
  OBJ_DESTROY, [femurROIout, tibiaROIout]
END