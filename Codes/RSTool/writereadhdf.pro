;+
;+
;:Description:


PRO CENTERTLB, tlb, x, y, NoCenter=nocenter

  COMPILE_OPT StrictArr
  
  geom = WIDGET_INFO(tlb, /Geometry)
  
  IF N_ELEMENTS(x) EQ 0 THEN xc = 0.5 ELSE xc = FLOAT(x[0])
  IF N_ELEMENTS(y) EQ 0 THEN yc = 0.5 ELSE yc = 1.0 - FLOAT(y[0])
  center = 1 - KEYWORD_SET(nocenter)
  ;
  oMonInfo = OBJ_NEW('IDLsysMonitorInfo')
  rects = oMonInfo -> GetRectangles(Exclude_Taskbar=exclude_Taskbar)
  pmi = oMonInfo -> GetPrimaryMonitorIndex()
  OBJ_DESTROY, oMonInfo
  
  screenSize =rects[[2, 3], pmi]
  
  ; Get_Screen_Size()
  IF screenSize[0] GT 2000 THEN screenSize[0] = screenSize[0]/2 ; Dual monitors.
  xCenter = screenSize[0] * xc
  yCenter = screenSize[1] * yc
  
  xHalfSize = geom.Scr_XSize / 2 * center
  yHalfSize = geom.Scr_YSize / 2 * center
  
  XOffset = 0 > (xCenter - xHalfSize) < (screenSize[0] - geom.Scr_Xsize)
  YOffset = 0 > (yCenter - yHalfSize) < (screenSize[1] - geom.Scr_Ysize)
  
  WIDGET_CONTROL, tlb, XOffset=XOffset, YOffset=YOffset
END
;
; 测试 分块写如HDF文件
; 读取请参考  C:\Program Files\ITT\IDL71\examples\doc\sdf\hdf_info.pro
; Author: DYQ 2010-5-9;
;
; Blog: http://hi.baidu.com/dyqwrp
;-
PRO WRITEREADHDF
  ;创建隐藏tlb，目的为了显示进度条
  wtlb = WIDGET_BASE(map = 0)
  WIDGET_CONTROL,wtlb,/realize
  ;tlb居中显示
  CENTERTLB,wtlb
  ;创建进度条
  process = IDLITWDPROGRESSBAR( TIME=0,$
    GROUP_LEADER=wtlb, $
    TITLE='测试分块保存HDF... 请等待')
  IDLITWDPROGRESSBAR_SETVALUE, process, 0
  
  ;源数据及相关信息
  image = DIST(6000)
  ;求出数据范围
  myRANGE=[MAX(image,min=min_xray),min_xray]
  dims  = SIZE(image,/dimension)
  ;块大小
  tileSize = [1024, 1024]
  
  ;初始化写入HDF数据
  filename = 'test.hdf'
  
  sd_id=HDF_SD_START(filename,/CREATE)
  ;
  sds_id=HDF_SD_CREATE(sd_id,'largeWrite', $
    [dims[0],dims[1]],/FLOAT)
  ;
  HDF_SD_SETINFO,sds_id,FILL=0.0,LABEL='data', $
    UNIT='float',$
    RANGE=myRANGE
  ;
  ; Write labels to each of the dimension
  HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,0),NAME='Width',LABEL='Width of data'
  HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,1),NAME='Height',LABEL='Height of data'
  
  ;xn和yn分别是行、列的初始循环次数
  xn = 0
  yn = 0
  
  ;计算循环次数，- 目的为了进度条正确显示
  IF(dims[1]/tileSize[1] EQ 0 )AND(dims[0]/tileSize[0] EQ 0) THEN BEGIN
    TotalNum  = 1
  ENDIF ELSE IF(dims[1]/tileSize[1] EQ 0 ) THEN BEGIN
    TotalNum = FIX(dims[0]/tileSize[0])+1
  ENDIF ELSE IF(dims[0]/tileSize[0] EQ 0 ) THEN BEGIN
    TotalNum = FIX(dims[1]/tileSize[1])+1
  ENDIF ELSE  TotalNum = (FIX(dims[1]/tileSize[1])+1)*(FIX(dims[0]/tileSize[0])+1)
  ; 更新下进度条
  IDLITWDPROGRESSBAR_SETVALUE, process, 1
  DoneNum = 0
  
  UpRate = 99/TotalNum
  ;分别在水平和竖直方向循环
  WHILE(yn LT FIX(dims[1]/tileSize[1])) DO BEGIN
  
    WHILE(xn LT FIX(dims[0]/tileSize[0])) DO BEGIN
      ;计算存储的数据块位置
      loc = [tileSize[0]*xn,tileSize[1]*yn]
      ;提取数据相应位置数据
      wtImg = image[loc[0]:(loc[0]+tilesize[0]-1),loc[1]:(loc[1]+tilesize[1]-1)]
      ;写入HDF文件中
      HDF_SD_ADDDATA, sds_id, wtImg, $
        START=loc, COUNT=tileSize
      xn++
      ;更新进度条
      DoneNum = DoneNum+1
      IDLITWDPROGRESSBAR_SETVALUE, process, 1+UpRate*DoneNum
    ENDWHILE
    ;
    IF(dims[0] GT tileSize[0]*xn)THEN BEGIN
      ;计算存储的数据块位置
      loc = [tileSize[0]*xn,tileSize[1]*yn]
      ;提取数据相应位置数据
      wtImg = image[loc[0]:(dims[0]-1),loc[1]:(loc[1]+tilesize[1]-1)]
      ;写入HDF文件中，注意count的变化
      HDF_SD_ADDDATA, sds_id,  wtImg, $
        START=loc, COUNT=SIZE(wtImg,/dimension)
    ENDIF
    ;
    xn = 0
    yn++
    ;更新进度条
    DoneNum = DoneNum+1
    IDLITWDPROGRESSBAR_SETVALUE, process, 1+UpRate*DoneNum
  ENDWHILE
  ; 最后一行不完整的部分
  IF(dims[1] GT tileSize[1]*yn)THEN BEGIN
    xn = 0
    WHILE(xn LT FIX(dims[0] /tileSize[0])) DO BEGIN
      ;计算存储的数据块位置
      loc = [tileSize[0]*xn,tileSize[1]*yn]
      ;提取数据相应位置数据
      wtImg = image[loc[0]:(dims[0]-1),loc[1]:(dims[1]-1)]
      ;写入HDF文件中
      HDF_SD_ADDDATA, sds_id,  wtImg, $
        START=loc, COUNT=SIZE(wtImg,/dimension)
      xn++
      ;更新进度条
      DoneNum = DoneNum+1
      IDLITWDPROGRESSBAR_SETVALUE, process, 1+UpRate*DoneNum
    ENDWHILE    
  ENDIF
  
  ;关闭HDF
  HDF_SD_ENDACCESS,sds_id
  HDF_SD_END,sd_id
  IDLITWDPROGRESSBAR_SETVALUE, process, 100
  ;销毁没用的
  WAIT,0.3
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL, wtlb,/DESTROY
END