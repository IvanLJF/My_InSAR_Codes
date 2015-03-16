;
;+
; :Description:
;    Handle Event
;-
pro testDimsView::HandleEvent,event
  compile_opt idl2
  ;
  tagName = TAG_NAMES(event, /Structure_Name)

;  if tagName eq 'WIDGET_KILL_REQUEST' then begin
;    status = DIALOG_MESSAGE('关闭?', /Question)
;    if status eq 'Yes'then begin
;      WIDGET_CONTROL, event.top, /Destroy
;    endif
;    RETURN
;  endif
;  if (TAG_NAMES(event, /Structure_Name) eq 'WIDGET_DRAW') then begin
;    ;窗口暴露事件
;    if event.type eq 4 then begin
;      self->REFRESHDRAW
;      RETURN
;    endif
;  endif

;  if tagName eq 'WIDGET_PROPSHEET_CHANGE' then begin
;    if (event.proptype ne 0) then begin
;      value = WIDGET_INFO(event.id, Property_Value = event.identifier)
;      event.component->SETPROPERTYBYIDENTIFIER, event.identifier, value
;      self->RefreshDraw
;    endif
;  endif

  UName = widget_info(event.id, /UName)
  Case UName OF
    ;选择文件
    'select': BEGIN
      filters = [['*.jpg;*.jpeg', '*.tif;*.tiff', '*.png'], $
           ['JPEG', 'TIFF', 'Bitmap']]
      file = Dialog_PickFile(filter = filters, $
        title = '选择图像文件', $
        path = self.rootDir, $
        Get_Path = path)
      ;
      IF file[0] NE '' THEN BEGIN
        self.rootDir = path
        Widget_Control, self.wInputFile, $
          Set_Value = file[0]
        self->InitImage,file[0]
        Widget_Control,self.controlBase,/REFRESH_PROPERTY
      END
    END
    'reset': self->Reset
    'exit': BEGIN
      status = DIALOG_MESSAGE('关闭?', /Question)
      if status eq 'Yes'then begin
        WIDGET_CONTROL, event.top, /Destroy
      endif
      RETURN
    END
    'about' : BEGIN
      status = Dialog_Message(''+String(13B)+  $
       'Author: DYQ ' +String(13B)+  $
       'E-mail: dongyq@esrichina-bj.cn'+String(13B)+  $
       'MSN: dongyq@esrichina-bj.cn',/INFORMATION)
    END
    ELSE :
  ENDCASE

end
;+
; :Description:
;    CLEANUP.
;-
pro testDimsView::CLEANUP
  compile_opt idl2

  self->IDLGRVIEW::CLEANUP
end

;+
; :Description:
;    SetProperty.
;-
pro testDimsView::SetProperty, $
    drawXSize = drawXSize, $
    drawYSize = drawYSize , $
    drawScrXSize = drawScrXSize, $
    drawScrYSize = drawScrYSize , $
    drawXOffset= drawXOffset   , $
    drawYOffset= drawYOffset  , $
    ;
    viewXDims = viewXDims , $
    viewYDims = viewYDims , $
    viewXLoc = viewXLoc , $
    viewYLoc = viewYLoc , $
    ;
    viewP0 = viewP0 , $
    viewP1 = viewP1 , $
    viewP2 = viewP2 , $
    viewP3 = viewP3 , $
    ;
    _Ref_Extra = _extra
  compile_opt idl2

  if N_ELEMENTS(drawXSize) gt 0 then self.drawXSize = drawXSize
  if N_ELEMENTS(drawYSize) gt 0 then self.drawYSize = drawYSize
  if N_ELEMENTS(drawScrXSize) gt 0 then self.drawScrXSize = drawScrXSize
  if N_ELEMENTS(drawScrYSize) gt 0 then self.drawScrYSize = drawScrYSize
  if N_ELEMENTS(drawXOffset) gt 0 then self.drawXOffset = drawXOffset
  if N_ELEMENTS(drawYOffset) gt 0 then self.drawYOffset = drawYOffset
;  if N_ELEMENTS(drawYOffset) gt 0 then self.drawColors = drawColors
  ;
  if N_ELEMENTS(viewXDims) gt 0 then self.viewXDims = viewXDims
  if N_ELEMENTS(viewYDims) gt 0 then self.viewYDims = viewYDims
  if N_ELEMENTS(viewXLoc) gt 0 then self.viewXLoc = viewXLoc
  if N_ELEMENTS(viewYLoc) gt 0 then self.viewYLoc = viewYLoc
  ;
  if N_ELEMENTS(viewP0) gt 0 then self.viewP0 = viewP0
  if N_ELEMENTS(viewP1) gt 0 then self.viewP1 = viewP1
  if N_ELEMENTS(viewP2) gt 0 then self.viewP2 = viewP2
  if N_ELEMENTS(viewP3) gt 0 then self.viewP3 = viewP3
  ;
  ;
  Widget_Control, self.draw, xSize = self.drawXSize, $
    ySize = self.drawYSize, scr_Xsize = self.drawScrXsize, $
    scr_YSize = self.drawScrYsize, $
    XOffset = self.drawXOffset, $
    YOffset = self.drawYOffset
  ;
  self->IDLGRVIEW::SETPROPERTY, Dimension = [self.viewXDims,self.viewYDims], $
    viewPlane_Rect = [self.viewP0,self.viewP1, self.viewP2,self.viewP3], $
    Location = [self.viewXLoc, self.viewYLoc]
  ;
  self->IDLGRVIEW::SETPROPERTY, _Extra = _extra
  ;
  self->RefreshDraw
