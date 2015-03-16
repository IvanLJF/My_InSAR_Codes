PRO DISPLAY, image=image, wid=wid
  
  IF N_ELEMENTS(wid) EQ 0 THEN wid=!D.WINDOW
  WSET, wid
  TV, image
  
END