; Chapter08Legend.pro
PRO Chapter08Legend
    mywindow = OBJ_NEW('IDLgrWindow', RETAIN=2)
    myview = OBJ_NEW('IDLgrView')
    mymodel = OBJ_NEW('IDLgrModel')
    myview -> Add, mymodel
    itemNameArr = ['Original Data', 'Histogram Plot', $
        'Boxcar-filtered (Width=5)']
    mytitle = OBJ_NEW('IDLgrText', 'Plot Legend')
    mysymbol = OBJ_NEW('IDLgrSymbol', 5, SIZE=[0.3, 0.3])
    myLegend = OBJ_NEW('IDLgrLegend', itemNameArr, TITLE=mytitle, $
        BORDER_GAP=0.8, GAP=0.5, $
        ITEM_TYPE=[0,1], ITEM_LINESTYLE=[0,4,2], $
        ITEM_OBJECT=[mysymbol, OBJ_NEW(), OBJ_NEW()], $
        GLYPH_WIDTH=2.0, /SHOW_OUTLINE)
    mymodel -> Add, mylegend
    dims = mylegend->ComputeDimensions(mywindow)
    mymodel->Translate, -(dims[0]/2.), -(dims[1]/2.), 0
    mywindow->Draw, myview
END