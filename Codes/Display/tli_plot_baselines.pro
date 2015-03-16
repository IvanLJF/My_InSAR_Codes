;-
;- Plot the baselines
;-
;- Input parameters
;-   baselistfile  : GAMMA base.list file. It is produced using base_calc
;-
;- Input keywords
;-   outputfile    : The output image file. Ommitted: baselistfile+'.jpg'
;-   tbaseline     : Set this keyword to 1 to plot temporal baselines instead of acquisition dates.
;-
;- Output:
;-   outputfile
;-
;- Example:
;-   baselistfile='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/base.list'
;-   outputfile=baselistfile+'.jpg'
;-   tbaseline=0
;-   TLI_PLOT_BASELINES, baselistfile, ouputfile=outputfile, tbaseline=tbaseline
;-
;- Written by:
;-   T.LI @ ISEIS, 20131125
;-
PRO TLI_PLOT_BASELINES, baselistfile, outputfile=outputfile, tbaseline=tbaseline

  IF NOT FILE_TEST(baselistfile) THEN Message, 'Error: TLI_PLOT_BASELINES, inputfile does not exist.'
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=baselistfile+'.jpg'
  
  workpath=FILE_DIRNAME(baselistfile)+PATH_SEP()
  
  baseinfo=TLI_READTXT(baselistfile,/easy)
  ; Check the data
  sz=SIZE(baseinfo,/DIMENSIONS)
  IF sz[0] NE 5 THEN Message, 'ERROR: TLI_PLOT_BASELINES, input file error, plase use the GAMMA base.list file.'+$
    '     Please refer to base_calc'
    
  mdate=LONG(baseinfo[1,*])
  sdate=LONG(baseinfo[2,*])
  bp=baseinfo[3, *]
  bt=baseinfo[4,*]
  x=bt ; x are the temporal baselines.
  IF NOT KEYWORD_SET(tbaseline) THEN BEGIN  ; Set x axis to be the acqusition dates.
    slavejul=TLI_DATE2JULDAY(sdate)
    dummy=LABEL_DATE(date_format='%M. %Y')
    x=slavejul
  ENDIF
  y= bp
  
  ; Decide the window size.
  sz=GET_SCREEN_SIZE()
  sz=sz[0]<sz[1]
  sz=sz*0.85
  thisWindow = OBJ_NEW('IDLgrWindow', dim=[sz, sz])
  
  ; Check the keywords.
  position = [0.15, 0.2, 0.93, 0.93]
  
  ; Make font objects.  
  helvetica15pt = Obj_New('IDLgrFont', 'Helvetica', Size=15) ; Font of the image title.
  helvetica14pt=Obj_New('IDLgrFont', 'Helvetica', Size=14) ; Font of the axis title
  
  ; Create title objects for the axes. Color them yellow.
  title = 'Baselines (Master Date: '+STRMID(STRCOMPRESS(mdate[0]),1,8)+')'
  xtitle = 'Acquisition Date'
  ytitle = 'Perpendicular Baseline (m)'  
  IF KEYWORD_SET(tbaseline) THEN BEGIN
    xtitle= 'Temporal Baseline (d)'
  ENDIF  
  xTitle = Obj_New('IDLgrText', xtitle, Color=[255,255,0])
  yTitle = Obj_New('IDLgrText', ytitle, Color=[255,255,0])
  xTitle->SetProperty, Font=helvetica14pt
  yTitle->SetProperty, Font=helvetica14pt
    
  CASE N_Elements(exact) OF
    0: exact = [1,1]
    1: exact = Replicate(exact, 2)
    2:
    ELSE: BEGIN
      ok = Dialog_Message('Keyword contains too many elements. Returning...')
      RETURN
    ENDCASE
  ENDCASE
  
  
  
  
  
  ; Create a plot object. The plot will be in the coordinate
  ; space 0->1. The view will be in the range -0.35->1.25 so
  ; that the plot axis annotation will be visable. Make the plot
  ; a green color.
  
  ; Create connectivity
  mind= WHERE(bt EQ 0, COMPLEMENT=sind)
  IF N_ELEMENTS(mind) NE 1 THEN Message, 'There should be only 1 master image.'
  connectivity=LONARR(3)
  FOR i=0, N_ELEMENTS(sind)-1 DO BEGIN
    connectivity= [connectivity, 2, mind, sind[i]]
  ENDFOR
  connectivity= connectivity[3:*]
  
  ; Another way to plot
  IF 0 THEN BEGIN
    connectivity=LONARR(3)
    startx=bt[sind]
    endx=LONARR(N_ELEMENTS(sind))
    starty= bp[sind]
    endy= bp[sind]
    ; Create connectivity
    FOR i=0, N_ELEMENTS(sind)-1 DO BEGIN
      thiscon= [2, 2*i, 2*i+N_ELEMENTS(sind)]
      connectivity= [connectivity, thiscon]
    ENDFOR
    connectivity= connectivity[3:*]
    x= [startx, endx]
    y= [starty, endy]
  ENDIF
  
  
  thisPlot = Obj_New("IDLgrPolyline", x, y,POLYLINES=connectivity,  _Extra=extra, $
    Color=[0,255,0], Thick=1.55)
    
  ; Get the data ranges from the Plot Object.
    
  thisPlot->GetProperty, XRange=xrange, YRange=yrange
  
  ; Enlarge the range by +-enl%
  enl=5
  xenl= (xrange[1]-xrange[0])*enl/100D
  xrange= [xrange[0]-xenl, xrange[1]+xenl]
  yenl= (yrange[1]-yrange[0])*enl/100D
  yrange= [yrange[0]-yenl, yrange[1]+yenl]
  
  ; Create plot box style axes. Make the axes yellow.
  ; The large values in the LOCATION keyword indicates which
  ; values are NOT used. The axes text is set to Helvetica
  ; 10 point font.
  
  IF KEYWORD_SET(tbaseline) THEN BEGIN
    xAxis1 = Obj_New("IDLgrAxis", 0, Color=[0,0,0], Ticklen=0.025, $
      Minor=4, Major=7,Range=xrange, Title=xtitle, $
      Location=[1000, position[1] ,0], Exact=exact[0])  ; Plot the lowr x axis.
  ENDIF ELSE BEGIN
    xAxis1 = Obj_New("IDLgrAxis", 0, Color=[0,0,0], Ticklen=0.025, $
      Minor=4, Major=7,Range=xrange, Title=xtitle, tickformat="label_date", $
      Location=[1000, position[1] ,0], Exact=exact[0])  ; Plot the lowr x axis.
  ENDELSE
  
  xAxis1->GetProperty, Ticktext=xAxisText
  xAxisText->SetProperty, Font=helvetica14pt
  
  xAxis2 = Obj_New("IDLgrAxis", 0, Color=[0,0,0], Ticklen=0.025, $
    Minor=5, /NoText, Range=xrange, TickDir=1, $
    Location=[1000, position[3], 0], Exact=exact[0])  ; Plot the upper x axis.
    
  yAxis1 = Obj_New("IDLgrAxis", 1, Color=[0,0,0], Ticklen=0.025, $
    Minor=4, Major=6, Title=ytitle, Range=yrange, $
    Location=[position[0], 1000, 0], Exact=exact[1])
  yAxis1->GetProperty, Ticktext=yAxisText
  yAxisText->SetProperty, Font=helvetica14pt
  
  yAxis2 = Obj_New("IDLgrAxis", 1, Color=[0,0,0], Ticklen=0.025, $
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
  
  
  ; Create a plot title. Plot it at a center location above the plot.
  
  helvetica14pt = Obj_New('IDLgrFont', 'Helvetica', Size=18)
  ;  plotTitle = Obj_New('IDLgrText', title, Color=[0,0,0], $
  ;    Location=[0.55, 0.98, 0.0], Alignment=0.5, Font=helvetica14pt, $
  ;    ENABLE_FORMATTING=1)
  plotTitle = Obj_New('IDLgrText', title, Color=[0,0,0], $
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
  thisPlot->SetProperty, Color=[0,0,0]
  xAxis1->SetProperty, Color=[0,0,0]
  yAxis1->SetProperty, Color=[0,0,0]
  xAxis2->SetProperty, Color=[0,0,0]
  yAxis2->SetProperty, Color=[0,0,0]
  plotTitle->SetProperty, Color=[0,0,0]
  
  ;  thisWindow->Draw, plotView
  thiswindow->SETPROPERTY, graphics_tree=plotView
  thisWindow->Show, 0
  thisWindow->DRAW
  
  oPrint=thisWindow->READ()
  oPrint->GETPROPERTY, data=data
  
  ; Suffix
  suffix=TLI_GAMMA_FNAME(outputfile, /suffix)
  suffix=STRUPCASE(suffix)
  IF suffix EQ 'JPG' THEN suffix='JPEG'
  ; Write_BMP, Write_Tiff, Write_image(Support bmp gif jpeg png rpm srf tiff)
  IF (STRPOS('BMP GIF JPEG PNG RPM SRF TIFF', suffix))[0] EQ -1 THEN $
    Message, 'Error: TLI_PLOT_BASELINES, output format not supported.'
  WRITE_IMAGE, outputfile, suffix,data
  
  ; Create a container object to hold all the other
  ; objects. This will make it easy to free all the
  ; objects when we are finished with the program.
  
  thisContainer = Obj_New('IDL_Container')
  thisContainer->Add, thisWindow
  thisContainer->Add, plotView
  thisContainer->Add, helvetica14pt
  thisContainer->Add, helvetica15pt
  thisContainer->Add, xaxis1
  thisContainer->Add, xaxis2
  thisContainer->Add, yaxis1
  thisContainer->Add, yaxis2
  thisContainer->Add, plotTitle
  thisContainer->Add, xTitle
  thisContainer->Add, yTitle
  Obj_Destroy, thisContainer
  
  Result=DIALOG_MESSAGE('The file was written into:'+STRING(13b)+STRING(13b)+outputfile,/INFORMATION,/CENTER)
END