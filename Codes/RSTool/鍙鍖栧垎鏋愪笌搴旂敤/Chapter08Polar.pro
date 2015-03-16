; Chapter08Polar.pro
PRO Chapter08Polar
    mywindow = OBJ_NEW('IDLgrWindow', RETAIN = 2)
    myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-100,-100,200,200])
    mymodel = OBJ_NEW('IDLgrModel')
    r = FINDGEN(100)
    theta = r/5
    mypolarplot = OBJ_NEW('IDLgrPlot', r, theta, /POLAR)
    myview -> Add, mymodel
    mymodel -> Add, mypolarplot
    mywindow -> Draw, myview
END