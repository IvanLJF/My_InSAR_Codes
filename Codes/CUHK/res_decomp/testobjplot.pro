
;------------------------------------------------------------------------


PRO TestObjPlot


    ; Check to be sure at least one parameter is present.

np =  N_Params()
CASE np OF
    0: BEGIN
    
    
    
    
;       Print, 'Using fake data in XPLOT...'
;       y = FIndGen(101)
;       y = Sin(y/5) / Exp(y/50)
;       x = IndGen(N_Elements(y))
;       xtitle = 'Time'
;       ytitle = 'Signal Stength'
       
       
       
       
       
       END
    1: BEGIN
       y = xx
       x = IndGen(N_Elements(y))
       END
    ELSE:
ENDCASE

thisWindow = OBJ_NEW('IDLgrWindow', dim=[450, 400])

    ; Check keyword parameters.
position = [0.1, 0.1, 0.95, 0.95]
title = ''
xtitle = ''
ytitle = ''
CASE N_Elements(exact) OF
   0: exact = [0,0]
   1: exact = Replicate(exact, 2)
   2:
   ELSE: BEGIN
      ok = Dialog_Message('Exact keyword contains too many elements. Returning...')
      RETURN
      ENDCASE
ENDCASE

   ; Create title objects for the axes. Color them yellow.

xTitle = Obj_New('IDLgrText', xtitle, Color=[255,255,0])
yTitle = Obj_New('IDLgrText', ytitle, Color=[255,255,0])

    ; Make a font object.

helvetica10pt = Obj_New('IDLgrFont', 'Helvetica', Size=10)

    ; Create a plot object. The plot will be in the coordinate
    ; space 0->1. The view will be in the range -0.35->1.25 so
    ; that the plot axis annotation will be visable. Make the plot
    ; a green color.

thisPlot = Obj_New("IDLgrPLOT", x, y, _Extra=extra, $
   Color=[0,255,0], Thick=2)

    ; Get the data ranges from the Plot Object.

thisPlot->GetProperty, XRange=xrange, YRange=yrange

    ; Create plot box style axes. Make the axes yellow.
    ; The large values in the LOCATION keyword indicates which
    ; values are NOT used. The axes text is set to Helvetica
    ; 10 point font.

xAxis1 = Obj_New("IDLgrAxis", 0, Color=[255,255,0], Ticklen=0.025, $
    Minor=4, Range=xrange, Title=xtitle, $
    Location=[1000, position[1] ,0], Exact=exact[0])
xAxis1->GetProperty, Ticktext=xAxisText
xAxisText->SetProperty, Font=helvetica10pt

xAxis2 = Obj_New("IDLgrAxis", 0, Color=[255,255,0], Ticklen=0.025, $
    Minor=4, /NoText, Range=xrange, TickDir=1, $
    Location=[1000, position[3], 0], Exact=exact[0])

yAxis1 = Obj_New("IDLgrAxis", 1, Color=[255,255,0], Ticklen=0.025, $
    Minor=4, Title=ytitle, Range=yrange, $
    Location=[position[0], 1000, 0], Exact=exact[1])
yAxis1->GetProperty, Ticktext=yAxisText
yAxisText->SetProperty, Font=helvetica10pt

yAxis2 = Obj_New("IDLgrAxis", 1, Color=[255,255,0], Ticklen=0.025, $
    Minor=4, /NoText, Range=yrange, TickDir=1, $
    Location=[position[2], 1000, 0], Exact=exact[1])

    ; Because we may not be using exact axis ranging, the axes
    ; may extend further than the xrange and yrange. Get the
    ; actual axis range so that the plot, etc. can be scaled
    ; appropriately.

xAxis1->GetProperty, CRange=xrange
yAxis1->GetProperty, CRange=yrange

    ; Set up the scaling so that the axes for the plot and the
    ; plot data extends from 0->1 in the X and Y directions.

xs = FSC_Normalize(xrange, Position=[position[0], position[2]])
ys = FSC_Normalize(yrange, Position=[position[1], position[3]])

    ; Scale the plot data and axes into 0->1.

thisPlot->SetProperty, XCoord_Conv=xs, YCoord_Conv=ys
xAxis1->SetProperty, XCoord_Conv=xs
xAxis2->SetProperty, XCoord_Conv=xs
yAxis1->SetProperty, YCoord_Conv=ys
yAxis2->SetProperty, YCoord_Conv=ys


  ; Create a plot title. Center it at a location above the plot.

helvetica14pt = Obj_New('IDLgrFont', 'Helvetica', Size=14)
plotTitle = Obj_New('IDLgrText', title, Color=[255,255,0], $
   Location=[0.55, 0.98, 0.0], Alignment=0.5, Font=helvetica14pt, $
   ENABLE_FORMATTING=1)

    ; Create a plot model and add axes, plot, and plot title to it.

plotModel = Obj_New('IDLgrModel')
plotModel->Add, thisPlot
plotModel->Add, xAxis1
plotModel->Add, xAxis2
plotModel->Add, yAxis1
plotModel->Add, yAxis2
plotModel->Add, plotTitle

    ; Create a view and add the plot model to it. Notice that the view
    ; is larger than the 0->1 plot area to accomodate axis annotation.
    ; The view will have a gray background.

plotView = Obj_New('IDLgrView', Viewplane_Rect=[0.0, 0.0, 1.0, 1.05], $
   Location=[0,0], Color=[80,80,80])
plotView->Add, plotModel



    ; Display the plot in the window.
plotView->SetProperty, Color=[255,255,255]
      thisPlot->SetProperty, Color=[139,69,19]
      xAxis1->SetProperty, Color=[0,100,0]
      yAxis1->SetProperty, Color=[0,100,0]
      xAxis2->SetProperty, Color=[0,100,0]
      yAxis2->SetProperty, Color=[0,100,0]
      plotTitle->SetProperty, Color=[0,0,128]

thisWindow->Draw, plotView

   ; Create a container object to hold all the other
   ; objects. This will make it easy to free all the
   ; objects when we are finished with the program.

thisContainer = Obj_New('IDL_Container')
thisContainer->Add, thisWindow
thisContainer->Add, plotView
thisContainer->Add, helvetica10pt
thisContainer->Add, helvetica14pt
thisContainer->Add, xaxis1
thisContainer->Add, xaxis2
thisContainer->Add, yaxis1
thisContainer->Add, yaxis2
thisContainer->Add, plotTitle
thisContainer->Add, xTitle
thisContainer->Add, yTitle



;thisWindow->GetProperty, Image_Data=snapshot
;
;
;
;      filename = Dialog_Pickfile(/Write, File='xplot.jpg')
;      IF filename NE '' THEN Write_JPEG, filename, snapshot, True=1


END
;------------------------------------------------------------------------


