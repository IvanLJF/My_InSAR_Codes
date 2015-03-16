; Chapter05ObjectSurface.pro
PRO Chapter05ObjectSurface, VIEW=oView, MODEL=oModel, $
                            SURFACE=oSurface, WINDOW=oWindow
    zData = DIST(60)
    oView = OBJ_NEW('IDLgrView', COLOR=[60,60,60], $
    VIEWPLANE_RECT=[-1,-1,2,2])
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel
    oSurface = OBJ_NEW('IDLgrSurface', zData, color=[255,0,0])
    oModel->Add, oSurface
    oSurface->GetProperty,XRANGE=xrange,YRANGE=yrange,ZRANGE=zrange
    xs = [-0.5, 1/(xrange[1]-xrange[0])]
    ys = [-0.5, 1/(yrange[1]-yrange[0])]
    zs = [-0.5, 1/(zrange[1]-zrange[0])]
    oSurface->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs
    oModel->Rotate,[1,0,0], -90
    oModel->Rotate,[0,1,0], 30
    oModel->Rotate,[1,0,0], 30
    oWindow = OBJ_NEW('IDLgrWindow')
    oWindow->Draw, oView
END