end

;+
; :Description:
;    GetProperty.
;-
pro testDimsView::GetProperty, $
    drawXSize = drawXSize, $
    drawYSize = drawYSize , $
    drawScrXSize = drawScrXSize, $
    drawScrYSize = drawScrYSize , $
    drawXOffset= drawXOffset   , $
    drawYOffset= drawYOffset  , $
    viewXDims = viewXDims , $
    viewYDims = viewYDims , $
    viewXLoc = viewXLoc , $
    viewYLoc = viewYLoc , $
    ;
    viewP0 = viewP0 , $
    viewP1 = viewP1 , $
    viewP2 = viewP2 , $
    viewP3 = viewP3 , $
    ;
    ;
    _Ref_Extra = _extra
  compile_opt idl2

  if ARG_PRESENT(drawXSize) then drawXSize = self.drawXSize
  if ARG_PRESENT(drawYSize) then drawYSize = self.drawYSize
  if ARG_PRESENT(drawScrXSize) then drawScrXSize = self.drawScrXSize
  if ARG_PRESENT(drawScrYSize) then drawScrYSize = self.drawScrYSize
  if ARG_PRESENT(drawXOffset) then drawXOffset = self.drawXOffset
  if ARG_PRESENT(drawYOffset) then drawYOffset = self.drawYOffset
  ;
  if ARG_PRESENT(viewXDims) then viewXDims = self.viewXDims
  if ARG_PRESENT(viewYDims) then viewYDims = self.viewYDims
  if ARG_PRESENT(viewXLoc) then viewXLoc = self.viewXLoc
  if ARG_PRESENT(viewYLoc) then viewYLoc = self.viewYLoc
  ;
  if ARG_PRESENT(viewP0) then begin
    self->GetProperty, viewPlane_Rect = vr
    viewP0 = vr[0]
  endif
  if ARG_PRESENT(viewP1) then begin
    self->GetProperty, viewPlane_Rect = vr
    viewP1 = vr[1]
  endif
  if ARG_PRESENT(viewP2) then begin
    self->GetProperty, viewPlane_Rect = vr
    viewP2 = vr[2]
  endif
  if ARG_PRESENT(viewP3) then begin
    self->GetProperty, viewPlane_Rect = vr
    viewP3 = vr[3]
  endif
  if ARG_PRESENT(viewP4) then begin
    self->GetProperty, viewPlane_Rect = vr
    viewP4 = vr[4]
  endif
  ;
  self->IDLGRVIEW::GETPROPERTY, _Extra = _extra
end

;+
; :Description:
;    reset
;-
pro testDimsView::Reset
  compile_opt idl2
  xSize = self.initSize[0]
  ySize = self.initSize[1]
  ;
  self->SetProperty, $
    drawXSize = xSize, $
    drawYSize = ySize, $
    drawXOffset = 0 , $
    drawYOffset = 0 , $
    drawScrXSize = xSize, $
    drawScrYSize = ySize, $
    viewXDims  = xSize, $
    viewYDims = ySize, $
    viewXLoc = 0, $
    viewYLoc = 0, $
    viewP0 = 0, $
    viewP1 = 0, $
    viewP2 = xSize, $
    viewP3 = ySize

  Widget_Control,self.controlBase,/REFRESH_PROPERTY

end
;
;+
; :Description:
;    Register Property
;-
pro testDimsView::Register
  ;

  status = self->IDLITCOMPONENT::INIT()

  if status then begin        ;
    ;
    self->SetPropertyAttribute, 'name', /Hide
    self->SetPropertyAttribute, 'description', /Hide

    self->RegisterProperty, 'viewXDims', /Float, $
      Name = 'Dimension[0]',  $
      Valid_Range = [1, 5000, 20]
    self->RegisterProperty, 'viewYDims', /Float, $
      Name = 'Dimension[1]',  $
      Valid_Range = [1, 5000, 20]
    self->RegisterProperty, 'viewP0', /Float, $
      Name = 'viewPlane_Rect[0]',  $
      Valid_Range = [-5000, 5000, 50]
    self->RegisterProperty, 'viewP1', /Float, $
      Name = 'viewPlane_Rect[1]',  $
      Valid_Range = [-5000, 5000, 50]
    self->RegisterProperty, 'viewP2', /Float, $
      Name = 'viewPlane_Rect[2]',  $
      Valid_Range = [-5000, 5000, 50]
    self->RegisterProperty, 'viewP3', /Float, $
      Name = 'viewPlane_Rect[3]',  $
      Valid_Range = [-5000, 5000, 50]
    ;
    self->RegisterProperty, 'drawXOffset', /Float, $
      Name = 'Draw的XOffset', $
      Valid_Range = [0, 1000, 10]
    self->RegisterProperty, 'drawYOffset', /Float, $
      Name = 'Draw的YOffset', $
      Valid_Range = [0, 1000, 10]

    self->RegisterProperty, 'drawXSize', /Float, $
      Name = 'Draw的XSize', $
      Valid_Range = [0, 1000, 10]
    self->RegisterProperty, 'drawYSize', /Float, $
      Name = 'Draw的YSize',  $
      Valid_Range = [0, 1000, 10]
    self->RegisterProperty, 'drawScrXSize', /Float, $
      Name = 'Draw的SCRXSize',  $
      Valid_Range = [0, 1000, 10]
    self->RegisterProperty, 'drawScrYSize', /Float, $
      Name = 'Draw的SCRYSize',  $
      Valid_Range = [0, 1000, 10]

  endif
