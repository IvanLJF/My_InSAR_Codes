; Chapter08Light.pro
PRO Chapter08Light
    zdata = DIST(40)
    mywindow = OBJ_NEW('IDLgrWindow',RETAIN=2)
    myview = OBJ_NEW('IDLgrView')
    mymodel = OBJ_NEW('IDLgrMODEL')
    mysurf = OBJ_NEW('IDLgrSurface', zdata, STYLE=2)
    myview -> Add, mymodel
    mymodel -> Add, mysurf
    mysurf -> GetProperty, XRANGE=xr, YRANGE=yr, ZRANGE=zr
    xnorm = [-xr[0]/(xr[1]-xr[0]), 1/(xr[1]-xr[0])]
    ynorm = [-yr[0]/(yr[1]-yr[0]), 1/(yr[1]-yr[0])]
    znorm = [-zr[0]/(zr[1]-zr[0]), 1/(zr[1]-zr[0])]
    mysurf -> SETPROPERTY, XCOORD_CONV=xnorm, $
        YCOORD_CONV=ynorm, ZCOORD_CONV=znorm
    mymodel ->Rotate, [1,0,0], -90
    mymodel ->Rotate, [0,1,0], 30
    mymodel ->Rotate, [1,0,0], 30
    SET_VIEW, myview, mywindow
    mywindow -> Draw, myview
    variable=''
    READ, variable, PROMPT='press Enter to draw next!'
    mylight = OBJ_NEW('IDLgrLight', TYPE=1, LOCATION=[0,0,1])
    mymodel -> Add, mylight
    mywindow -> Draw, myview
    READ, variable, PROMPT='press Enter to draw next!'
    mylight -> SetProperty, COLOR=[255,0,255]
    mywindow -> Draw, myview
    READ, variable, PROMPT='press Enter to draw next!'
    mylight -> SetProperty, INTENSITY=0.7
    mywindow -> Draw, myview
    READ, variable, PROMP='Destroy objects? (y/n) [y]: '
    IF STRPOS(STRUPCASE(variable),'N') EQ -1 THEN BEGIN
       OBJ_DESTROY, myview
       OBJ_DESTROY, mywindow
    ENDIF
END