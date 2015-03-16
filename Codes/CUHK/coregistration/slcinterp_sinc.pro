;+   
; Purpose:
;    
; Calling Sequence:
;    
; Inputs:
;    
; Optional Input Parameters:
;    
; Keyword Input Parameters:
;    
; Outputs:
;    
; Commendations:
;    
; Example:
;    
; Modification History:
;-  


;+
; NAME:
;    sint
; PURPOSE: (one line)
;    Sinc interpolation of a 1-D vector of data.
; CALLING SEQUENCE:
;    result = sint( x, f )
; INPUTS:
;    x  : Independent variable values for which f is to be interpolated.
;         Note: The implied independent variable values for f are the indicies
;         of the vector f.
;    f  : Vector of function values (dependent variable).
; OUTPUTS:
;    Interpolated value(s).
; MODIFICATION HISTORY:
;    Written by Doug Loucks, Lowell Observatory, September, 1993.
;    Adapted from the IDL function sshift.pro written by Marc Buie.
;    01/14/94, DWL, Documentation update.
;-
FUNCTION sint, x, f

dampfac = 3.25
ksize   = 21

nx = N_ELEMENTS( x )
nf = N_ELEMENTS( f )

ix = FIX( x )
fx = x - ix
z = WHERE( fx EQ 0, countz )
i = WHERE( fx NE 0, counti )

r = x * 0

IF countz NE 0 THEN BEGIN
   ;There are integral values of the independent variable. Select the function
   ;values directly for these points.
   r[ z ] = f[ ix[z] ]
ENDIF

IF counti NE 0 THEN BEGIN
   ;Use sinc interpolation for the points having fractional values.
   FOR point=0, counti-1 DO BEGIN
      xkernel = ( FINDGEN( ksize ) - 10 ) - fx[ i[ point ] ]
      u1 = xkernel / dampfac
      u2 = !pi * xkernel
      sinc = EXP( -( u1*u1 ) ) * SIN( u2 ) / u2
      lobe = ( INDGEN( ksize ) - 10 ) + ix[ i[point] ]
      vals = FLTARR( ksize )
      w = WHERE( lobe LT 0, count )
      IF count NE 0 THEN vals[w] = f[0]
      w = WHERE( lobe GE 0 AND lobe LT nf, count )
      IF count NE 0 THEN vals[w] = f[ lobe[w] ]
      w = WHERE( lobe GE nf, count )
      IF count NE 0 THEN vals[w] = f[ nf-1 ]
      r[ i[ point ] ] = TOTAL( sinc * vals )
   ENDFOR
ENDIF

RETURN, r

END
;+
; NAME:
;    sinc
; PURPOSE: (one line)
;    Sinc interpolation of a 2-D array of data.
; CATEGORY:
;    Numerical
; CALLING SEQUENCE:
;    result = sint2d( x, y, f )
; INPUTS:
;    x, y  : Position of desired function value.
;    f     : Two-D function array.
; OUTPUTS:
;    Interpolated function value.
; PROCEDURE:
;    Calls external function sint to interpolate appropriate 1-D slices of
; the 2-D array.
;    Note: For speed, input parameters are not verified.
; MODIFICATION HISTORY:
;    Written by Doug Loucks, Lowell Observatory, September, 1993.
;    23/02/2012: Add case when x or y lt 0 or x lt f_samples or y lt f_lines
;                Modified by T.Li @ InSAR Team in SWJTU & CUHK
;-
FUNCTION sinc, x, y, f

IF x LT 0 $
OR y LT 0 $ 
OR x GT (SIZE(f,/DIMENSIONS))[0] $
OR y GT (SIZE(f,/DIMENSIONS))[1] $
THEN BEGIN
  result= !VALUES.F_NAN
  RETURN, result
ENDIF
;Get size of input array.
stat = SIZE( f )
xsize = stat[ 1 ]
ysize = stat[ 2 ]

;Half-size of the kernel.
delta = 10

;Compute integer and fractional parts of input position.
ix = FIX( x )
fx = x - ix
iy = FIX( y )
fy = y - iy

yoff = MIN( [ iy, delta ] )
ly   = iy - yoff
hy   = iy + yoff
IF hy GE ysize THEN hy = ysize-1
ny   = hy - ly + 1

vals = FLTARR( ny )
FOR j = 0, ny-1 DO BEGIN
   xoff = MIN( [ ix, delta ] )
   lx = ix - xoff
   hx = ix + xoff
   IF hx GE xsize THEN hx = xsize-1
   r1 = f[ lx : hx, ly+j ]
   x1 = fx + xoff
   vals[j] = sint( x1, r1 )
ENDFOR
RETURN, sint( fy+yoff, vals )

END

FUNCTION SLCINTERP_SINC, f, x, y

  szx= SIZE(x)
  szy= SIZE(y)
  
;  result= FLTARR(szx)
  
  IF szx(0) EQ 1 THEN BEGIN
    result= FLTARR(szx(1))
    FOR i=0, szx(1)-1 DO BEGIN
      xcoor= x[i]
      ycoor= y[i]
      result[i]= SINC(xcoor, ycoor, f)
    ENDFOR
  ENDIF ELSE BEGIN
    result= FLTARR(szx[1],szx(2))
    FOR i=0, szx(1)-1 DO BEGIN
      FOR j=0, szx(2)-1 DO BEGIN
        xcoor= x(i,j)
        ycoor= y(i,j)
        result(i,j)= SINC(xcoor, ycoor, f)
      ENDFOR
    ENDFOR
  ENDELSE

  RETURN, result
  
END