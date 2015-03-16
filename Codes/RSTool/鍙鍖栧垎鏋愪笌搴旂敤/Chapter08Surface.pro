; Chapter08Surface.pro
PRO Chapter08Surface
    zData = DIST(30)
    oView = OBJ_NEW('IDLgrView', color=[60,60,60], VIEWPLANE_RECT=[-1,-1,2,2])
    oModel = OBJ_NEW('IDLgrModel' )
    oView->Add, oModel
    oSurface = OBJ_NEW('IDLgrSurface', zData, color=[255,0,0])
    oModel->Add, oSurface
    oSurface->GetProperty,XRANGE=xrange,YRANGE=yrange,ZRANGE=zrange
    xs = [-0.5, 1/(xrange[1]-xrange[0])]
    ys = [-0.5, 1/(yrange[1]-yrange[0])]
    zs = [-0.5, 1/(zrange[1]-zrange[0])]
    oSurface->SetProperty,XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs
    oModel->Rotate,[1,0,0], -90
    oModel->Rotate,[0,1,0], 30
    oModel->Rotate,[1,0,0], 30
    oWindow = OBJ_NEW('IDLgrWindow',RETAIN=2)
    oWindow->Draw, oView
    variable=''
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=1, COLOR=[0,0,255]
    oWindow->Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=2, COLOR=[0,255,0]
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=3, COLOR=[255,0,0]
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=4, COLOR=[0,255,0]
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=5, COLOR=[0,0,255]
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=6, COLOR=[0,255,0]
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    vcolors =[[0,100,200],[200,150,200],[150,200,250],[250,0,100]]
    oSurface -> SetProperty, STYLE=1, VERT_COLORS=vcolors
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=2, SHADING=1
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, STYLE=1, /SHOW_SKIRT, SKIRT=0.1
    oWindow -> Draw, oView
    READ, variable, PROMPT='press Enter to draw next!'
    oSurface -> SetProperty, /HIDDEN_LINES
    oWindow -> Draw, oView
    READ, variable, PROMP='Destroy objects? (y/n) [y]: '
    IF STRPOS(STRUPCASE(variable),'N') EQ -1 THEN BEGIN
       OBJ_DESTROY, oView
       OBJ_DESTROY, oWindow
    ENDIF
END
