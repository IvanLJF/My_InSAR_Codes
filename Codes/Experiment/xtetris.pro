; ¶íÂÞË¹·½¿é
;+
; NAME:
;       XTETRIS
;
; PURPOSE:
;
;	This is an IDL version of the old computer game called TETRIS.
;
; 	Adapted from a non-widget version of TETRIS originally written by
;	Ray Sterner.  The control keys below are implemented using a trick
;	where a text widget is behind a draw widget on a bulletin-board type
;	base.  The input focus is given to the text widget so that it
;	recognizes alpha-numeric input.  The events generated in the text
;	widget are interpreted as listed below.  This nice trick
;	was posted on the IDL newsgroup by JD Smith.
;
; AUTHOR:
;
;       Robert M. Dimeo, Ph.D.
;	NIST Center for Neutron Research
;       100 Bureau Drive
;	Gaithersburg, MD 20899
;       Phone: (301) 975-8135
;       E-mail: robert.dimeo@nist.gov
;       http://www.ncnr.nist.gov/staff/dimeo
;
; CATEGORY:
;
;       Widgets, games
;
; CALLING SEQUENCE:
;
;       XTETRIS
;
;
; CONTROLS:
;
;	A: left
;	F: right
;	P: pause
;	R: resume
;	D: down
;	SPACE: rotate
;	Q: quit
;
; REQUIREMENTS:
;
;	Uses the object class "PRINTOBJ" for scoring updates.  In the
;	original program by Sterner this was performed using a procedure
;	called SPRINT which used common blocks.  Use of this object class
;	eliminates the need for any common blocks.
;
; COMMON BLOCKS:
;
;	None
;
; DISCLAIMER
;
;	This software is provided as is without any warranty whatsoever.
;	Permission to use, copy, modify, and distribute modified or
;	unmodified copies is granted, provided this disclaimer
;	is included unchanged.
;
; MODIFICATION HISTORY:
;
;       Written by Rob Dimeo, December 7, 2002.
;	12/12/02 (RMD): Added the checkmarks next to the skill level,
;			renamed the skill levels, and added an intermediate level.
;			The checkmarks are a new feature of IDL 5.6 and the program
;			determines if you are running this on 5.6.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtcleanup,tlb
  WIDGET_CONTROL,tlb,get_uvalue = pState
  WDELETE,(*pState).winPix
  PTR_FREE,(*pState).t_pxa,(*pState).t_pya,(*pState).t_pfxa,(*pState).t_pfya
  PTR_FREE,(*pState).t_brd,(*pState).top,(*pState).t_pfx,(*pState).t_pfy
  PTR_FREE,(*pState).t_px,(*pState).t_py
  OBJ_DESTROY,(*pState).oText
  PTR_FREE,pState
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xthelp,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  strout = ' '
  strout = [strout,' Tetris has 7 different playing pieces which drop down']
  strout = [strout,' from the top of the screen. Points are scored by']
  strout = [strout,' fitting these pieces together to form horizontal rows']
  strout = [strout,' having no gaps. Such complete rows dissolve away and add']
  strout = [strout," to the player's score. Pieces may be moved left and right"]
  strout = [strout,' and rotated to fit together. The more rows completed the']
  strout = [strout,' higher the score each newly completed row is worth.']
  strout = [strout,' Extra credit is given for completing 4 rows at the same']
  strout = [strout,' time.  Upper or lower case key commands may be used. ']
  strout = [strout,' Both the current game scores and the highest score during']
  strout = [strout,' the current session of IDL are displayed.']
  strout = [strout,' ']
  strout = [strout,' The first version of this project was written using PC IDL']
  strout = [strout,' in an afternoon as a test of the capabilities of IDL on a']
  strout = [strout,' 386 class machine. (Ray Sterner-1991)']
  strout = [strout,'']
  strout = [strout,' The widget version of this project was written using IDL 5.4']
  strout = [strout,' and updated a bit for release 5.6.']
  strout = [strout,' (Rob Dimeo-2002)']
  strout = [strout,' ']
  void = DIALOG_MESSAGE(dialog_parent = event.top,strout,/information)
  WIDGET_CONTROL,(*pState).hiddenTextId,/input_focus
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtquit,event
  WIDGET_CONTROL,event.top,/destroy
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtstart,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  (*pState).t_lpc = (*pState).t_pc
  (*pState).t_lln = (*pState).t_ln
  (*pState).t_lsc = (*pState).t_sc
  (*pState).oText->Changetext,index = 20,text = STRTRIM((*pState).t_lpc,2)
  (*pState).oText->Changetext,index = 21,text = STRTRIM((*pState).t_lln,2)
  (*pState).oText->Changetext,index = 22,text = STRTRIM((*pState).t_lsc,2)
  
  (*pState).t_hpc = (*pState).t_hpc > (*pState).t_pc
  (*pState).t_hln = (*pState).t_hln > (*pState).t_ln
  (*pState).t_hsc = (*pState).t_hsc > (*pState).t_sc
  (*pState).oText->Changetext,index = 23,text = STRTRIM((*pState).t_hpc,2)
  (*pState).oText->Changetext,index = 24,text = STRTRIM((*pState).t_hln,2)
  (*pState).oText->Changetext,index = 25,text = STRTRIM((*pState).t_hsc,2)
  
  Xtinit,event
  
  top = [-1]
  t_ny = (*pState).t_ny
  t_brd = *(*pState).t_brd
  tmp = FLTARR(t_ny)
  FOR j = 0,t_ny-1 DO tmp[j] = TOTAL(t_brd[*,j])
  mx = 1+MAX(WHERE(tmp NE 0))
  top = [top,mx]
  *(*pState).top = top
  WIDGET_CONTROL,(*pState).timerId,timer = (*pState).duration
  (*pState).loop = 1
  Xt_next,event
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xt_plot,event,flag = flag
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  c = 0
  IF flag EQ 1 THEN c = (*pState).t_c
  IF MAX((*pState).t_y+(*(*pState).t_pfy)) LT (*pState).t_ny THEN BEGIN
    POLYFILL, (*pState).t_x+(*(*pState).t_pfx), $
      (*pState).t_y+(*(*pState).t_pfy), color=c
  ENDIF
  
  RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xt_drop,event,done = done,range = range
  WIDGET_CONTROL,event.top,get_uvalue = pState
  t_brd = *(*pState).t_brd
  
  Xt_plot, event,flag = 0       ; Erase current position.
  (*pState).t_y = (*pState).t_y - 1   ; Drop one position.
  
  flag = 0                                ; Undo flag.
  IF MIN((*pState).t_y + (*(*pState).t_py)) LT 0 THEN flag = 1   ; Hit bottom.
  IF MAX(t_brd((*pState).t_x+(*(*pState).t_px), $
    (*pState).t_y+(*(*pState).t_py))) GT 0 THEN flag = 1    ; Collision.
    
  done = 0                                ; Assume not done yet.
  IF flag EQ 1 THEN BEGIN                 ; Done.
    (*pState).t_y = (*pState).t_y + 1                        ; Can't move down.
    t_brd((*pState).t_x+(*(*pState).t_px), $
      (*pState).t_y+(*(*pState).t_py)) = (*pState).t_c       ; Update board with color.
    done = 1                              ; Set done flag.
    range = [MIN((*pState).t_y+(*(*pState).t_py)), $
      MAX((*pState).t_y+(*(*pState).t_py))]  ; Range to check.
  ENDIF
  
  ; Update the "COMMON" variables
  *(*pState).t_brd = t_brd
  Xt_plot,event,flag = 1       ; Plot new position.
  RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xt_next,event,pn = pn
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  IF N_ELEMENTS(pn) EQ 0 THEN BEGIN
    (*pState).t_p = BYTE(RANDOMU(s)*7)  ; Pick a random piece #.
  ENDIF ELSE (*pState).t_p = pn         ; Use selected piece number.
  (*pState).t_r = 0                     ; Start in standard position.
  (*pState).t_c = (*pState).t_ca[(*pState).t_p]   ; Look up piece color.
  ; Pull out correct offsets.
  *(*pState).t_px = (*(*pState).t_pxa)(*, (*pState).t_r, (*pState).t_p)
  *(*pState).t_py = (*(*pState).t_pya)(*, (*pState).t_r, (*pState).t_p)
  ; Extract outline
  *(*pState).t_pfx = (*(*pState).t_pfxa)(0:(*pState).t_pflst((*pState).t_p), $
    (*pState).t_r,(*pState).t_p)
  *(*pState).t_pfy = (*(*pState).t_pfya)(0:(*pState).t_pflst((*pState).t_p), $
    (*pState).t_r,(*pState).t_p)
  (*pState).t_x = (*pState).t_nx/2                 ; Starting position.
  (*pState).t_y = (*pState).t_ny
  RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xt_score, event,r = r
  WIDGET_CONTROL,event.top,get_uvalue = pState
  ; Pull out all of the "COMMON" variables
  t_nx = (*pState).t_nx & t_ny = (*pState).t_ny & t_brd = *(*pState).t_brd
  t_p = (*pState).t_p & t_r = (*pState).t_r & t_x = (*pState).t_x
  t_y = (*pState).t_y & t_pxa = *(*pState).t_pxa & t_pya = *(*pState).t_pya
  t_px = *(*pState).t_px & t_py = *(*pState).t_py & t_ca = (*pState).t_ca
  t_c = (*pState).t_c & t_wait = (*pState).t_wait & t_pflst = (*pState).t_pflst
  t_pfxa = *(*pState).t_pfxa & t_pfya = *(*pState).t_pfya & t_pfx = *(*pState).t_pfx
  t_pfy = *(*pState).t_pfy & t_pc = (*pState).t_pc & t_lpc = (*pState).t_lpc
  t_hpc = (*pState).t_hpc & t_ln = (*pState).t_ln & t_lln = (*pState).t_lln
  t_hln = (*pState).t_hln & t_sc = (*pState).t_sc & t_lsc = (*pState).t_lsc
  t_hsc = (*pState).t_hsc
  
  ;---------  Add score for this piece  --------
  
  t_sc = t_sc + 7      ; Each piece worth 7 pts.
  (*pState).oText->Changetext,index = 19,text = STRTRIM(t_sc, 2)
  (*pState).t_sc = t_sc
  count = 0                                 ; Lines scored on piece.
  rn = (r(0)+INDGEN(r(1)-r(0)+1))<(t_ny-1)  ; Range to check.
  FOR i = 0, N_ELEMENTS(rn)-1 DO BEGIN      ; Check each line.
    IF TOTAL(t_brd(*,rn(i)) EQ 0) EQ 0 THEN BEGIN  ; Score.
      ;---  light up score line  ----
      xp = [0.01,.99,.99,0.01]*(t_nx-1)
      yp = [0.05,0.05,.99,.99]+rn(i)
      POLYFILL, xp,yp,color=0,spacing=.1,orient=0
      POLYFILL, xp,yp,color=0,spacing=.1,orient=90
      ;            wait, 0
      ;            ;---  ring bell  -----
      ;            if t_bell then print,string(7b),form='($,a1)'
      ;---  Collapse board  -------
      t_brd(0,rn(i)) = t_brd(*,(rn(i)+1):*)
      *(*pState).t_brd = t_brd
      ;---  Repaint screen board  -----
      tmp = FLTARR(t_ny)
      FOR j = 0, t_ny-1 DO tmp(j) = TOTAL(t_brd(*,j))
      mx = 1+MAX(WHERE(tmp NE 0))
      FOR z = 0.8, 0., -.2 DO BEGIN
        FOR iy = rn(i), mx DO BEGIN
          FOR ix = 0, t_nx-2 DO BEGIN
            c = t_brd(ix,iy)
            POLYFILL, [0,1,1,0]+ix, (z+[0,0,1,1]+iy)<(t_ny-1), color=c
          ENDFOR
        ENDFOR
      ENDFOR  ; Z
      ;---  Decrement range  ------
      rn = rn - 1
      ;----  Count scored line  -----
      count = count + 1
      ;---  Update score board  -----
      
      t_ln = t_ln + 1
      (*pState).t_ln = t_ln
      (*pState).oText->Changetext,index = 18,text = STRTRIM(t_ln,2)
      
      t_sc = t_sc + 22      ; Each line worth 22 pts.
      (*pState).t_sc = t_sc
      (*pState).oText->Changetext,index = 19,text = STRTRIM(t_sc,2)
      
    ENDIF
  ENDFOR
  
  ;--------  Check for a tetris (4 lines scored on 1 piece) ----
  IF count EQ 4 THEN BEGIN
    t_sc = t_sc + 48      ; 48 extra points.
    (*pState).t_sc = t_sc
    (*pState).oText->Changetext,index = 19,text = STRTRIM(t_sc,2)
  ENDIF
  
  RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtfinish,event, r = r
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  tmp = FLTARR((*pState).t_ny)
  FOR j = 0, (*pState).t_ny-1 DO tmp(j) = TOTAL((*(*pState).t_brd)(*,j))
  mx = 1+MAX(WHERE(tmp NE 0))
  *(*pState).top = [*(*pState).top,mx]
  IF MIN(r) GE (*pState).t_ny-1 THEN BEGIN  ; Game over?
    (*pState).loop = 0
    POLYFILL, [0,1,1,0]*((*pState).t_nx-1), [0,0,1,1]*((*pState).t_ny-1),$
      color=0, spacing=.1, orient=0
    POLYFILL, [0,1,1,0]*((*pState).t_nx-1), [0,0,1,1]*((*pState).t_ny-1),$
      color=0, spacing=.1, orient=90
    RETURN
  ENDIF
  ;------  Update current piece count  ------
  (*pState).t_pc = (*pState).t_pc + 1
  (*pState).oText->Changetext,index = 17,text = STRTRIM((*pState).t_pc,2)
  Xt_score,event,r = r                      ; Update score.
  Xt_next,event
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtleft,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  Xt_plot, event,flag = 0                  ; Erase current position.
  (*pState).t_x = (*pState).t_x - 1                           ; Shift left 1.
  
  flag = 0                                ; Undo flag.
  IF MIN((*pState).t_x + (*(*pState).t_px)) LT 0 THEN flag = 1   ; Out of bounds.
  IF MAX((*(*pState).t_brd)((*pState).t_x + (*(*pState).t_px), $
    (*pState).t_y + (*(*pState).t_py))) GT 0 THEN flag = 1    ; Collision.
    
  IF flag EQ 1 THEN (*pState).t_x = (*pState).t_x + 1         ; Undo.
  Xt_plot, event,flag = 1                               ; Plot new position.
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtright,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  Xt_plot, event, flag = 0             ; Erase current position.
  (*pState).t_x = (*pState).t_x + 1         ; Shift right 1.
  flag = 0              ; Undo flag.
  IF MAX((*pState).t_x + (*(*pState).t_px)) GT ((*pState).t_nx-2) THEN flag = 1 ; Out of bounds.
  IF MAX((*(*pState).t_brd)((*pState).t_x + (*(*pState).t_px), $
    (*pState).t_y + (*(*pState).t_py))) GT 0 THEN flag = 1    ; Collision.
  IF flag EQ 1 THEN (*pState).t_x = (*pState).t_x - 1         ; Undo.
  Xt_plot, event,flag = 1                                     ; Plot new position.
  
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtrotate,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  ; Pull out all of the "COMMON" variables
  t_nx = (*pState).t_nx & t_ny = (*pState).t_ny & t_brd = *(*pState).t_brd
  t_p = (*pState).t_p & t_r = (*pState).t_r & t_x = (*pState).t_x
  t_y = (*pState).t_y & t_pxa = *(*pState).t_pxa & t_pya = *(*pState).t_pya
  t_px = *(*pState).t_px & t_py = *(*pState).t_py & t_ca = (*pState).t_ca
  t_c = (*pState).t_c & t_wait = (*pState).t_wait & t_pflst = (*pState).t_pflst
  t_pfxa = *(*pState).t_pfxa & t_pfya = *(*pState).t_pfya & t_pfx = *(*pState).t_pfx
  t_pfy = *(*pState).t_pfy & t_pc = (*pState).t_pc & t_lpc = (*pState).t_lpc
  t_hpc = (*pState).t_hpc & t_ln = (*pState).t_ln & t_lln = (*pState).t_lln
  t_hln = (*pState).t_hln & t_sc = (*pState).t_sc & t_lsc = (*pState).t_lsc
  t_hsc = (*pState).t_hsc
  
  Xt_plot,event,flag = 0               ; Erase current position.
  
  t_r = (t_r + 1) MOD 4   ; Rotate.
  t_px = t_pxa(*,t_r,t_p) ; Extract new offsets.
  t_py = t_pya(*,t_r,t_p)
  t_pfx = t_pfxa(0:t_pflst(t_p),t_r,t_p)    ; Extract outline.
  t_pfy = t_pfya(0:t_pflst(t_p),t_r,t_p)
  
  ;----  Check for out of bounds or collision. -----
  flag = 0                ; Undo flag.
  ;------  Don't rotate out the sides  ---------
  IF (MIN(t_x+t_px) LT 0) OR (MAX(t_x+t_px) GT (t_nx-2)) THEN flag = 1
  ;------  Don't rotate out the bottom  -----
  IF (MIN(t_y+t_py) LT 0) THEN flag = 1
  ;------  Check collision with another piece  ------
  IF MAX(t_brd(t_x+t_px, t_y+t_py)) GT 0 THEN flag = 1    ; Collision.
  IF flag EQ 1 THEN BEGIN    ; Undo.
    t_r = (t_r + 3) MOD 4    ; Rotate 270 = -90.
    t_px = t_pxa(*,t_r,t_p)  ; Extract new offsets.
    t_py = t_pya(*,t_r,t_p)
    t_pfx = t_pfxa(0:t_pflst(t_p),t_r,t_p)    ; Extract outline.
    t_pfy = t_pfya(0:t_pflst(t_p),t_r,t_p)
  ENDIF
  
  (*pState).t_r = t_r
  *(*pState).t_px = t_px
  *(*pState).t_py = t_py
  *(*pState).t_pfx = t_pfx
  *(*pState).t_pfy = t_pfy
  
  Xt_plot, event,flag = 1               ; Plot new position.
  
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtevents,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  thisEvent = TAG_NAMES(event,/structure_name)
  CASE thisEvent OF
    'WIDGET_BUTTON': $
      BEGIN
      uname = WIDGET_INFO(event.id,/uname)
      IF uname EQ 'NOVICE' THEN BEGIN
        (*pState).duration = 0.5
        IF (!version).release GE 5.6 THEN $
          WIDGET_CONTROL,event.id,set_button = 1
        id1 = WIDGET_INFO(event.top,find_by_uname = $
          'INTERMEDIATE')
        id2 = WIDGET_INFO(event.top,find_by_uname = $
          'EXPERT')
        WIDGET_CONTROL,id1,set_button = 0
        WIDGET_CONTROL,id2,set_button = 0
      ENDIF
      IF uname EQ 'INTERMEDIATE' THEN BEGIN
        (*pState).duration = 0.25
        IF (!version).release GE 5.6 THEN $
          WIDGET_CONTROL,event.id,set_button = 1
        id1 = WIDGET_INFO(event.top,find_by_uname = $
          'NOVICE')
        id2 = WIDGET_INFO(event.top,find_by_uname = $
          'EXPERT')
        WIDGET_CONTROL,id1,set_button = 0
        WIDGET_CONTROL,id2,set_button = 0
      ENDIF
      IF uname EQ 'EXPERT' THEN BEGIN
        (*pState).duration = 0.1
        IF (!version).release GE 5.6 THEN $
          WIDGET_CONTROL,event.id,set_button = 1
        id1 = WIDGET_INFO(event.top,find_by_uname = $
          'INTERMEDIATE')
        id2 = WIDGET_INFO(event.top,find_by_uname = $
          'NOVICE')
        WIDGET_CONTROL,id1,set_button = 0
        WIDGET_CONTROL,id2,set_button = 0
      ENDIF
    END
    'WIDGET_TEXT_CH': $
      BEGIN
      CASE STRUPCASE(event.ch) OF
      
        ' ':  BEGIN
          IF (*pState).loop EQ 1 THEN Xtrotate,event
        END
        'H':	Xthelp,event
        'P':	(*pState).loop = 0
        'R':	(*pState).loop = 1
        'Q':	BEGIN
          Xtquit,event
          RETURN
        END
        'A':	BEGIN
          IF (*pState).loop EQ 1 THEN Xtleft,event
        END
        'F':	BEGIN
          IF (*pState).loop EQ 1 THEN Xtright,event;(*pState).direction = 'E'
        END
        ELSE:
      ENDCASE
    END
    ELSE:  WIDGET_CONTROL,(*pState).hiddenTextId,/input_focus
  ENDCASE
  
  IF (*pState).loop EQ 1 THEN BEGIN	; update display
    Xt_drop,event, done = d, range = r
    IF d EQ 1 THEN BEGIN	; piece is done moving
      Xtfinish,event,r = r
    ENDIF
    
    WIDGET_CONTROL,(*pState).timerId,timer = (*pState).duration
  ENDIF
  
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtinit,event
  WIDGET_CONTROL,event.top,get_uvalue = pState
  
  t_pxa = INTARR(4,4,7)
  t_pxa(0,0,0) = [[0,1,0,1], $   ; Piece # 0:  X X
    [0,1,0,1], $   ;             X X
    [0,1,0,1], $
    [0,1,0,1]]
    
  t_pxa(0,0,1) = [[-2,-1,0,1], $ ; Piece # 1: X X X X
    [0,0,0,0], $
    [-2,-1,0,1],$
    [0,0,0,0]]
    
  t_pxa(0,0,2) = [[-1,0,1,0], $  ; Piece # 2:  X X X
    [0,0,0,1], $   ;               X
    [-1,0,1,0], $
    [0,0,0,-1]]
    
  t_pxa(0,0,3) = [[-1,0,0,1], $  ; Piece # 3:    X X
    [0,0,-1,-1], $ ;                 X X
    [0,-1,-1,-2], $
    [-1,-1,0,0]]
    
  t_pxa(0,0,4) = [[-1,0,0,1], $  ; Piece # 4:      X X
    [-1,-1,0,0], $ ;               X X
    [0,-1,-1,-2], $
    [0,0,-1,-1]]
    
  t_pxa(0,0,5) = [[-1,0,1,1],$   ; Piece # 5:    X X X
    [0,0,0,1], $   ;                   X
    [1,0,-1,-1], $
    [0,0,0,-1]]
    
  t_pxa(0,0,6) = [[1,0,-1,-1],$  ; Piece # 6:    X X X
    [0,0,0,1],$    ;               X
    [-1,0,1,1],$
    [0,0,0,-1]]
    
  ;---  Set up Y offsets for 7 4 part pieces, each with 4 rotations --
  t_pya = INTARR(4,4,7)
  
  t_pya(0,0,0) = [[0,0,1,1],[0,0,1,1],[0,0,1,1],[0,0,1,1]]
  t_pya(0,0,1) = [[0,0,0,0],[-2,-1,0,1],[0,0,0,0],[-2,-1,1,0]]
  t_pya(0,0,2) = [[0,0,0,-1],[-1,0,1,0],[0,0,0,1],[1,0,-1,0]]
  t_pya(0,0,3) = [[0,0,-1,-1],[0,-1,-1,-2],[-1,-1,0,0],[-1,0,0,1]]
  t_pya(0,0,4) = [[-1,-1,0,0],[0,-1,-1,-2],[0,0,-1,-1],[-1,0,0,1]]
  t_pya(0,0,5) = [[0,0,0,-1],[-1,0,1,1],[0,0,0,1],[1,0,-1,-1]]
  t_pya(0,0,6) = [[0,0,0,-1],[1,0,-1,-1],[0,0,0,1],[-1,0,1,1]]
  
  ;------  Setup pieces as outlines  ---------
  t_pfxa = INTARR(8,4,7)
  t_pfxa(0,0,0) = [[0,2,2,0,0,0,0,0],$
    [0,2,2,0,0,0,0,0],$
    [0,2,2,0,0,0,0,0],$
    [0,2,2,0,0,0,0,0]]
  t_pfxa(0,0,1) = [[-2,2,2,-2,0,0,0,0],$
    [0,1,1,0,0,0,0,0],$
    [-2,2,2,-2,0,0,0,0],$
    [0,1,1,0,0,0,0,0]]
  t_pfxa(0,0,2) = [[-1,0,0,1,1,2,2,-1],$
    [0,1,1,2,2,1,1,0],$
    [-1,2,2,1,1,0,0,-1],$
    [-1,0,0,1,1,0,0,-1]]
  t_pfxa(0,0,3) = [[-1,0,0,2,2,1,1,-1],$
    [-1,0,0,1,1,0,0,-1],$
    [-2,-1,-1,1,1,0,0,-2],$
    [-1,0,0,1,1,0,0,-1]]
  t_pfxa(0,0,4) = [[-1,1,1,2,2,0,0,-1],$
    [0,1,1,0,0,-1,-1,0],$
    [-2,0,0,1,1,-1,-1,-2],$
    [0,1,1,0,0,-1,-1,0]]
  t_pfxa(0,0,5) = [[-1,1,1,2,2,-1,0,0],$
    [0,1,1,2,2,0,0,0],$
    [-1,2,2,0,0,-1,0,0],$
    [-1,1,1,0,0,-1,0,0]]
  t_pfxa(0,0,6) = [[-1,0,0,2,2,-1,0,0],$
    [0,2,2,1,1,0,0,0],$
    [-1,2,2,1,1,-1,0,0],$
    [0,1,1,-1,-1,0,0,0]]
  t_pfya = INTARR(8,4,7)
  t_pfya(0,0,0) = [[0,0,2,2,0,0,0,0],$
    [0,0,2,2,0,0,0,0],$
    [0,0,2,2,0,0,0,0],$
    [0,0,2,2,0,0,0,0]]
  t_pfya(0,0,1) = [[0,0,1,1,0,0,0,0],$
    [-2,-2,2,2,0,0,0,0],$
    [0,0,1,1,0,0,0,0],$
    [-2,-2,2,2,0,0,0,0]]
  t_pfya(0,0,2) = [[0,0,-1,-1,0,0,1,1],$
    [-1,-1,0,0,1,1,2,2],$
    [0,0,1,1,2,2,1,1],$
    [0,0,-1,-1,2,2,1,1]]
  t_pfya(0,0,3) = [[0,0,-1,-1,0,0,1,1],$
    [-2,-2,-1,-1,1,1,0,0],$
    [0,0,-1,-1,0,0,1,1],$
    [-1,-1,0,0,2,2,1,1]]
  t_pfya(0,0,4) = [[-1,-1,0,0,1,1,0,0],$
    [-2,-2,0,0,1,1,-1,-1],$
    [-1,-1,0,0,1,1,0,0],$
    [-1,-1,1,1,2,2,0,0]]
  t_pfya(0,0,5) = [[0,0,-1,-1,1,1,0,0],$
    [-1,-1,1,1,2,2,0,0],$
    [0,0,1,1,2,2,0,0],$
    [-1,-1,2,2,0,0,0,0]]
  t_pfya(0,0,6) = [[-1,-1,0,0,1,1,0,0],$
    [-1,-1,0,0,2,2,0,0],$
    [0,0,2,2,1,1,0,0],$
    [-1,-1,2,2,1,1,0,0]]
  *(*pState).t_pxa = t_pxa
  *(*pState).t_pya = t_pya
  *(*pState).t_pfxa = t_pfxa
  *(*pState).t_pfya = t_pfya
  
  t_brd = BYTARR((*pState).t_nx-1,(*pState).t_ny)
  
  IF ABS((*pState).lev) GT 0 THEN BEGIN
    lset = (BYTE(RANDOMU(i,(*pState).t_nx-1,ABS((*pState).lev))*8)<7B)* $
      BYTE(RANDOMU(i,(*pState).t_nx-1,ABS((*pState).lev)) GT .5)
    IF (*pState).lev LT 0 THEN lset = 8*(lset NE 0)
    t_brd(0,0) = lset
  ENDIF
  *(*pState).t_brd = t_brd
  
  WSET,(*pState).winPix
  ERASE
  t_nx = (*pState).t_nx
  t_ny = (*pState).t_ny
  lev = (*pState).lev
  ;-------  Scale board to screen  --------
  PLOT,[0,(*pState).t_nx-1],[0,(*pState).t_ny-1],position=[.1,.1,.4,.9],/xsty,/ysty,/nodata
  ;-------  Outline board  -----------------
  ERASE
  POLYFILL, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
    color=10
  POLYFILL, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
    color=9, spacing=.15, orient=0
  POLYFILL, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
    color=9, spacing=.15, orient=90
  POLYFILL,[-.2,t_nx-.8,t_nx-.8,-.2],$
    [-.2,-.2,t_ny-.8,t_ny-.8]
  POLYFILL,[0,1,1,0]*(t_nx-1),[0,0,1,1]*(t_ny-1), color=0
  PLOTS,[-1,t_nx,t_nx,-1,-1],[-1,-1,t_ny,t_ny,-1],thick=3
  
  ;------  Show starting board  --------
  IF ABS(lev) GT 0 THEN BEGIN
    FOR iy = 0, ABS(lev) DO BEGIN
      FOR ix = 0, t_nx-2 DO BEGIN
        c = t_brd(ix,iy)
        POLYFILL, [0,1,1,0]+ix, [0,0,1,1]+iy, color=c
      ENDFOR
    ENDFOR
  ENDIF
  
  ;------  Menu  -----
  IF (*pState).t_init_flag EQ 0 THEN BEGIN
    (*pState).oText->Addtext,txtSize=1.2, x=325, y=310, text='A = Move left'	;1
    (*pState).oText->Addtext,txtSize=1.2, x=475, y=310, text='F = Move right'	;2
    (*pState).oText->Addtext,txtSize=1.2, x=325, y=290, text='SPACE = Rotate'	;3
    (*pState).oText->Addtext,txtSize=1.2, x=475, y=290, text='H = Help'
    (*pState).oText->Addtext,txtSize=1.2, x=325, y=270, text='P = Pause'
    (*pState).oText->Addtext,txtSize=1.2, x=475, y=270, text='Q = Quit'
    (*pState).oText->Addtext,txtSize=1.2, x=325, y=250, text='R = Resume'		;7
    
    (*pState).oText->Addtext,txtSize=1.8, x=310, y=160, text='Pieces'	;8
    (*pState).oText->Addtext,txtSize=1.8, x=310, y=130, text='Lines'
    (*pState).oText->Addtext,txtSize=1.8, x=310, y=100, text='Score'
    (*pState).oText->Addtext,txtSize=1.2, x=410, y=210, text='This'
    (*pState).oText->Addtext,txtSize=1.2, x=410, y=190, text='Game'
    (*pState).oText->Addtext,txtSize=1.2, x=480, y=210, text='Last'
    (*pState).oText->Addtext,txtSize=1.2, x=480, y=190, text='Game'
    (*pState).oText->Addtext,txtSize=1.2, x=550, y=210, text='Session'
    (*pState).oText->Addtext,txtSize=1.2, x=550, y=190, text='High'	;16
    
    (*pState).oText->Addtext,txtSize=1.2, x=410, y=160, $
      text=STRTRIM((*pState).t_pc,2);17
    (*pState).oText->Addtext,txtSize=1.2, x=410, y=130, $
      text=STRTRIM((*pState).t_ln,2);18
    (*pState).oText->Addtext,txtSize=1.2, x=410, y=100, $
      text=STRTRIM((*pState).t_sc,2);19
    (*pState).oText->Addtext,txtSize=1.2, x=480, y=160, $
      text=STRTRIM((*pState).t_lpc,2);20
    (*pState).oText->Addtext,txtSize=1.2, x=480, y=130, $
      text=STRTRIM((*pState).t_lln,2);21
    (*pState).oText->Addtext,txtSize=1.2, x=480, y=100, $
      text=STRTRIM((*pState).t_lsc,2);22
    (*pState).oText->Addtext,txtSize=1.2, x=550, y=160, $
      text=STRTRIM((*pState).t_hpc,2);23
    (*pState).oText->Addtext,txtSize=1.2, x=550, y=130, $
      text=STRTRIM((*pState).t_hln,2);24
    (*pState).oText->Addtext,txtSize=1.2, x=550, y=100, $
      text=STRTRIM((*pState).t_hsc,2);25
      
    (*pState).t_init_flag = 1
  ENDIF ELSE (*pState).oText->Displayall
  
  (*pState).t_pc = 0	; Current score.
  (*pState).t_ln = 0
  (*pState).t_sc = 0
  (*pState).oText->Changetext,index = 17,text = STRTRIM((*pState).t_pc,2)
  (*pState).oText->Changetext,index = 18,text = STRTRIM((*pState).t_ln,2)
  (*pState).oText->Changetext,index = 19,text = STRTRIM((*pState).t_sc,2)
  
  ;-------  Load color table  --------
  TVLCT, $
    [0,255,255,127,255,127,255,127,128,255,  0,  0,255,255,255,255],$
    [0,127,127,255,255,127,189,255,128,255,  0,255,  0,255,255,255],$
    [0,127,255,255,127,255,127,127,128,255,255,233,  0,  0,  0,255]
    
  ;---------  Make title  --------
  xshft = 30
  XYOUTS, 25+300+xshft, 400+15, /dev, size=3, '!17IDL Tetris', color=10
  XYOUTS, 25+301+xshft, 401+15, /dev, size=3, '!17IDL Tetris', color=10
  XYOUTS, 25+302+xshft, 402+15, /dev, size=3, '!17IDL Tetris', color=11
  XYOUTS, 25+303+xshft, 403+15, /dev, size=3, '!17IDL Tetris', color=11
  XYOUTS, 25+304+xshft, 404+15, /dev, size=3, '!17IDL Tetris', color=12
  XYOUTS, 25+305+xshft, 405+15, /dev, size=3, '!17IDL Tetris', color=12
  XYOUTS, 25+306+xshft, 406+15, /dev, size=3, '!17IDL Tetris', color=13
  XYOUTS, 25+307+xshft, 407+15, /dev, size=3, '!17IDL Tetris', color=13
  xval1 = 80
  xval2 = 50
  XYOUTS, /dev, size=2, 23+392-xval1, 370+13, $
    '!13Adaptation/Original by', color=12
  XYOUTS, /dev, size=2, 23+342-xval2, 336+13, $
    '!13Rob Dimeo/Ray Sterner!3', color=12
  XYOUTS, /dev, size=2, 24+392-xval1, 370+14, $
    '!13Adaptation/Original by', color=12
  XYOUTS, /dev, size=2, 24+342-xval2, 336+14, $
    '!13Rob Dimeo/Ray Sterner!3', color=12
  XYOUTS, /dev, size=2, 25+392-xval1, 370+15, $
    '!13Adaptation/Original by', color=6
  XYOUTS, /dev, size=2, 25+342-xval2, 336+15, $
    '!13Rob Dimeo/Ray Sterner!3', color=6
    
  WSET,(*pState).winVis
  DEVICE,copy = [0,0,!d.x_size,!d.y_size,0,0,(*pState).winPix]
  
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Xtetris
  ; Widget definition module
  DEVICE,decomposed = 0
  registerName = 'xtetris'
  IF XREGISTERED(registerName) THEN RETURN
  tlb = WIDGET_BASE(/col,title = 'xTetris',mbar = bar,/tlb_frame_attr)
  skill = WIDGET_BUTTON(bar,value = 'Skill Level',/menu)
  IF (!version).release LT 5.6 THEN BEGIN
    void = WIDGET_BUTTON(skill,value = 'NOVICE',uname = 'NOVICE')
    void = WIDGET_BUTTON(skill,value = 'INTERMEDIATE',uname = 'INTERMEDIATE')
    void = WIDGET_BUTTON(skill,value = 'EXPERT',uname = 'EXPERT')
  ENDIF ELSE BEGIN
    void = WIDGET_BUTTON(skill,value = 'NOVICE',uname = 'NOVICE',/checked_menu)
    void = WIDGET_BUTTON(skill,value = 'INTERMEDIATE',uname = 'INTERMEDIATE',/checked_menu)
    void = WIDGET_BUTTON(skill,value = 'EXPERT',uname = 'EXPERT',/checked_menu)
  ENDELSE
  void = WIDGET_BUTTON(tlb,value = 'START',event_pro = 'xtStart')
  xsize = 650 & ysize = 500
  ; Now create a "bulletin board" type base and put a draw widget and
  ; a text widget on it.
  bulBase = WIDGET_BASE(tlb);		bulletin board base
  win = WIDGET_DRAW(bulBase,xsize = xsize,ysize = ysize)
  hiddenTextId = WIDGET_TEXT(bulBase,scr_xsize = 1,scr_ysize = 1,/all_events)
  
  WIDGET_CONTROL,tlb,/realize
  IF (!version).release GE 5.6 THEN BEGIN
    id = WIDGET_INFO(tlb,find_by_uname = 'EXPERT')
    WIDGET_CONTROL,id,set_button = 2
  ENDIF
  WIDGET_CONTROL,win,get_value = winVis
  WINDOW,/free,/pixmap,xsize = xsize,ysize = ysize
  winPix = !d.window
  xpos = FIX(0.5*xsize)
  ypos = ysize
  
  ; Define the filled circle symbol
  th = (2.0*!pi/20.)*FINDGEN(21)
  xc = COS(th) & yc = SIN(th)
  USERSYM,xc,yc,/fill
  
  t_nx = 11
  t_ny = 21
  
  state = {	winPix:winPix,		$
    win:win,			$
    winVis:winVis,		$
    duration:0.05,		$
    symsize:2.0,		$
    hiddenTextId:hiddenTextId,	$
    direction:'S',		$
    xincrement:8,		$
    yincrement:8,		$
    xpos:xpos,			$
    ypos:ypos,			$
    loop:0,				$
    timerID:bulBase,	$
    oText:OBJ_NEW('printObj'),	$
    
    t_init_flag:0,				$
    wt:(-1),	$
    t_wait:0.1,	$
    lev:0,		$
    t_ln:0,	$
    t_pc:0,	$
    t_sc:0,	$
    t_lln:0,	$
    t_lpc:0,	$
    t_lsc:0,	$
    t_hln:0,	$
    t_hpc:0,	$
    t_hsc:0,	$
    
    t_p:0,		$
    t_r:0,	$
    t_x:0,	$
    t_y:0,	$
    t_px:PTR_NEW(0),	$
    t_py:PTR_NEW(0),	$
    t_c:0,	$
    t_pfx:PTR_NEW(0),	$
    t_pfy:PTR_NEW(0),	$
    
    top:PTR_NEW(/allocate_heap),	$
    t_nx:t_nx,					$
    t_ny:t_ny,					$
    t_brd:PTR_NEW(/allocate_heap),	$
    t_ca:(1+INDGEN(8)),			$
    t_pxa:PTR_NEW(/allocate_heap),		$
    t_pya:PTR_NEW(/allocate_heap),		$
    t_pflst:[3,3,7,7,7,5,5],	$
    t_pfxa:PTR_NEW(/allocate_heap),		$
    t_pfya:PTR_NEW(/allocate_heap)		$
    
    }
    
  pState = PTR_NEW(state,/no_copy)
  WIDGET_CONTROL,tlb,set_uvalue = pState
  pseudoEvent = {pEvent,id:win,top:tlb,handler:0L}
  Xtinit,pseudoEvent
  Xt_next,pseudoEvent
  WIDGET_CONTROL,(*pState).hiddenTextId,/input_focus
  
  XMANAGER,registerName,tlb,event_handler = 'xtEvents', $
    cleanup = 'xtCleanup',/no_block
    
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;+
; NAME:
;       PRINTOBJ__DEFINE
;
; PURPOSE:
;
;       This object class mimics the functionality of the routine SPRINT.PRO
;	written by Ray Sterner for use in the program TETRIS.PRO.  This object
;	class removes the common block.  This object class is used in the
;	widget program XTETRIS.PRO.
;
; AUTHOR:
;
;       Robert M. Dimeo, Ph.D.
;	NIST Center for Neutron Research
;       100 Bureau Drive
;	Gaithersburg, MD 20899
;       Phone: (301) 975-8135
;       E-mail: robert.dimeo@nist.gov
;       http://www.ncnr.nist.gov/staff/dimeo
;
; CATEGORY:
;
;       Objects, widgets
;
; CALLING SEQUENCE:
;
;       object = obj_new('PRINTOBJ')
;
;
; INPUT PARAMETERS:
;
;       NONE
;
; INPUT KEYWORDS:
;
;       NONE
;
; REQUIRED PROGRAMS:
;
;       NONE
;
; COMMON BLOCKS:
;
;       NONE
;
; RESTRICTIONS
;
;       NONE
;
; OBJECT METHODS:
;
; There are no explicitly private object methods in IDL but the
; methods used in this class are divided into PUBLIC and PRIVATE
; to indicate which ones should be used by users who wish to run
; the program from the command line, for instance.
;
; PUBLIC OBJECT PROCEDURE METHODS:
;
;   addText --		initializes text at device coordinates (x,y).
;	USAGE: o->addText,x = x,y = y,text = text, txtSize = txtSize, $
;			  color = color, erase = erase
;
;   changeText --	changes text whose index is given by the order in which
;			it was added using the addText method
;	USAGE: o->changeText,text = text, index = index, color = color, $
;			txtSize = txtSize,erase = erase
;
;   displayAll --	displays all of the text that has been added using addText
;	USAGE: o->displayAll
;
;   clear --		clears all of the text that has been added using addText
;
;
; PRIVATE OBJECT PROCEDURE METHODS:
;
;   cleanup -- frees the pointers
;
;   init -- standard object class initialization
;
; EXAMPLE
;
;	IDL>	o = obj_new('printobj')		; instantiate the object class
;	IDL>	window,0,xsize = 400,ysize = 400
;		Initialize a text string, 'Hi there', to appear at (325,310) in device coordinates
;	IDL>	o-> addText,txtSize=1.2, x=325, y=310, text='Hi'
;		Initialize a text string, 'Hello', to appear at (125,100) in device coordinates
;	IDL>	o-> addText,txtSize = 3.4,x = 125,y = 100,text = 'Hello'
;		Change the first string from 'Hi' to 'Oh no'
;	IDL>	o -> changeText,index = 1,text = 'Oh no'
;		Destroy the object
;	IDL>	obj_destroy,o
;
;
; DISCLAIMER
;
;	This software is provided as is without any warranty whatsoever.
;	Permission to use, copy, modify, and distribute modified or
;	unmodified copies is granted, provided this disclaimer
;	is included unchanged.
;
; MODIFICATION HISTORY:
;
;       Written by Rob Dimeo, December 7, 2002.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO printObj::cleanup
  COMPILE_OPT idl2,hidden
  PTR_FREE,self.xPtr,self.yPtr
  PTR_FREE,self.sizePtr,self.textPtr
  PTR_FREE,self.colorPtr,self.indexPtr
  PTR_FREE,self.erasePtr
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO printObj::addText,	x = x, $
    y = y, $
    txtSize = txtSize,	$
    text = text, $
    color = color, $
    erase = erase
  COMPILE_OPT idl2,hidden
  IF N_ELEMENTS(erase) EQ 0 THEN erase = 0
  IF N_ELEMENTS(txtSize) EQ 0 THEN txtSize = 1
  IF N_ELEMENTS(color) EQ 0 THEN color = !p.color
  
  IF N_ELEMENTS(*self.xPtr) EQ 0 THEN BEGIN	; first one
    *self.xPtr = [x]
    *self.yPtr = [y]
    *self.textPtr = [text]
    *self.colorPtr = [color]
    *self.sizePtr = [txtSize]
    *self.indexPtr = [1]
    *self.erasePtr = [ERASE]
  ENDIF ELSE BEGIN	; adding another
    *self.xPtr = [*self.xPtr,x]
    *self.yPtr = [*self.yPtr,y]
    *self.textPtr = [*self.textPtr,text]
    *self.colorPtr = [*self.colorPtr,color]
    *self.sizePtr = [*self.sizePtr,txtSize]
    *self.erasePtr = [*self.erasePtr,ERASE]
    newIndex = N_ELEMENTS(*self.indexPtr) + 1
    *self.indexPtr = [*self.indexPtr,newIndex]
  ENDELSE
  
  ; Display the latest addition
  XYOUTS,/dev,x,y,text,color = color,charSize = txtSize
  
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO printObj::changeText,	text = text, $
    index = index, $
    color = color, $
    txtSize = txtSize, $
    erase = erase
  COMPILE_OPT idl2,hidden
  IF N_ELEMENTS(erase) EQ 0 THEN erase = (*self.erasePtr)[index - 1]
  ; First erase the old text
  x = (*self.xPtr)[index - 1]
  y = (*self.yPtr)[index - 1]
  oldText = (*self.textPtr)[index - 1]
  XYOUTS,/dev,x,y,oldText,color = erase, $
    charsize = (*self.sizePtr)[index - 1]
    
  ; Now display the new text
  IF N_ELEMENTS(color) EQ 0 THEN color = (*self.colorPtr)[index - 1]
  IF N_ELEMENTS(txtSize) EQ 0 THEN txtSize = (*self.sizePtr)[index - 1]
  XYOUTS,/dev,x,y,text,charsize = txtSize,color = color
  (*self.colorPtr)[index-1] = color
  (*self.sizePtr)[index-1] = txtSize
  (*self.textPtr)[index-1] = text
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO printObj::displayAll
  COMPILE_OPT idl2,hidden
  n = N_ELEMENTS(*self.xPtr)
  IF n EQ 0 THEN RETURN
  FOR i = 0,n-1 DO BEGIN
    x = (*self.xPtr)[i]
    y = (*self.yPtr)[i]
    text = (*self.textPtr)[i]
    color = (*self.colorPtr)[i]
    txtSize = (*self.sizePtr)[i]
    XYOUTS,/dev,x,y,text,color = color,charSize = txtSize
  ENDFOR
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO printObj::clear
  PTR_FREE,self.xPtr,self.yPtr
  PTR_FREE,self.sizePtr,self.textPtr
  PTR_FREE,self.colorPtr,self.indexPtr
  PTR_FREE,self.erasePtr
  self.xPtr = PTR_NEW(/allocate_heap)
  self.yPtr = PTR_NEW(/allocate_heap)
  self.sizePtr = PTR_NEW(/allocate_heap)
  self.textPtr = PTR_NEW(/allocate_heap)
  self.colorPtr = PTR_NEW(/allocate_heap)
  self.indexPtr = PTR_NEW(/allocate_heap)
  self.erasePtr = PTR_NEW(/allocate_heap)
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION printObj::init
  COMPILE_OPT idl2,hidden
  self.xPtr = PTR_NEW(/allocate_heap)
  self.yPtr = PTR_NEW(/allocate_heap)
  self.sizePtr = PTR_NEW(/allocate_heap)
  self.textPtr = PTR_NEW(/allocate_heap)
  self.colorPtr = PTR_NEW(/allocate_heap)
  self.indexPtr = PTR_NEW(/allocate_heap)
  self.erasePtr = PTR_NEW(/allocate_heap)
  RETURN,1
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Printobj__define
  COMPILE_OPT idl2,hidden
  define = {	printObj,		$
    xPtr:PTR_NEW(),		$
    yPtr:PTR_NEW(),		$
    sizePtr:PTR_NEW(),	$
    textPtr:PTR_NEW(),	$
    colorPtr:PTR_NEW(),	$
    erasePtr:PTR_NEW(),	$
    indexPtr:PTR_NEW()	$
    }
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
