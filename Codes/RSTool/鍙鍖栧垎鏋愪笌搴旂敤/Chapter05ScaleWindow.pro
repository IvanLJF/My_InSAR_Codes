; Chapter05ScaleWindow.pro
PRO Chapter05ScaleWindow
FOR i = 1,200 DO BEGIN
    WINDOW, TITLE = 'My Window', XPOS=100+i, YPOS=100+i, XSIZE=400-i, YSIZE=400-i
    PLOT, SIN(FINDGEN(100)/10)
    WAIT, 0.01
    WDELETE
ENDFOR
END