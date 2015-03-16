;+
; :Description:
;    CLEANUP.
;-
PRO testDimsImage::Cleanup
  COMPILE_OPT idl2
  
  self->Idlgrimage::cleanup
END

;+
; :Description:
;    SetProperty.
;-
PRO testDimsImage::SetProperty, $
    ;
    imageXDims = imageXDims , $
    imageYDims = imageYDims , $
    imageXLoc = imageXLoc , $
    imageYLoc = imageYLoc , $
    ;
    _Ref_Extra = _extra
  COMPILE_OPT idl2
  ;
  IF N_ELEMENTS(imageXDims) GT 0 THEN self.imageXDims = imageXDims
  IF N_ELEMENTS(imageYDims) GT 0 THEN self.imageYDims = imageYDims
  IF N_ELEMENTS(imageXLoc) GT 0 THEN self.imageXLoc = imageXLoc
  IF N_ELEMENTS(imageYLoc) GT 0 THEN self.imageYLoc = imageYLoc
  ;
  self->Idlgrimage::setproperty, Dimension = [self.imageXDims, self.imageyDims] , $
    Location = [self.imageXLoc, self.imageYLoc]
  ;
  self->Idlgrimage::setproperty, _Extra = _extra
  
END

;+
; :Description:
;    GetProperty.
;-
PRO testDimsImage::GetProperty, $
    ;
    imageXDims = imageXDims , $
    imageYDims = imageYDims , $
    imageXLoc = imageXLoc , $
    imageYLoc = imageYLoc , $
    ;
    _Ref_Extra = _extra
  COMPILE_OPT idl2
  ;  ;
  IF ARG_PRESENT(imageXDims) THEN imageXDims = self.imageXDims
  IF ARG_PRESENT(imageYDims) THEN imageYDims = self.imageYDims
  IF ARG_PRESENT(imageXLoc) THEN imageXLoc = self.imageXLoc
  IF ARG_PRESENT(imageYLoc) THEN imageYLoc = self.imageYLoc
  ;
  self->Idlgrimage::getproperty, _Extra = _extra
END


FUNCTION testDimsImage::InitImage, file
  COMPILE_OPT idl2
  
  queryStatus = Query_image(file, imageInfo)
  ;
  IF queryStatus EQ 1 THEN BEGIN
    self.imageXDims = (imageInfo.DIMENSIONS)[0]
    self.imageYDims = (imageInfo.DIMENSIONS)[1]
    self.initSize = imageInfo.DIMENSIONS
    image = Read_image(file)
    self->Setproperty, data = image, $
      dimension = [self.imageXDims, self.imageYDims]
      
  ENDIF ELSE RETURN, 0
  ;
  RETURN, 1
  
END
                                                                                                                                                                                                                                                                                                                                                                                                                  
;+
; :Description:
;    reset
;-
PRO testDimsImage::Reset
  COMPILE_OPT idl2
  ;
  self->Setproperty, $
    imageXDims = self.initSize[0] , $
    imageYDims = self.initSize[1] , $
    imageXLoc = 0, $
    imageYLoc = 0
    
  WIDGET_CONTROL,self.controlBase,/REFRESH_PROPERTY
  
END
;
;+
; :Description:
;    Register Property
;-
PRO testDimsImage::Register
  ;

  status = self->Idlitcomponent::init(name = '图像属性')
  
  IF status THEN BEGIN
    self->Setpropertyattribute, 'name', /Hide
    self->Setpropertyattribute, 'description', /Hide
    
    self->Registerproperty, 'imageXLoc', /Float, $
      Name = 'Location[0]',  $
      Valid_Range = [-500, 500, 10]
    self->Registerproperty, 'imageYLoc', /Float, $
      Name = 'Location[1]',  $
      Valid_Range = [-500, 500, 10]
    ;
    self->Registerproperty, 'imageXDim', /Float, $
      Name = 'Dimension[0]',  $
      Valid_Range = [0, 1000, 10]
    self->Registerproperty, 'imageYDim', /Float, $
      Name = 'Dimension[1]',  $
      Valid_Range = [0, 1000, 10]
  ENDIF
END
;-
;---------------------------------------------------------------------------
;+
;+
; :Description:
;   inherits IDLgrImage, uses as draw+model+view!
;
; Author: DYQ  2008-12-10
;
; E-mail: dongyq@esrichina-bj.cn
; MSN: dongyq@esrichina-bj.cn
;-
;
FUNCTION testDimsImage::Init, $
    controlBase = controlBase , $
    _Extra=extra
  COMPILE_OPT idl2
  
  IF (self->Idlgrimage::init(_Extra=extra) NE 1) THEN RETURN, 0
  ;
  self.controlBase = controlBase
  self.imageXLoc = 0
  self.imageYLoc = 0
  
  self->Register
  
  RETURN, 1
END

;+
; :Description:
;    DEFINE.
;
;-
PRO Testdimsimage__define
  COMPILE_OPT idl2
  
  void = {testDimsImage, $
    ;继承的父类
    INHERITS IDLgrImage   , $
    
    ;系统参数
    controlBase : 0L , $
    initSize    : INTARR(2), $
    imageXDims : 0. , $
    imageYDims : 0. , $
    imageXLoc  : 0 , $
    imageYLoc  : 0   $
    }
END