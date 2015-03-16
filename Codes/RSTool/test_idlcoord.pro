PRO test_idlcoord
  ;
  oWindow = OBJ_NEW('IDLgrWindow', $
    retain =2, $
    DIMENSIONS = [800,400])    
    
  ;显示体系结构
  oView = OBJ_NEW('IDLgrView')
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  
  ;读取数据
  file = filepath( 'day.jpg', SUBDIRECTORY=['examples','data'] )
  
  READ_JPEG, file,imageData
  ; Resize the image data
  imageData = congrid(imageData,3,360,180)
  
  oImage = OBJ_NEW('IDLgrImage', $
    imageData)
  imageModel->add,oImage
  ;读取矢量文件
  shpFilename = filepath( 'shape\continents.shp', SUBDIRECTORY=['resource','maps'] )
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts[j]:cuts[j+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;转换到当前图像坐标下
        tempLon = (REFORM(tempLon) -(-180))
        tempLat = (REFORM(tempLat) -(-90))
        ;
        num = N_ELEMENTS(tempLon)
        polylines = LINDGEN(num+1)-1
        polylines[0] = num
        
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          tempLon, $
          tempLat, $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ;  图像坐标显示
  oView->setproperty, viewPlane_Rect = [0,0,800,400]
  oWindow->SetProperty, title ='图像坐标显示'
  oWindow->draw,oView
  ;停顿两秒
  wait,2
  
  ;归一化坐标显示
  ;销毁原来的
  OBJ_DESTROY,oTopModel
  ;建立新的
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  ;
  oImage = OBJ_NEW('IDLgrImage', $
    imageData)
  imageModel->add,oImage
  ;获取当前图像对象的X、Y方向的范围
  oImage->getproperty, xRange = xRange,yRange = yRange
  ;求出归一化系数
  xr = norm_coord(xRange)
  ;解析：xrange =[0,360],xr是两个参数,[-0.00000000 ,0.0027777778],通过设置该参数，
  ;那么转换后x方向的原数据坐标为xr[0]+xr[1]*xrange[0]= -0+0.002777*0 = 0
  ;                           xr[0]+xr[1]*xRange[1]= -0+0.002777*360 =1
  ; 可测试 Norm_Coord([-100,100]) =      [0.500000 ,  0.00500000]
  ;
  yr = norm_coord(yRange)
  oImage->setproperty, xCoord_conv = xr, $
    yCoord_conv = yr
  ;
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
;      cuts = reform(cuts);- 伪二维变一维
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts:cuts[i+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;
        ;转换到归一化的坐标系下显示
        tempLon = FLOAT((REFORM(tempLon) -(-180))) /360.
        tempLat = FLOAT((REFORM(tempLat) -(-90)))/180.
        ;
        num = N_ELEMENTS(tempLon)
        polylines = LINDGEN(num+1)-1
        polylines[0] = num
        
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          tempLon, $
          tempLat, $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ; 设置显示区域坐标
  oView->setproperty, viewPlane_Rect = [0,0,1,1]
  oWindow->SetProperty, title ='归一化坐标显示'
  oWindow->draw,oView
  ;停顿两秒
  wait,2
  
  ;地理坐标显示
  ;销毁原来的
  OBJ_DESTROY,oTopModel
  
  ;建立新的
  sMap = map_proj_init('Interrupted Goode') 
;  或用下面的投影
;  ;全球的“等距圆柱投影”
;  sMap = Map_Proj_Init('Equirectangular'        , $
;                 Limit = [-90,-180,90,180]     , $
;                 Center_Longitude = 0        )
  
  shapeModel = OBJ_NEW('IDLgrModel')
  imageModel= OBJ_NEW('IDLgrModel')
  oTopModel= OBJ_NEW('IDLgrModel')
  oTopModel->add,[imageModel,shapeModel]
  oView->add,oTopModel
  ;
  
  ;对图像进行纠正
  ;
  red= REFORM(imageData[0,*,*])
  green= REFORM(imageData[1,*,*])
  blue= REFORM(imageData[2,*,*])
  
  red1 = map_proj_image( red, MAP_STRUCTURE=sMap, MASK=mask, $
    UVRANGE=uvrange, XINDEX=xindex, YINDEX=yindex )
  green1 = map_proj_image( green, XINDEX=xindex, YINDEX=yindex )
  blue1 = map_proj_image( blue, XINDEX=xindex, YINDEX=yindex )
  imageData = BYTARR(4,360,180)
  imageData[0,*,*] = red1
  imageData[1,*,*] = green
  imageData[2,*,*] = blue
  ;设置掩膜
  imageData[3,*,*] = mask*255b
  ;
  uRange = uvRange[2]-uvRange[0]
  vRange = uvRange[3]-uvRange[1]
  
  oImage = OBJ_NEW('IDLgrImage', $
    imageData, $
    BLEND_FUNCTION = [3, 4], $
    dimensions=[uRange,vRange], $  ;维数--大地坐标
    location=uvRange[0:1] )        ;位置--大地坐标
  imageModel->add,oImage
  ;  ;
  shapeFile = OBJ_NEW('IDLffShape', shpFileName)
  shapeFile->getproperty, N_Entities = nEntities
  
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeFile->getentity(i)
    
    IF PTR_VALID(entitie.parts) NE 0 THEN BEGIN
      cuts = [*entitie.parts, entitie.n_vertices]
      FOR j=0, entitie.n_parts-1 DO BEGIN
        tempLon = (*entitie.vertices)[0,cuts[j]:cuts[j+1] - 1]
        tempLat = (*entitie.vertices)[1,cuts[j]:cuts[j+1] - 1]
        ;
        ;转换到m制坐标系下显示
        vert = MAP_PROJ_FORWARD([tempLon,tempLat], $
          Map_Structure = sMap, $
          Polylines = polyLines)
        ;          
        tempPlot = OBJ_NEW('IDLgrPolyline', $
          vert[0,*], $
          vert[1,*], $
          Polylines = polyLines    , $
          Alpha_Channel = 1, $
          color = [255,0,0])
        shapeModel->add,tempPlot
        
      ENDFOR
    ENDIF
    shapeFile->destroyentity, entitie
  ENDFOR
  ;
  ; 设置显示区域坐标 
  
  oView->setproperty, viewPlane_Rect = [uvrange[0],uvrange[1],uRange,vRange]
  oWindow->SetProperty, title ='Interrupted Goode 投影下m制坐标显示'
  oWindow->draw,oView  
END