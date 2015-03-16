; Chapter08DateAxis.pro
PRO Chapter08DateAxis
    number_samples = 37
    date_time = TIMEGEN(number_samples, UNITS = 'Seconds', $
    START = JULDAY(3, 30, 2000, 14, 59, 30))
    displacement = SIN(10.*!DTOR*FINDGEN(number_samples))
    date_label = LABEL_DATE(DATE_FORMAT = ['%I:%S'])
    oPlotWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
    DIMENSIONS = [500, 360])
    oPlotView = OBJ_NEW('IDLgrView', /DOUBLE)
    oPlotModel = OBJ_NEW('IDLgrModel')
    oPlot = OBJ_NEW('IDLgrPlot', date_time, displacement, /DOUBLE)
    oPlot -> GetProperty, XRANGE = xr, YRANGE = yr
    xs = NORM_COORD(xr)
    xs[0] = xs[0] - 0.5
    ys = NORM_COORD(yr)
    ys[0] = ys[0] - 0.5
    oPlot -> SetProperty, XCOORD_CONV = xs, YCOORD_CONV = ys
    oTextXAxis = OBJ_NEW('IDLgrText', 'Time (seconds)')
    oPlotXAxis = OBJ_NEW('IDLgrAxis', 0, /EXACT, RANGE = xr, $
    XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextXAxis, $
    LOCATION = [xr[0], yr[0]], TICKDIR = 0, $
    TICKLEN = (0.02*(yr[1] - yr[0])), $
    TICKFORMAT = ['LABEL_DATE'], TICKINTERVAL = 5, $
    TICKUNITS = ['Time'])
    oTextYAxis = OBJ_NEW('IDLgrText', 'Displacement (inches)')
    oPlotYAxis = OBJ_NEW('IDLgrAxis', 1, /EXACT, RANGE = yr, $
    XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextYAxis, $
    LOCATION = [xr[0], yr[0]], TICKDIR = 0, $
    TICKLEN = (0.02*(xr[1] - xr[0])))
    oPlotText = OBJ_NEW('IDLgrText', 'Measured Signal', $
    LOCATIONS = [(xr[0] + xr[1])/2.,(yr[1]+(0.02*(yr[0]+yr[1])))], $
    XCOORD_CONV = xs, YCOORD_CONV = ys, $
    ALIGNMENT = 0.5)
    oPlotModel -> Add, oPlot
    oPlotModel -> Add, oPlotXAxis
    oPlotModel -> Add, oPlotYAxis
    oPlotModel -> Add, oPlotText
    oPlotView -> Add, oPlotModel
    oPlotWindow -> Draw, oPlotView
    val=''
    READ, val, PROMPT='Press <Return> to draw next one.'
    date_label = LABEL_DATE(DATE_FORMAT=['%I:%S','%H','%D %M,%Y'])
    oPlotXAxis -> SetProperty, $
    TICKFORMAT = ['LABEL_DATE', 'LABEL_DATE', 'LABEL_DATE'], $
    TICKUNITS = ['Time', 'Hour', 'Day']
    oPlotWindow -> Draw, oPlotView
    READ, val, PROMPT='Press <Return> to quit.'
    OBJ_DESTROY, oPlotView
    OBJ_DESTROY, oTextXAxis
    OBJ_DESTROY, oTextYAxis
    OBJ_DESTROY, oPlotWindow
END
