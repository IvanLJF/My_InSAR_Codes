;Got the boundary of tif file and creat a .shp
;By Tao
;Aug.14, 2014

pro tifboundary
  ENVI,/RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT
  
  ;read tif file
  tiffile = DIALOG_PICKFILE(filter='*.tif',title='Select file')
  result = READ_TIFF(tiffile,geotif=geoinfo)
  d=SIZE(result)
  ;Determine the dimensions of the file
  IF d[0] EQ 2 THEN BEGIN
    col=d[1]
    row=d[2]
  ENDIF ELSE IF d[0] EQ 3 THEN BEGIN
    channel=d[1]
    col=d[2]
    row=d[3]
  ENDIF
  
  ;Get the four points' coordinates
  LUlon=geoinfo.MODELTIEPOINTTAG[3]
  LUlat=geoinfo.MODELTIEPOINTTAG[4]
  lonres=geoinfo.MODELPIXELSCALETAG[0]
  latres=geoinfo.MODELPIXELSCALETAG[1]*(-1)
  LLlon=LUlon
  LLlat=LUlat+row*latres
  
  RUlon=LUlon+col*lonres
  RUlat=LUlat

  RLlon=LUlon+col*lonres
  RLlat=LUlat+row*latres
  ;Creat a .shp file
  shapefile='C:\TEMP\boundary.shp'
  oshp=obj_new('IDLffshape',shapefile, Entity_type=3,/update)
  entNew = {IDL_SHAPE_ENTITY}
  entNew.SHAPE_TYPE = 5
  ;add the coordinates
  coor=[[LUlon,LUlat],[RUlon,RUlat],[RLlon,RLlat],[LLlon,LLlat]]
  entNew.ISHAPE = 0
  entNew.BOUNDS[0] = min(coor[0,*])
  entNew.BOUNDS[1] = min(coor[1,*])
  entNew.BOUNDS[2] = 0.000000
  entNew.BOUNDS[3] = 0.000000
  entNew.BOUNDS[4] = max(coor[0,*])
  entNew.BOUNDS[5] = max(coor[1,*])
  entNew.BOUNDS[6] = 0.00000000
  entNew.BOUNDS[7] = 0.00000000
  pvertice = coor
  entNew.VERTICES = Ptr_NEW(pvertice,/no_copy)
  entNew.N_VERTICES = (SIZE(coor))[2]
  
  oshp->PutEntity, entNew
  
  oshp->AddAttribute, 'id', 3,8, Precision = 0
  oshp->AddAttribute, 'name', 7,20, PRECISION = 0
  
  new_attr = oshp->GetAttributes(/ATTRIBUTE_STRUCTURE)
  new_attr.ATTRIBUTE_0 = 1
  new_attr.ATTRIBUTE_1 = 'boundary'
  oshp->SetAttributes,0,new_attr  
  obj_destroy, oshp
  
;  ENVI_BATCH_EXIT
  print,'-----complete-----'
end