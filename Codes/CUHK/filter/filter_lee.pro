;-   
;- Purpose:
;-    Do Lee-filter.
;- Calling Sequence:
;-    Result= FILTER_LEE(phase, winsize=winsize, sig=sig)
;- Inputs:
;-    phase: Phase to be filtered.
;- Optional Input Parameters:
;-    None.
;- Keyword Input Parameters:
;-    winsize: Window size for the filter.
;-    sig:  A keyword for lee filter.
;- Outputs:
;-    Filtered phase
;- Commendations:
;-    sig: The larger ,the more seriously filtered.1,2 or 3 will be enough.
;- Example:
;    infile= 'D:\ForExperiment\TSX_TJ_500\20090327.rslc'
;    slc= OPENSLC(infile)
;    phase= ATAN(slc,/PHASE)
;    winsize=5
;    sig=2
;    result= FILTER_LEE(phase, winsize=winsize, sig=sig)
;- Modification History:
;-    19/02/2012: Written by T.Li @ InSAR Team in CUHK

FUNCTION FILTER_LEE, phase, winsize=winsize, sig=sig,display=display
  
  ;-------------Input Params-------------
  IF N_PARAMS() NE 1 THEN result= DIALOG_MESSAGE('Usage:'+ STRING(13B)+ 'result= FILTER_LEE(phase, winsize=winsize, sig=sig)')
  IF ~KEYWORD_SET(winsize) THEN winsize=5
  IF ~KEYWORD_SET(sig) THEN sig=3
  ;-------------Input Params-------------
  
  result= LEEFILT(phase, winsize ,sig)
  
;  IF KEYWORD_SET(display) THEN BEGIN
;      DEVICE, DECOMPOSED=0
;  WINDOW,0, TITLE='Original', XSIZE=500, YSIZE=500
;  LOADCT, 25
;  TVSCL, phase
;  
;  WINDOW,1, TITLE='Filtered', XSIZE=500, YSIZE=500
;  TVSCL, result
;  DEVICE, DECOMPOSED=1
;  ENDIF
  
  RETURN, result

END