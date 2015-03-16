; Chapter08PatternPloygon.pro
pro Chapter08PatternPloygon
    pattern = BYTE(RANDOMN(seed, 32, 4)*255)
    myPattern = OBJ_NEW('IDLgrPattern', STYLE=2, PATTERN=pattern)
    myView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,0,10,10])
    myModel = OBJ_NEW('IDLgrModel')
    myPolygon = OBJ_NEW('IDLgrPolygon', [4, 7, 3], [8, 6, 3],$
    color=[255,0,255], fill_pattern=myPattern)
    myView -> Add, myModel
    myModel -> Add, myPolygon
    myWindow = OBJ_NEW('IDLgrWindow', RETAIN=2)
    myWindow -> Draw, myView
end