;-
;- Script that:
;-      Show the Detail of Every PRO and FUNCTION
;- Usage:
;-      Run it.
;- Write by:
;-      T Li @ InSAR Team in SWJTU
;-      23:21, 2011-10-05
;-

PRO MyInSARTools

  DEVICE, GET_SCREEN_SIZE=ScreenSize
  width   =600
;  hight  =ScreenSize(1)
  IF width GT ScreenSize(0) THEN BEGIN
    result=DIALOG_MESSAGE('电脑分辨率过低',/INFORMATION)
    RETURN
  ENDIF
  xoffset = (ScreenSize(0)-width)/2
  tlb= WIDGET_BASE(TITLE='Functions And Pro. Written by T. Li @ InSAR Team in SWJTU', $
                   XSIZE=600, XOFFSET=xoffset, MBAR=mbar, TLB_FRAME_ATTR=1)
  fmenu= WIDGET_BUTTON(mbar, value='File')
    omenu= WIDGET_BUTTON(fmenu, value='Open', menu=2)
      button= WIDGET_BUTTON(omenu, value='BMP')
      button= WIDGET_BUTTON(omenu, value='SLC')
  button= WIDGET_BUTTON(mbar, value='Choose PS')
  
  
  WIDGET_CONTROL, tlb, /REALIZE
  XMANAGER, 'MYINSARTOOLS', tlb, /NO_BLOCK

END