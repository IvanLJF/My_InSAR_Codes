; Chapter08DateContour.pro
PRO Chapter08DateContour
    number_samples = 37
    date_time = TIMEGEN(number_samples, UNITS = 'Seconds', $
    START = JULDAY(3, 30, 2000, 14, 59, 30))
    angle = 10.*FINDGEN(number_samples)
    temperature = BYTSCL(SIN(10.*!DTOR* $
    FINDGEN(number_samples)) # COS(!DTOR*angle))
    date_label = LABEL_DATE(DATE_FORMAT = $
        ['%I:%S', '%H', '%D %M, %Y'])
    oContourPalette = OBJ_NEW('IDLgrPalette')
    oContourPalette -> LoadCT, 5
    oContourWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
        DIMENSIONS = [760, 500])
    oContourView = OBJ_NEW('IDLgrView', /DOUBLE)
    oContourModel = OBJ_NEW('IDLgrModel')
    oContour = OBJ_NEW('IDLgrContour', temperature, $
        GEOMX = angle, GEOMY = date_time, GEOMZ = 0., $
        /PLANAR, /FILL, PALETTE = oContourPalette, $
        /DOUBLE_GEOM, C_VALUE = BYTSCL(INDGEN(8)), $
    C_COLOR = BYTSCL(INDGEN(8)))
    oContourLines = OBJ_NEW('IDLgrContour', temperature, $
        GEOMX = angle, GEOMY = date_time, GEOMZ = 0.001, $
        /PLANAR, /DOUBLE_GEOM, C_VALUE = BYTSCL(INDGEN(8)))
    oContour -> GetProperty, XRANGE = xr, YRANGE = yr, ZRange = zr
    xs = NORM_COORD(xr)
    xs[0] = xs[0] - 0.5
    ys = NORM_COORD(yr)
    ys[0] = ys[0] - 0.5
    oContour -> SetProperty, XCOORD_CONV = xs, YCOORD_CONV = ys
    oContourLines -> SetProperty, XCOORD_CONV = xs, YCOORD_CONV = ys
    oTextXAxis = OBJ_NEW('IDLgrText', 'Angle (degrees)')
    oContourXAxis = OBJ_NEW('IDLgrAxis', 0, /EXACT, RANGE = xr, $
        XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextXAxis, $
        LOCATION = [xr[0], yr[0], zr[0] + 0.001], TICKDIR = 0, $
        TICKLEN = (0.02*(yr[1] - yr[0])))
    oTextYAxis = OBJ_NEW('IDLgrText', 'Time (seconds)')
    oContourYAxis = OBJ_NEW('IDLgrAxis', 1, /EXACT, RANGE = yr, $
        XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextYAxis, $
        LOCATION = [xr[0], yr[0], zr[0] + 0.001], TICKDIR = 0, $
        TICKLEN = (0.02*(xr[1] - xr[0])), $
        TICKFORMAT = ['LABEL_DATE', 'LABEL_DATE', 'LABEL_DATE'], $
        TICKUNITS = ['Time', 'Hour', 'Day'], TICKLAYOUT = 2)
    oContourText = OBJ_NEW('IDLgrText', $
        'Measured Temperature (degrees Celsius)', $
        LOCATIONS = [(xr[0] + xr[1])/2., $
        (yr[1] + (0.02*(yr[0] + yr[1])))], $
        XCOORD_CONV = xs, YCOORD_CONV = ys, ALIGNMENT = 0.5)
    oContourModel -> Add, oContour
    oContourModel -> Add, oContourLines
    oContourModel -> Add, oContourXAxis
    oContourModel -> Add, oContourYAxis
    oContourModel -> Add, oContourText
    oContourView -> Add, oContourModel
    oContourWindow -> Draw, oContourView
    val = ''
    READ, val, PROMPT='Press <Return> to quit.'
    OBJ_DESTROY, oContourView
    OBJ_DESTROY, oContourWindow
END