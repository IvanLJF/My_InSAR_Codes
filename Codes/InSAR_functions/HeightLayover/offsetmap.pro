;- Script that:
;-     Draw Offset Map
;- Usage:
;-     Run the script
;-     infile: Text includes offset information.
;-     avepwr: Pwr of the area.
;- Author:
;-     T. Li @ InSAR Team in SWJTU 

; $Id: //depot/idl/IDL_70/idldir/lib/velovect.pro#1 $
;
; Copyright (c) 1983-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.




PRO MYVELOVECT,U,V,X,Y, Missing = Missing, Length = length, Dots = dots,  $
        CLIP=clip, NOCLIP=noclip, OVERPLOT=overplot, _REF_EXTRA=extra

;
;+
; NAME:
;   VELOVECT
;
; PURPOSE:
;   Produce a two-dimensional velocity field plot.
;
;   A directed arrow is drawn at each point showing the direction and
;   magnitude of the field.
;
; CATEGORY:
;   Plotting, two-dimensional.
;
; CALLING SEQUENCE:
;   VELOVECT, U, V [, X, Y]
;
; INPUTS:
;   U:  The X component of the two-dimensional field.
;       U must be a two-dimensional array.
;
;   V:  The Y component of the two dimensional field.  Y must have
;       the same dimensions as X.  The vector at point [i,j] has a
;       magnitude of:
;
;           (U[i,j]^2 + V[i,j]^2)^0.5
;
;       and a direction of:
;
;           ATAN2(V[i,j],U[i,j]).
;
; OPTIONAL INPUT PARAMETERS:
;   X:  Optional abcissae values.  X must be a vector with a length
;       equal to the first dimension of U and V.
;
;   Y:  Optional ordinate values.  Y must be a vector with a length
;       equal to the first dimension of U and V.
;
; KEYWORD INPUT PARAMETERS:
;   COLOR:  The color index used for the plot.
;
;   DOTS:   Set this keyword to 1 to place a dot at each missing point.
;       Set this keyword to 0 or omit it to draw nothing for missing
;       points.  Has effect only if MISSING is specified.
;
;   LENGTH: Length factor.  The default of 1.0 makes the longest (U,V)
;       vector the length of a cell.
;
;       MISSING: Missing data value.  Vectors with a LENGTH greater
;       than MISSING are ignored.
;
;       OVERPLOT: Set this keyword to make VELOVECT "overplot".  That is, the
;               current graphics screen is not erased, no axes are drawn, and
;               the previously established scaling remains in effect.
;
;
;   Note:   All other keywords are passed directly to the PLOT procedure
;       and may be used to set option such as TITLE, POSITION,
;       NOERASE, etc.
; OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   Plotting on the selected device is performed.  System
;   variables concerning plotting are changed.
;
; RESTRICTIONS:
;   None.
;
; PROCEDURE:
;   Straightforward.  Unrecognized keywords are passed to the PLOT
;   procedure.
;
; MODIFICATION HISTORY:
;   DMS, RSI, Oct., 1983.
;   For Sun, DMS, RSI, April, 1989.
;   Added TITLE, Oct, 1990.
;   Added POSITION, NOERASE, COLOR, Feb 91, RES.
;   August, 1993.  Vince Patrick, Adv. Visualization Lab, U. of Maryland,
;       fixed errors in math.
;   August, 1993. DMS, Added _EXTRA keyword inheritance.
;   January, 1994, KDB. Fixed integer math which produced 0 and caused
;                   divide by zero errors.
;   December, 1994, MWR. Added _EXTRA inheritance for PLOTS and OPLOT.
;   June, 1995, MWR. Removed _EXTRA inheritance for PLOTS and changed
;            OPLOT to PLOTS.
;       September, 1996, GGS. Changed denominator of x_step and y_step vars.
;       February, 1998, DLD.  Add support for CLIP and NO_CLIP keywords.
;       June, 1998, DLD.  Add support for OVERPLOT keyword.
;   June, 2002, CT, RSI: Added the _EXTRA back into PLOTS, since it will
;       now (as of Nov 1995!) quietly ignore unknown keywords.
;-
;
COMPILE_OPT strictarr

        on_error,2                      ;Return to caller if an error occurs
        s = size(u)
        t = size(v)
        if s[0] ne 2 then begin
baduv:   message, 'U and V parameters must be 2D and same size.'
                endif
        if total(abs(s[0:2]-t[0:2])) ne 0 then goto,baduv
;
        if n_params(0) lt 3 then x = findgen(s[1]) else $
                if n_elements(x) ne s[1] then begin
