
;------------------------------------------------------------------------
;
PRO ViewImageSystem::RefreshSheet
  COMPILE_OPT idl2
  
  IF self.initFlag THEN BEGIN
    WIDGET_CONTROL, self.viewSheet, /REFRESH_PROPERTY
    WIDGET_CONTROL, self.imageSheet, /REFRESH_PROPERTY
  ENDIF
  
END

;------------------------------------------------------------------------
;
PRO ViewImageSystem::Reset
  COMPILE_OPT idl2
  
  IF self.initFlag THEN BEGIN
    self.oImage->Reset
    self.oView->Reset
    
  ENDIF
  
END
;------------------------------------------------------------------------
;
;组件改变大小
;
PRO ViewImageSystem::pan,event

  self.oView->Getproperty,viewPlane_Rect = viewP
  self.oImage->Getproperty, location = imageLoc
 
  CASE event.type OF
    0: BEGIN
      ;左键
      IF event.press EQ 1 THEN BEGIN
        ;为平移准备
        self.panStatus = [1,event.x,event.y]
        
      ENDIF
    END
    1: BEGIN
      self.panStatus = 0
      
      ;更新显示
      self.oView->Refreshdraw
    END
    2: BEGIN
      IF self.panStatus[0] EQ 1 THEN BEGIN
        ;移动视图
        distance = [event.x,event.y]- self.panStatus[1:2]
        IF self.panFlag EQ 0 THEN BEGIN
          viewP[0:1] = viewP[0:1] - distance
          self.oView->Setproperty, viewPlane_Rect = viewP
          
        ENDIF ELSE BEGIN
          imageLoc += distance
          self.oImage->Setproperty, imageXLoc = imageLoc[0], $
            imageYLoc = imageLoc[1]
        ENDELSE
        
        self.panStatus[1:2] = [event.x, event.y]
        ;
        self->Refreshsheet
        
        ;更新显示
        self.oView->Refreshdraw
      ENDIF
    END
    ELSE:
  ENDCASE
END
;------------------------------------------------------------------------
;
;组件改变大小
;
PRO ViewImageSystem::SelectFile
  COMPILE_OPT idl2
  
  filters = [['*.jpg;*.jpeg', '*.tif;*.tiff', '*.png'], $
  ['JPEG', 'TIFF', 'Bitmap']]
  file = DIALOG_PICKFILE(filter = filters, $
    title = '选择图像文件', $
    path = self.rootDir, $
    Get_Path = path)
  ;
  IF file[0] NE '' THEN BEGIN
    self.rootDir = path
    WIDGET_CONTROL, self.wInputFile, $
      Set_Value = file[0]
      
    self.initFlag = self.oImage->Initimage(file[0])
    
    IF self.initFlag THEN BEGIN
      ;
      self.oView->Refreshdraw
      self->Refreshsheet
    ENDIF
  ;    Widget_Control,self.controlBase,/REFRESH_PROPERTY
  END
END

;------------------------------------------------------------------------
;
;主窗口事件处理
;
PRO ViewImageSystem::HandleEvent, event
  COMPILE_OPT idl2
  
  tagName = TAG_NAMES(event, /Structure_Name)
  CASE tagName OF
    ;系统关闭事件
    'WIDGET_KILL_REQUEST': BEGIN
      status = DIALOG_MESSAGE('Exit?', /Question,dialog_parent=self.wTlb)
      IF status EQ 'Yes'THEN BEGIN
        WIDGET_CONTROL, event.top, /Destroy
      ENDIF
      RETURN
    END
    ;属性更改器
    'WIDGET_PROPSHEET_CHANGE' :BEGIN
    IF (event.proptype NE 0) THEN BEGIN
      value = WIDGET_INFO(event.id, Property_Value = event.identifier)
      event.component->Setpropertybyidentifier, event.identifier, value
      self.oView->Refreshdraw,/Erase
    ENDIF
  END
  ;Draw上面
  'WIDGET_DRAW' :BEGIN
  IF self.initFlag THEN BEGIN
    ;窗口暴露事件
    IF event.type EQ 4 THEN BEGIN
      self.oView->Refreshdraw
      RETURN
    ENDIF
    
    CASE self.mouseStatus OF
      'zoom': self->Zoom, event
      'pan': self->Pan, event
      ELSE:
    ENDCASE
  ENDIF
  
