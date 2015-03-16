; Chapter08Axis.pro
PRO Chapter08Axis
    data = FINDGEN(100)
    myplot = OBJ_NEW('IDLgrPlot', data)
    xaxis = OBJ_NEW('IDLgrAxis', 0)
    yaxis = OBJ_NEW('IDLgrAxis', 1)
    myplot -> GetProperty, XRANGE=xr, YRANGE=yr
    xaxis -> SetProperty, RANGE=xr
    yaxis -> SetProperty, RANGE=yr
    xtl = 0.02 * (xr[1] - xr[0])
    ytl = 0.02 * (yr[1] - yr[0])
    xaxis -> SetProperty, TICKLEN=xtl
    yaxis -> SetProperty, TICKLEN=ytl
    mymodel = OBJ_NEW('IDLgrModel')
    myview = OBJ_NEW('IDLgrView')
    mywindow = OBJ_NEW('IDLgrWindow', RETAIN=2)
    mymodel -> Add, myplot
    mymodel -> Add, xaxis
    mymodel -> Add, yaxis
    myview -> Add, mymodel
    SET_VIEW, myview, mywindow
    mywindow -> Draw, myview
    val=''
    READ, val, PROMP='Press <Return> to destroy objects.'
    OBJ_DESTROY, mywindow
    OBJ_DESTROY, myview
END