end

;+
; :Description:
;    建立view架构.
;-
pro testDimsView::initViewLayer
  compile_opt idl2
  ;
  draw = Widget_Draw(self.parentBase, $
    XSize = self.drawXSize, $
    YSize = self.drawYSize, $
    X_SCROLL_SIZE = self.drawScrXSize, $
    Y_Scroll_Size = self.drawScrYSize, $
    Graphics_Level = 2, $
    /BUTTON_EVENTS , $
    /MOTION_EVENTS, $
    /Expose_Events, $
    Retain = 0)

  Widget_Control, draw, get_value = oWindow
  self.oWindow = oWindow
  self.draw = draw
  ;
  oModel = OBJ_NEW('IDLgrModel',depth_test_disable=2)

  oModel->ADD, self.oImage
  self->ADD, oModel

end
;+
; :Description:
;    INIT.
;-
pro testDimsView::RefreshDraw, Erase = Erase
  ;
  IF KeyWord_set(erase) then  self.oWindow->Erase
  self.oWindow->Draw, self
end

;-
;---------------------------------------------------------------------------
;+
;+
; :Description:
;   inherits IDLgrView, uses as draw+model+view!
;
; Author: DYQ  2008-12-10
;
; E-mail: dongyq@esrichina-bj.cn
; MSN: dongyq@esrichina-bj.cn
;-
;
function testDimsView::INIT, $
    parent = parent, $
    controlBase = controlBase , $
    rootDir = rootDir, $
    oImage = oImage , $
    xSize = xSize, $
    ySize = ySize, $
    _Extra=extra
  compile_opt idl2

  if (self->IDLGRVIEW::INIT(_Extra=extra) ne 1) then RETURN, 0
  ;
  self.parentBase = parent
  self.controlBase = controlBase
  self.rootDir = rootDir
  self.oImage = oImage
  ;
  self.initSize[0:1] = [xSize, ySize]

  self.xSize = xSize
  self.ySize = ySize

  self.drawXSize = xSize
  self.drawYSize = ySize
  self.drawXOffset = 0
  self.drawYOffset = 0
  ;
  self.drawScrXSize = xSize
  self.drawScrYSize = ySize
  self.viewXDims  = xSize
  self.viewYDims = ySize
  self.viewXLoc = 0
  self.viewYLoc = 0
  ;
  self.viewP0 = 0
  self.viewP1 = 0
  self.viewP2 = xSize
  self.viewP3 = ySize
  ;
  ;初始化显示
  self->initViewLayer
  ;
  self->SetProperty, viewPlane_rect = $
    [self.viewP0,self.viewP1, self.viewP2, self.viewP3]

  self->Register
  ;刷新显示
  self->RefreshDraw

  RETURN, 1
end

;+
; :Description:
;    DEFINE.
;
;-
pro testDimsView__DEFINE
  compile_opt idl2

  void = {testDimsView, $
    ;继承的父类
    inherits IDLgrView      , $

    ;系统参数
    parentBase    : 0      , $
    controlBase   : 0      , $
    imageBase     : 0     , $
    rootDir  :  ''          , $
    wInputFile : 0 , $
    initSize  : FltArr(4)   , $
    draw      : 0 , $
    xSize    :  0.         , $
    ySize    :  0.        , $
    drawXSize:  0.         , $
    drawYSize:  0.         , $
    drawXOffset:  0.       , $
    drawYOffset:  0.       , $
    drawScrXSize:  0.      , $
    drawScrYSize:  0.      , $
;    drawColors : BytArr(3) , $
    viewXDims :  0.        , $
    viewYDims :   0.       , $
    viewXLoc  : 0. , $
    viewYLoc  : 0. , $

    viewP0 : 0. , $
    viewP1 : 0. , $
    viewP2 : 0. , $
    viewP3 : 0. , $

;    imageXDims : 0. , $
;    imageYDims : 0. , $
;    imageXLoc  : 0 , $
;    imageYLoc   : 0 , $
    ;
    oWindow : Obj_New() , $

    oImage   : OBJ_NEW()    $
    }
end