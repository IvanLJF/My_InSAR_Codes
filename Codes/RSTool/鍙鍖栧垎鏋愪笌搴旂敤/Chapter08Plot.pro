; Chapter08Plot.pro
PRO Chapter08Plot
    Mywindow = OBJ_NEW('IDLgrWindow',RETAIN=2)
    MySymbol = OBJ_NEW('IDLgrSymbol', 5, SIZE=[.3,.3])
    Myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-10,-10,20,20])
    Mymodel = OBJ_NEW('IDLgrModel')
    x = (FINDGEN(21) / 10.0 - 1.0) * 10.0
    y = [3.0, -2.0, 0.5, 4.5, 3.0, 9.5, 9.0, 4.0, 1.0, -8.0, $
         -6.5, -7.0, -2.0, 5.0, -1.0, -2.0, -6.0, 3.0, 5.5, 2.5, -3.0]
    Myplot1 = OBJ_NEW('IDLgrPlot', x, y, COLOR=[120, 120, 120])
    Myplot2 = OBJ_NEW('IDLgrPlot', x, y, /HISTOGRAM, LINESTYLE=4)
    y2 = SMOOTH(y, 5)
    Myplot3 = OBJ_NEW('IDLgrPlot', x, y2, LINESTYLE=2)
    Myview -> Add, Mymodel
    Mymodel -> Add, Myplot1
    Mymodel -> Add, Myplot2
    Mymodel -> Add, Myplot3
    myplot1 -> SetProperty, SYMBOL=mySymbol
    Mywindow -> Draw, Myview
END