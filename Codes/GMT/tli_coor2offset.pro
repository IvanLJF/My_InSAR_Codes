; 
; Change the given coordinates to offset files which can be accepted by psxy.
;
; The format will be [x0, y0, angle, length]
; Where angle is the angle of the offset vector.
; Length is the lenght of the offset length.
;
; Input params:
;   array          : Two columns array: [start_coor, end_coor], all in complex format.
;   radians        : Return radians instead of angles.
;   lines          : Flip the coordinates in vertical direction.
;   dpi            : Calculate the pixel value instead of inches.
; Return value:
;   The result is organized as the aformentioned format.
; Written by:
;   T.LI @ ISEIS, 20131009
; 
FUNCTION TLI_COOR2OFFSET, array,radians=radians, lines=lines, dpi=dpi,mul=mul

  ; First check the input array
  sz=SIZE(array)
  IF sz[0] NE 2 THEN Message, 'TLI_COOR2OFFSET: Input array must have 2 dimensions.'
  IF sz[1] NE 2 THEN Message, 'TLI_COOR2OFFSET: Input array must have 2 columns.'
  IF sz[3] NE 6 THEN Message, 'TLI_COOR2OFFSET: Elements must be complex values.'
  IF NOT KEYWORD_SET(mul) THEN mul=1.0
  ; Calculate the demanded information.
  ref_coor=array[0,*]
  cal_coor=array[1,*]
  diff_coor=cal_coor-ref_coor
  IF KEYWORD_SET(lines) THEN diff_coor=COMPLEX(REAL_PART(diff_coor), lines-IMAGINARY(diff_coor))
  
  rad=ATAN(diff_coor,/PHASE)  
  deg=DEGREE2RADIUS(rad,/REVERSE)
  
  offset=ABS(diff_coor)
  IF KEYWORD_SET(dpi) THEN offset=offset/dpi
  offset=offset*mul
  IF KEYWORD_SET(radians) THEN result=[rad, offset] $
  ELSE result=[deg, offset]
  RETURN, result
END