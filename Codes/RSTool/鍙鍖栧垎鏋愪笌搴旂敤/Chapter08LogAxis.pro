; Chapter08LogAxis.pro
PRO Chapter08LogAxis
    oWindow = OBJ_NEW('IDLgrWindow',RETAIN=2)
    oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-0.2,-0.2,1.4,1.4])
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel
    yData = FINDGEN(50)*20.
    yMin = MIN(yData, MAX=yMax)
    yRange = yMax - yMin
    xMin = 0
    xMax = N_ELEMENTS(yData)-1
    xRange = xMax - xMin
    oXTitle = OBJ_NEW('IDLgrText', 'Linear X Axis')
    oXAxis = OBJ_NEW('IDLgrAxis', 0, RANGE=[xmin,xmax], $
    TICKLEN=(0.1*yRange), TITLE=oXTitle)
    oModel->Add, oXAxis
    oYTitle = OBJ_NEW('IDLgrText','Linear Y Axis')
    oYAxis = OBJ_NEW('IDLgrAxis', 1, RANGE=[yMin,yMax], $
    TICKLEN=(0.1*xRange), TITLE=oYTitle)
    oModel->Add, oYAxis
    oPlot = OBJ_NEW('IDLgrPlot', yData, COLOR=[255,0,0])
    oModel->Add, oPlot
    oModel->Scale, 1.0/xRange, 1.0/yRange, 1.0
    oModel->Translate, -(xMin/xRange), -(yMin/yRange), 0.0
    oXAxis->GetProperty, TICKTEXT=oXTickText
    oXTitle->SetProperty, RECOMPUTE_DIMENSIONS=2
    oXTickText->SetProperty, RECOMPUTE_DIMENSIONS=2
    oYAxis->GetProperty, TICKTEXT=oYTickText
    oYTickText->SetProperty, RECOMPUTE_DIMENSIONS=2
    oYTitle->SetProperty, RECOMPUTE_DIMENSIONS=2
    oWindow->Draw, oView
    val=''
    READ, val, PROMPT='Press <Return> to draw with a logarithmic Y axis.'
    posElts = WHERE(yData GT 0, nPos)
    IF (nPos GT 0) THEN BEGIN
        yValidData = yData[posElts]
        yValidMin = MIN(yValidData, MAX=yValidMax)
        yLogData = ALOG10(yValidData)
        oPlot->Setproperty, DATAY=yLogData
    ENDIF ELSE BEGIN
        MESSAGE, 'Original plot data is entirely non-positive.',/INFORMATIONAL
        MESSAGE, '  Log plot will contain no data.',/NOPREFIX, /INFORMATIONAL
        yValidMin = 1.0
        yValidMax = 10.0
        oPlot->SetProperty, /HIDE
    ENDELSE
    oYAxis->SetProperty, /LOG, RANGE=[yValidMin, yValidMax]
    oYTitle->SetProperty, STRING='Logarithmic Y Axis'
    oYAxis->GetProperty, CRANGE=crange
    yLogMin = crange[0]
    yLogMax = crange[1]
    yLogRange = yLogMax - yLogMin
    oXAxis->SetProperty, TICKLEN=(0.1*yLogRange), $
                         LOCATION=[0,yLogMin,0]
    oModel->Reset
    oModel->Scale, 1.0/xRange, 1.0/yLogRange, 1.0
    oModel->Translate, -(xMin/xRange), $
                       -(yLogMin/yLogRange), 0.0
    oWindow->Draw, oView
    READ, val, PROMPT='Press <Return> to quit.'
    OBJ_DESTROY, oView
    OBJ_DESTROY, oWindow
    OBJ_DESTROY, oXTitle
    OBJ_DESTROY, oYTitle
END