END

ELSE:
ENDCASE 

UName = WIDGET_INFO(event.id, /UName)

CASE UName OF
  ;退出
  'exit': BEGIN
    status = DIALOG_MESSAGE('关闭?', /Question)
    IF status EQ 'Yes'THEN BEGIN
      WIDGET_CONTROL, event.top, /Destroy
    ENDIF
    RETURN
  END
  ;关于
  'about' : BEGIN
    status = DIALOG_MESSAGE(''+STRING(13B)+  $
      'Author: DYQ ' +STRING(13B)+  $
      'E-mail: dongyq@esrichina-bj.cn'+STRING(13B)+  $
      'MSN: dongyq@esrichina-bj.cn',/INFORMATION)
  END
  ;选择文件操作
  'select': self->Selectfile
  'reset': self->Reset
  'mview': BEGIN
    self.panFlag = 0
  END
  'mimage': BEGIN
    self.panFlag = 1
  END
  ;    end
  ELSE: BEGIN
  
  ENDELSE
ENDCASE
END
;-----------------------------------------------------------------
;创建menu
;
PRO ViewImageSystem::CreateMenu, mBar
  COMPILE_OPT idl2
  ;
  fMenu = WIDGET_BUTTON(mBar, value ='文件',/Menu)
  fReset = WIDGET_BUTTON(fMenu, value = '初始值', $
    uName = 'reset')
  fExit = WIDGET_BUTTON(fMenu, value = '退出', $
    uName = 'exit',/Sep)
  ;
  hMenu =  WIDGET_BUTTON(mBar, value ='帮助',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '关于', $
    uName = 'about',/Sep)
    
END