badxy:                  message, 'X and Y arrays have incorrect size.'
                        endif
        if n_params(1) lt 4 then y = findgen(s[2]) else $
                if n_elements(y) ne s[2] then goto,badxy
;
        if n_elements(missing) le 0 then missing = 1.0e30
        if n_elements(length) le 0 then length = 1.0

        mag = sqrt(u^2.+v^2.)             ;magnitude.
                ;Subscripts of good elements
        nbad = 0                        ;# of missing points
        if n_elements(missing) gt 0 then begin
                good = where(mag lt missing)
                if keyword_set(dots) then bad = where(mag ge missing, nbad)
        endif else begin
                good = lindgen(n_elements(mag))
        endelse

        ugood = u[good]
        vgood = v[good]
        x0 = min(x)                     ;get scaling
        x1 = max(x)
        y0 = min(y)
        y1 = max(y)
    x_step=(x1-x0)/(s[1]-1.0)   ; Convert to float. Integer math
    y_step=(y1-y0)/(s[2]-1.0)   ; could result in divide by 0

    maxmag=max([max(abs(ugood/x_step)),max(abs(vgood/y_step))])
    sina = length * (ugood)
    cosa = length * (vgood)
;    sina = length * (ugood/maxmag)
;    cosa = length * (vgood/maxmag)
;
        if n_elements(title) le 0 then title = ''
        ;--------------  plot to get axes  ---------------
        if n_elements(noclip) eq 0 then noclip = 1
        x_b0=x0-x_step
    x_b1=x1+x_step
    y_b0=y0-y_step
    y_b1=y1+y_step
        if (not keyword_set(overplot)) then begin
          if n_elements(position) eq 0 then begin
            plot,[x_b0,x_b1],[y_b1,y_b0],/nodata,/xst,/yst, $
              _EXTRA = extra
          endif else begin
            plot,[x_b0,x_b1],[y_b1,y_b0],/nodata,/xst,/yst, $
              _EXTRA = extra
          endelse
        endif
        if n_elements(clip) eq 0 then $
            clip = [!x.crange[0],!y.crange[0],!x.crange[1],!y.crange[1]]
;
        r = .3                          ;len of arrow head
        angle = 22.5 * !dtor            ;Angle of arrowhead
        st = r * sin(angle)             ;sin 22.5 degs * length of head
        ct = r * cos(angle)
;
        for i=0L,n_elements(good)-1 do begin     ;Each point
                x0 = x[good[i] mod s[1]]        ;get coords of start & end
                dx = sina[i]
                x1 = x0 + dx
                y0 = y[good[i] / s[1]]
                dy = cosa[i]
                y1 = y0 + dy
                xd=x_step
                yd=y_step
                plots,[x0,x1,x1-(ct*dx/xd-st*dy/yd)*xd, $
                      x1,x1-(ct*dx/xd+st*dy/yd)*xd], $
                      [y0,y1,y1-(ct*dy/yd+st*dx/xd)*yd, $
                      y1,y1-(ct*dy/yd-st*dx/xd)*yd], $
                      clip=clip,noclip=noclip,_EXTRA=extra
        endfor
        if nbad gt 0 then $             ;Dots for missing?
                PLOTS, x[bad mod s[1]], y[bad / s[1]], psym=3, $
                       clip=clip,noclip=noclip,_EXTRA=extra
end



PRO OFFSETMAP

;    infile='/mnt/software/ForExperiment/SparsePS/20090327-20090429.off.text'
;    avepwr='/mnt/software/ForExperiment/SparsePS/ave.bmp'
;    outbmp_path='/mnt/software/ForExperiment/SparsePS/offsetmap.bmp'
    infile='D:\ForExperiment\SparsePS\20090327-20090429.off.text'
    avepwr='D:\ForExperiment\SparsePS\ave.bmp'
    outbmp_path='D:\ForExperiment\SparsePS\offsetmap.bmp'
;    DEVICE, DECOMPOSED=1
;    !P.BACKGROUND= 'FFFFFF'XL
;    !P.COLOR='000000'XL

    n_lines= FILE_LINES(infile)
    s= 0
    l= 0
    s_off= 0.0
    l_off= 0.0
    img_scale=0.8
    
    OPENR, lun, infile, /GET_LUN
    temp=''
    FOR i=0, n_lines-1 DO BEGIN
      READF, lun, temp
      tempstr= STRSPLIT(temp, ' ', /EXTRACT)
      s=[s, tempstr(0)]
      l=[l, tempstr(1)]
      s_off= [s_off, tempstr(2)]
      l_off= [l_off, tempstr(3)]
    ENDFOR
    FREE_LUN, lun
    s= s(1:*)
    l= l(1:*)
    s_off= s_off(1:*)
    l_off= l_off(1:*)
    
    ;- Interpolate for offset map    
    TRIANGULATE, s, l, tri
    ntri=(SIZE(tri))[2]
