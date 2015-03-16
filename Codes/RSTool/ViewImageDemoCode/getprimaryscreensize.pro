;+
; :Description:
;    获取首屏幕的可用空间.
;
; :Keywords:
;    exclude_taskbar:是否排除任务栏
;-
function GETPRIMARYSCREENSIZE, Exclude_Taskbar=exclude_taskbar
  compile_opt idl2

  oMonInfo = OBJ_NEW('IDLsysMonitorInfo')
  rects = oMonInfo -> GetRectangles(Exclude_Taskbar=exclude_Taskbar)
  pmi = oMonInfo -> GetPrimaryMonitorIndex()
  OBJ_DESTROY, oMonInfo

  RETURN, rects[[2, 3], pmi] ; 首屏幕的可用空间：宽、高
end