;-----------------------------------------------------------------
;
;创建系统框架
;
PRO ViewImageSystem::Create
  COMPILE_OPT idl2
  
  ;create toplevelbase
  self.wTlb = WIDGET_BASE($
    UName = 'wBase', $
    UValue = self, $
    Title = ' Draw&View&Image: Location* Dimension', $
    TLB_FRAME_ATTR = 1, $
    MBar = mBar, $
    Space = 0, $
    XPad = 0, $
    YPad = 0, $
    Xoffset = 0, $
    Yoffset = 0, $
    Map = 0, $
    /Column, $
    /Tlb_Kill_Request_Events)
    
  WIDGET_CONTROL, self.wTlb, /Realize
  
  ;菜单栏
  self->Createmenu,mBar
  ;菜单栏
  ;  upBase = Widget_Base(self.wTlb, $
  ;    /Row, $
  ;    Space = 0)
  middleBase = WIDGET_BASE(self.wTlb, $
    /Row, $
    Space = 0)
  downBase  = WIDGET_BASE(self.wTlb, $
    /Row, $
    Space = 0)
  label = WIDGET_LABEL(downBase, value = ' Ready')
  
  ;
  ;创建显示及控制
  left = WIDGET_BASE(middleBase,/Column)
  right = WIDGET_BASE(middleBase, $
    Space = 0 , $
    XPad = 0, $
    YPad = 0)
  ;左侧的控制面板
  wInput = WIDGET_BASE(left, /ROW)
  self.wInputFile = WIDGET_TEXT(wInput, $
    XSize = 25)
  wSel = WIDGET_BUTTON(wInput, $
    uName = 'select',value = '文件')
    
  tabBase = WIDGET_TAB(left)
  viewBase = WIDGET_BASE(tabBase, $
    Space = 2 , $
    XPad = 0, $
    YPad = 0 , $
    title = 'View属性' , $
    /COLUMN)
  imageBase = WIDGET_BASE(tabBase, $
    Space = 2 , $
    XPad = 0, $
    YPad = 0 , $
    title= 'Image属性' ,$
    /COLUMN)
  ;右侧的显示
  drawBase = WIDGET_BASE(right, /Frame)
  ;
  self.viewSheet = WIDGET_PROPERTYSHEET(viewBase, $
    /Sunken_Frame, $
    Scr_XSize = 200, $
    ySize = 21, $
    /Multiple_Properties)
  self.imageSheet = WIDGET_PROPERTYSHEET(imageBase, $
    /Sunken_Frame, $
    ySize = 20, $
    Scr_XSize = 200, $
    /Multiple_Properties)
  ;
  wReset = WIDGET_BUTTON(left, $
    value = '初始值', $
    /Frame, $
    uName = 'reset')
  ;
  label = WIDGET_LABEL(left, $
    value = '平移时：')
  checkBase = WIDGET_BASE(left,/ROW, $
    /EXCLUSIVE, $
    /Frame  )
  cButton1 = WIDGET_BUTTON(checkBase, $
    value = '修改View', $
    uName = 'mview')
  cButton2 = WIDGET_BUTTON(checkBase, $
    value = '修改Image', $
    uName = 'mimage' )
  WIDGET_CONTROL, cButton1, /SET_BUTTON
  
  self.oImage = OBJ_NEW('testDimsImage', $
    controlBase = self.imageSheet , $
    /REGISTER_PROPERTIES)
  ;
  WIDGET_CONTROL,self.imageSheet, set_value = self.oImage
  
  self.oView = OBJ_NEW('testDimsView', $
    parent = drawBase, $
    controlBase = self.viewSheet , $
    rootDir = self.rootDir , $
    oImage = self.oImage, $
    xSize = self.sz[0]-200, $
    /REGISTER_PROPERTIES, $
    ySize = self.sz[1])
    
  WIDGET_CONTROL,self.viewSheet, set_value = self.oView
  ;主界面居中
  Centertlb, self.wtlb
  
  WIDGET_CONTROL, self.wtlb,/Map,Set_UValue = self
  
END

;-----------------------------------------------------------------
;
;析构
;
PRO ViewImageSystem::Cleanup
  COMPILE_OPT idl2
  
  OBJ_DESTROY, self.oView
  OBJ_DESTROY, self.oImage
  
END

;-----------------------------------------------------------------
;
;初始化
;
FUNCTION ViewImageSystem::Init, rootDir = rootDir
  COMPILE_OPT idl2
  ;
  self.sz = Getprimaryscreensize()*.8
  self.mouseStatus = 'pan'
  
  ;创建
  self->Create
  ;
  self.initFlag = self.oImage->Initimage(rootDir+'\demo.jpg')
  ;
  IF self.initFlag THEN BEGIN
    self.oView->Refreshdraw
    WIDGET_CONTROL, self.wInputFile, Set_Value = rootDir+'\demo.jpg'
  ENDIF
  Xmanager, 'ViewImageDemo',self.wTlb,/No_Block, Event_Handler = '_ViewImageDemo_Event', $
    Cleanup = '_ViewImageDemo_Cleanup'
    
  RETURN, 1
END

;-----------------------------------------------------------------
;
;定义
;
PRO Viewimagesystem__define
  COMPILE_OPT idl2
  
  void = {ViewImageSystem          , $
    ;继承的父类
    wTlb        : 0L  , $
    wInputFile  : 0L  , $
    rootDir     : ''  , $
    viewSheet   : 0L  , $
    imageSheet  : 0L  , $
    initFlag    : 0B  , $
    panFlag     : 0B  , $ ;平移类型
    panStatus   : FLTARR(3) , $
    
    mouseStatus : ''  , $
    sz : INTARR(2)    , $
    
    oView       : OBJ_NEW() , $
    oImage      : OBJ_NEW()  $
    }
    
END