;    s_off_rs= TRIGRID(s,l, s_off, tri, nx=30, ny=30, xgrid=xx, ygrid=yy)
;    l_off_rs= TRIGRID(s,l, l_off, tri, nx=30, ny=30, xgrid=xx, ygrid=yy)
    s_off_rs= TRIGRID(s,l, s_off, tri, nx=1000, ny=1000, xgrid=xx, ygrid=yy)
    l_off_rs= TRIGRID(s,l, l_off, tri, nx=1000, ny=1000, xgrid=xx, ygrid=yy)   
    x=s_off_rs
    y=l_off_rs
    r_off= COMPLEX(x, y)
    r_off_coor= COMPLEX(xx, yy)

    ;- Find offset in PS. First we have to read PS coor from a plist.
    infile='D:\ForExperiment\SparsePS\plist'
    ps_number=((FILE_INFO(infile)).SIZE)/8D
    PsCoor= LONARR(ps_number*2)
    OPENR, lun, infile,/GET_LUN,/SWAP_ENDIAN
    READU, lun, PsCoor
    FREE_LUN, lun
    PsCoor_x= PsCoor(2*INDGEN(ps_number-1))
    PsCoor_y= PsCoor(2*INDGEN(ps_number-1)+1)
    PsCoor= COMPLEX(PsCoor_x, PsCoor_y)
    
    ;- Secondly, analyze offset in PS
    r_off_ps= r_off(PsCoor_x, PsCoor_y)
    r= ABS(r_off_ps)
    PRINT, 'Min Offset in PS is:', MIN(r)
    PRINT, 'Max Offset in PS is:', MAX(r)
    PRINT, 'Mean offset in PS is:', MEAN(r)
    DEVICE, DECOMPOSED=1
    !P.BACKGROUND='FFFFFF'XL
    !P.COLOR='000000'XL
    PLOT, HISTOGRAM(r)   

    
    ;- Thirdly, analyze offset in NonPS
    Coor_x= REBIN(INDGEN(1000), 1000,1000)
    Coor_y= TRANSPOSE(Coor_x)
    Coor= COMPLEX(Coor_x, Coor_y)
    Coor= REFORM(Coor,  1000*1000D)
    Cooer=[Coor, PsCoor]    
    temp= UNIQ(Coor)
    Coor= Coor(temp)    
    NPsCoor_x= REAL_PART(Coor)
    NPsCoor_y= IMAGINARY(Coor)
    r_off_nps= r_off(NPsCoor_x,NPsCoor_y)
    r= ABS(r_off_nps)
    PRINT, 'Min Offset in NPS is:', MIN(r)
    PRINT, 'Max Offset in NPS is:', MAX(r)
    PRINT, 'Mean offset in NPS is:', MEAN(r)
    WINDOW
    PLOT, HISTOGRAM(r) 
    
    DEVICE, DECOMPOSED=0
    LOADCT, 5
    WINDOW
    TV, r_off*1000
    
    
;    ave= READ_BMP(avepwr)
;    r_off=SQRT(s_off^2+l_off^2)
;    amp= DOUBLE(ave(s,l))
;    ii= SORT(amp)
;    r_off= r_off(ii)
;    amp= amp(ii)/MAX(amp)*500
;;    WINDOW,1,XSIZE=500,YSIZE=500,TITLE='offset VS amp'
;;    PLOTS, amp, r_off*15,/DEVICE
;    
;    ii= SORT(r_off)
;    r_off= r_off(ii)
;    amp= amp(ii)
;;    WINDOW, 3, XSIZE=500, YSIZE=500, TITLE='amp VS offset'
;;    PLOTS, r_off*150, amp,/DEVICE
;    
;    sz= SIZE(ave)*img_scale
;    ave= CONGRID(ave, sz(1), sz(2))
;    WINDOW, 2, XSIZE=sz(1), YSIZE=sz(2), TITLE='Bmp & offset'
;    TVSCL, ave
;    
;    DEVICE, GET_DECOMPOSED=OldDecomposed
;    DEVICE, DECOMPOSED=0
;    TVLCT, 0,255,0,1
;    MYVELOVECT, x*5 , y*5, xx*img_scale, yy*img_scale, length=1.0, /OVERPLOT, COLOR=1, THICK=2.75,/DEVICE
;    DEVICE, DECOMPOSED= OldDecmposed
;    outbmp= TVRD(true=1)
;    WRITE_BMP, outbmp_path,outbmp

    
END