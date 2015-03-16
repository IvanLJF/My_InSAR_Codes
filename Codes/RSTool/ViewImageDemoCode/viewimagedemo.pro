;---------------------------------------------------------------------------
;+
; :Description:
;      demo shows the relationship of the draw dimensions¡¢view Dimensions¡¢image Locationetc .
;
; Author: DYQ 2008-12-10
;
; E-mail: dongyq@esrichina-bj.cn
; MSN: dongyq@esrichina-bj.cn
;-
;
PRO Viewimagedemo
  ;
  COMPILE_OPT STRICTARR
  ;

  CD, current = rootDir
  sz = Getprimaryscreensize()*.8
  ;
  oSystem = Obj_New('ViewImageSystem', $
    rootDir = rootDir)

END