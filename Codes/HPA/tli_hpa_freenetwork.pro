;+
; Purpose:
;     Create free network
;
; Pramameters:
;   corrthresh: correlation of arcs.
;   disthresh: distance of arcs.
;   rps  : Range pixel spacing
;   aps  : Azimuth pixel spacing
;   
; Keywords:
;   arcsfile: output file name. [startcorr, endcorr, [startind, endind]]
; 
; Written by:
;   T.LI @ ISEIS
;+
PRO TLI_HPA_FREENETWORK, ptfile, pdifffile, rps, aps, $
    disthresh=disthresh, corrthresh=corrthresh, arcsfile=arcsfile, optimize=optimize, txt=txt, $
    swap_endian=swap_endian
    
  COMPILE_OPT idl2
  
  ; Check input
  IF ~KEYWORD_SET(arcsfile) THEN BEGIN
    arcsfile=FILE_DIRNAME(ptfile)+PATH_SEP()+'freenet_arcs'
  ENDIF
  IF ~KEYWORD_SET(distthresh) THEN distthresh=1000D
  IF ~KEYWORD_SET(corrthresh) THEN corrthresh=0.5D
  
  ; Read ptfile
  pt_coor= TLI_READDATA(ptfile, samples=2, format='LONG',swap_endian=swap_endian)
  pt_coor=(COMPLEX(pt_coor[0,*], pt_coor[1, *]))
  npt= DOUBLE(TLI_PNUMBER(ptfile))
  ; Read pdifffile
  pdiff= TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',swap_endian=swap_endian)
  
  ; Networking
  OPENW, lun, arcsfile,/GET_LUN
  IF KEYWORD_SET(txt) THEN BEGIN
    arcstxt=arcsfile+'.txt'
    OPENW, luntxt, arcstxt,/GET_LUN
  ENDIF
  IF ~KEYWORD_SET(optimize) THEN BEGIN
    Print, 'Complete free network will be constructed.'
    FOR i=0D, npt-2D DO BEGIN
    
      IF ~ (i MOD 1000) THEN BEGIN
        Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt-2D)
      ENDIF
      ; End pts.
      npt_end= npt-i-1
      startpts= LINDGEN(npt_end)+i+1
      endpts= i+LONARR(npt_end)
      arc_ind= TRANSPOSE(COMPLEX(startpts, endpts))
      start_coor= pt_coor[*,startpts]
      end_coor= pt_coor[*,endpts]
      arcs= [start_coor, end_coor, arc_ind] ; start coor, end coor, [start_ind, end_ind]
      
      WRITEU, lun, arcs
      IF KEYWORD_SET(txt) THEN BEGIN
        PrintF, lun, arcs
      ENDIF
    ENDFOR
    
    Print, 'Free network constructed successfully!'
    FREE_LUN, lun
    IF KEYWORD_SET(txt) THEN BEGIN
      FREE_LUN, luntxt
    ENDIF
    
  ENDIF ELSE BEGIN
    ; With optimization
    Print, 'Optimized free network will be constructed.'
    FOR i=0D, npt-2D DO BEGIN
    
      IF ~ (i MOD 1000) THEN BEGIN
        Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt-2D)
      ENDIF
      ; End pts.
      npt_end= npt-i-1
      startpts= LINDGEN(npt_end)+i+1
      endpts= i+LONARR(npt_end)
      arc_ind= TRANSPOSE(COMPLEX(startpts, endpts))
      start_coor= pt_coor[*,startpts]
      end_coor= pt_coor[*,endpts]
      
      ; Dist threshold
      distance= start_coor-end_coor
      distance= SQRT((rps*REAL_PART(distance))^2+(aps*IMAGINARY(distance)^2))
      disind= WHERE(distance LT disthresh)
      IF disind[0] EQ -1 THEN CONTINUE
      arc_ind= arc_ind[*, disind]
      start_coor= start_coor[*, disind]
      end_coor= end_coor[*, disind]
      
      ; Corr threshold
      ; Use for-loop again
      arc_mask= BYTARR(N_ELEMENTS(arc_ind))
      FOR j=0, N_ELEMENTS(arc_ind)-1 DO BEGIN
        ; Extract slc values of the nodes.
        start_ind_j= REAL_PART(arc_ind[*, j])
        end_ind_j= IMAGINARY(arc_ind[*, j])
        start_slc_j= ATAN(pdiff[start_ind_j, *],/phase)
        end_slc_j= ATAN(pdiff[end_ind_j, *],/phase)
        corr= CORRELATE(start_slc_j, end_slc_j)
        IF corr GE corrthresh THEN BEGIN
          arc_mask[j]=1
        ENDIF
      ENDFOR
      
      disind= WHERE(arc_mask EQ 1)
      IF disind[0] EQ -1 THEN CONTINUE
      arc_ind= arc_ind[*, disind]
      start_coor= start_coor[*, disind]
      end_coor= end_coor[*, disind]
      
      arcs= [start_coor, end_coor, arc_ind] ; start coor, end coor, [start_ind, end_ind]
      WRITEU, lun, arcs
      IF KEYWORD_SET(txt) THEN BEGIN
        PrintF, lun, arcs
      ENDIF
      
    END
    Print, 'Free network constructed successfully!'
    FREE_LUN, lun
    IF KEYWORD_SET(txt) THEN BEGIN
      FREE_LUN, luntxt
    ENDIF
    
  ENDELSE
  
END