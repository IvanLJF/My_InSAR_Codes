;
; Return the maximum index for input array.
;
; Parameters:
;   array: Input array
;
; Keywords:
;   win_x   : window size in x direction.
;   win_y   : Window size in y direction.
;   ovsfactor: Over sampling factor
;   ovsfactor_x: ovsfactor in x direction (Ommitted is ovsfactor)
;   ovsfactor_y: ovsfactor in y direction (Ommitted is ovsfactor_x)
;   poly    : Method to do polynomial fit. 0: Circular, 1: 1 order, 2: 2 order, 3: 3 order. Else: Not supported.
;
; Written by:
;   T.LI @ ISEIS, CUHK, 20131129
;
;
FUNCTION TLI_SUBDATA, array, center_coor, win, coors=coors
  ; Return the subsetdata and the indices of the input array.
  sz=SIZE(array,/DIMENSIONS)
  
  center_x=center_coor[0]
  center_y=center_coor[1]
  win_x=win[0]
  win_y=win[1]
  
  IF sz[0] LE win_x OR sz[1] LE win_y THEN BEGIN
    Print, 'Warning: TLI_SUBDATA, window size is greater than array size. Returning the input array.'
    RETURN, array
  ENDIF
  
  halfx=FLOOR(win_x/2D)
  halfy=FLOOR(win_y/2D)
  
  xs=center_x-halfx   ; x start
  xe=xs+win_x-1       ; x end
  ys=center_y-halfy   ; y start
  ye=ys+win_y-1       ; y end
  
  xoffl=xs<0          ; offset of x, left side.
  xoffr=(xe<(sz[0]-1))-xe; offset of x, right side.
  
  yoffu=ys<0          ; offset of y, upper side.
  yoffd=(ye<(sz[1]-1))-ye; offset of y, down side.
  
  xs=xs-xoffl+xoffr
  xe=xe-xoffl+xoffr
  
  ys=ys-yoffu+yoffd
  ye=ye-yoffu+yoffd
  
  result=array[xs:xe, ys:ye]
  coors=INDEXARR(x=xs+LINDGEN(win_x), y=ys+LINDGEN(win_y))
  RETURN, result
END

FUNCTION TLI_MAX2D, array, win_x=win_x, win_y=win_y, ovsfactor=ovsfactor,$
                    ovsfactor_x=ovsfactor_x,ovsfactor_y=ovsfactor_y, poly=poly
  
  ; Check the input params
  IF NOT KEYWORD_SET(win_x) THEN win_x=3
  IF NOT KEYWORD_SET(win_y) THEN win_y=win_x
  IF KEYWORD_SET(ovsfactor)+KEYWORD_SET(ovsfactor_x)+KEYWORD_SET(ovsfactor_y) EQ 0 THEN ovsfactor=2
  IF NOT KEYWORD_SET(ovsfactor_x) THEN ovsfactor_x=ovsfactor
  IF NOT KEYWORD_SET(ovsfactor_y) THEN ovsfactor_y=ovsfactor_x
  IF NOT KEYWORD_SET(poly) THEN poly=0
  
  IF TLI_ISPOWER2(ovsfactor)+TLI_ISPOWER2(ovsfactor_x)+TLI_ISPOWER2(ovsfactor_y) NE 3 $
    THEN Message, 'Error: Oversampling factor should be the power of 2!'
    
  ; Find the coordinates of the maximum value.
  maxv=MAX(array,maxind)
  maxcoor=ARRAY_INDICES(array, maxind)
  
  ; Extract the surrounding pixels centered at maxcoor.
  pixels=TLI_SUBDATA(array, maxcoor, [win_x, win_y],indices=indices)
  
  ; Interpolate
  pixels=TLI_OVERSAMPLE(pixels, ovsfactor_x, ovsfactor_y)
  
  ; LS estimation
  
  
  ; Oversampling
  
;  arr=TLI_OVERSAMPLE(array, ovsfactor_x, ovsfactor_y)
  
  ; 

END