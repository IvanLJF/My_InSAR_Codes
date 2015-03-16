; Chapter08PlotAxis.pro
FUNCTION NORM_COORD, range
    scale = [-range[0]/(range[1]-range[0]), 1/(range[1]-range[0])]
    RETURN, scale
END
PRO Chapter08PlotAxis, data, VIEW=myview, MODEL=mymodel, $
    WINDOW=mywindow, CONTAINER=mycontainer,  $
    XAXIS=myxaxis, YAXIS=myyaxis, PLOT=myplot, _extra=e
    IF (N_ELEMENTS(data) EQ 0) THEN data = randomu(seed,100)
    mycontainer = OBJ_NEW('IDL_Container')
    mywindow = OBJ_NEW('IDLgrWindow', RETAIN=2)
    myview = OBJ_NEW('IDLgrView')
    mymodel = OBJ_NEW('IDLgrModel')
    myfont = OBJ_NEW('IDLgrFont', 'times')
    myplot = OBJ_NEW('IDLgrPlot', data, COLOR=[200,100,200])
    myplot ->SetProperty, _extra=e
    myplot -> GetProperty, XRANGE=xr, YRANGE=yr
    myplot->SetProperty, XCOORD_CONV=norm_coord(xr), $
                         YCOORD_CONV=norm_coord(yr)
    myxaxis = OBJ_NEW('IDLgrAxis', 0, RANGE=[xr[0], xr[1]])
    myxaxis -> SetProperty, XCOORD_CONV=norm_coord(xr)
    myyaxis = OBJ_NEW('IDLgrAxis', 1, RANGE=[yr[0], yr[1]])
    myyaxis -> SetProperty, YCOORD_CONV=norm_coord(yr)
    myxaxis -> SetProperty, TICKLEN=0.05
    myyaxis -> SetProperty, TICKLEN=0.05
    myview -> Add, mymodel
    mymodel -> Add, myplot
    mymodel -> Add, myxaxis
    mymodel -> Add, myyaxis
    SET_VIEW, myview, mywindow
    xtext = OBJ_NEW('IDLgrText', 'X Title', FONT=myfont)
    myxaxis -> SetProperty, TITLE=xtext
    mycontainer -> Add, mywindow
    mycontainer -> Add, myview
    mycontainer -> Add, myfont
    mycontainer -> Add, xtext
    mywindow -> Draw, myview
    val=''
    READ, val, PROMP='Destroy objects? (y/n) [y]: '
    IF STRPOS(STRUPCASE(val),'N') EQ -1 THEN OBJ_DESTROY,mycontainer
END
