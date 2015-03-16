; Chapter08Contour.pro
PRO Chapter08Contour
    mywindow = OBJ_NEW('IDLgrWindow', RETAIN=2)
    myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,0,19,19])
    mymodel = OBJ_NEW('IDLgrModel')
    data = DIST(20)
    mycontour = OBJ_NEW('IDLgrContour', data, COLOR=[100,150,200], $
        C_LINESTYLE=[0,2,4], /PLANAR, GEOMZ=0, C_VALUE=INDGEN(20))
    myview -> Add, mymodel
    mymodel -> Add, mycontour
    mywindow -> Draw, myview
    val = ''
    READ, val, PROMPT='Press <Return> to quit.'
    OBJ_DESTROY, myview
    OBJ_DESTROY, mywindow
END
