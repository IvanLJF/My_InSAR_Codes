;
; Make the image fit the window
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150105
;
PRO TLI_SMC_ZOOM
  
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; Get the base size of the draw widget
  xsize=wid.base_xsize
  ysize=wid.base_ysize
  
  ; Get the image size
  sz=SIZE(*(file.data),/DIMENSIONS)
  samples=sz[0]
  lines=sz[1]
  IF N_ELEMENTS(sz) EQ 3 THEN BEGIN
    samples=sz[1] & lines=sz[2]
  ENDIF
    
  
  ; Calculate zoom factor
  zf_r=samples/xsize
  zf_azi=lines/ysize
  
  wid.draw_scale=zf_r>zf_azi
  
  ; Calculate new dimensions
  new_xsize=samples/wid.draw_scale
  new_ysize=lines/wid.draw_scale
  
  ; Get original image
  IF N_ELEMENTS(sz) EQ 3 THEN BEGIN
    data=CONGRID(*(file.data),new_xsize, new_ysize, 3)
  ENDIF ELSE BEGIN
    data=CONGRID(*(file.data),new_xsize, new_ysize)
  ENDELSE
  
  TLI_SMC_DISPLAY, data
  
END