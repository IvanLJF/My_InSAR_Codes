;- Script that:
;-   Plot time series using IDLgrPlot
;- Input params:
;-
;- Example:
;-   See the main pro.

PRO TLI_PLOT_TS, ptind, def_range, time_int, time_lab, time_s,oGraphPath=oGraphPath

  COMPILE_OPT idl2
  ; This is the main function to plot figures
  x= time_int
  y= time_s
;  max_vel= (ABS(def_v_range))[0]>(ABS(def_v_range))[1]
;  ymin= MIN(x)*max_vel
;  ymax= MAX(x)*max_vel
;  IF ymax LT ymin THEN BEGIN
;    temp= ymax
;    ymax= ymin
;    ymin= temp
;  ENDIF
;  yrange=[(-1)*ymax, ymax]
  yrange= def_range


  ; Check keyword parameters.
  position = [0.1, 0.2, 0.93, 0.93]
  title = 'Time Series (Point Index:'+STRCOMPRESS(ptind)+')'
  xtitle = 'Imaging Time'
  ytitle = 'Deformation (mm)'
  CASE N_Elements(exact) OF
    0: exact = [1,1]
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

  thisPlot->GetProperty, XRange=xrange;, YRange=yrange

  ; Create plot box style axes. Make the axes yellow.
  ; The large values in the LOCATION keyword indicates which
  ; values are NOT used. The axes text is set to Helvetica
  ; 10 point font.

  ; Set tick info.
  xTickno= 6 ; Tick number of x axis.
  IF N_ELEMENTS(time_int) LE xTickno THEN BEGIN
    xTickvalues= time_int
    xTicktext= time_lab
  ENDIF ELSE BEGIN
    xrg= MAX(x)-MIN(x) ; xrange
    xint= xrg/(xTickno-1)      ; x interval
    xtickvf= (xint*DINDGEN(xTickno))+MIN(x) ; x tick value(false)
    xind=0
    FOR i=0, xTickno-1 DO BEGIN
      tempmin= MIN(ABS(time_int- xtickvf[i]), tempind)
      xind= [xind, tempind]
    ENDFOR
    xind= xind[1: *]
    xTickvalues= time_int[xind]
    xTicktext= time_lab[xind]
  ENDELSE
  xTicktxt= time_lab[xind]
  xTICKTEXT= Obj_new("IDLgrText", xTicktxt)

  xAxis1 = Obj_New("IDLgrAxis", 0, Color=[255,255,0], Ticklen=0.025, $
    Minor=4,Range=xrange, Title=xtitle, $
    TickValues= xTickvf, TICKTEXT=xTICKTEXT,   $
    Location=[1000, position[1] ,0], Exact=exact[0])  ; Plot the lowr x axis.
  xAxis1->GetProperty, Ticktext=xAxisText
  xAxisText->SetProperty, Font=helvetica10pt

  xAxis2 = Obj_New("IDLgrAxis", 0, Color=[255,255,0], Ticklen=0.025, $
    Minor=5, /NoText, Range=xrange, TickDir=1, $
    Location=[1000, position[3], 0], Exact=exact[0])  ; Plot the upper x axis.

  yAxis1 = Obj_New("IDLgrAxis", 1, Color=[255,255,0], Ticklen=0.025, $
    Minor=4, major=5, Title=ytitle, Range=yrange, $
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



  winDims = [630, 300]
;  thisWindow = OBJ_NEW('IDLgrWindow', dim=winDims)  IDLgrBuffer
;  thisWindow->Draw, plotView

oBuffer = Obj_New('IDLgrBuffer', dim=winDims)
    oBuffer->Draw, plotView
    oImage = oBuffer->Read()
    oImage->Getproperty, data=data
    ;
    ; 导出JPG
;    writeVGE = 0
;    if ~File_Test(fVGE) then writeVGE = 1
;    if File_Test(fVGE, /Write) then writeVGE = 1
;    if writeVGE eq 1 then begin
;    	VGEData = Bytarr(3, siz[1], siz[0])
;	    VGEData[0, *, *] = Rotate(Reform(data[0,*,*]), 3)
;	    VGEData[1, *, *] = Rotate(Reform(data[1,*,*]), 3)
;	    VGEData[2, *, *] = Rotate(Reform(data[2,*,*]), 3)
;	    WRITE_JPEG, fVGE, Temporary(VGEData), QUALITY=60, /true
;    endif
;	data = Congrid(data, 3, 1024, 512)
	outGraph = oGraphPath + Strtrim(ptind, 2) + '.jpg'
    WRITE_JPEG, outGraph, Temporary(data), QUALITY=40, /true ; 40, only 800K ,quality acceptable








  ; Create a container object to hold all the other
  ; objects. This will make it easy to free all the
  ; objects when we are finished with the program.

  thisContainer = Obj_New('IDL_Container')
;  thisContainer->Add, thisWindow
  thisContainer->Add, plotView
  thisContainer->Add, thisPlot
  thisContainer->Add, helvetica10pt
  thisContainer->Add, helvetica14pt
  thisContainer->Add, xaxis1
  thisContainer->Add, xaxis2
  thisContainer->Add, yaxis1
  thisContainer->Add, yaxis2
  thisContainer->Add, plotTitle
  thisContainer->Add, xTitle
  thisContainer->Add, yTitle
  thisContainer->Add, xTICKTEXT
  thisContainer->Add, plotModel
  thisContainer->Add, oBuffer
  thisContainer->Add, oImage
   Obj_Destroy, thisContainer



;thisWindow->GetProperty, Image_Data=snapshot
;
;
;
;      filename = Dialog_Pickfile(/Write, File='xplot.jpg')
;      IF filename NE '' THEN Write_JPEG, filename, snapshot, True=1

END



PRO TLI_TEST_PLOT

  COMPILE_OPT idl2

  parfile='F:\ExpGroup\def_fin.txt'
  oGraphPath = 'F:\ExpGroup\scr'
  def_v_range= [-10, 5]      ; Range of deformation velocity.
  def_v_range= [-25, 30]      ; Range of deformation velocity.


  ; Jump 3 lines
  nJumps = 3
  temp = strarr(nJumps)
  OPENR, lun, parfile,/GET_LUN
    READF, lun, temp
	strs = StrSplit(temp[0], ':', /extract)
	nPoints = Long(strs[1])
	help, nPoints

  temp=' '
  READF, lun, temp
  temp= STRSPLIT(temp, STRING(9B), /EXTRACT)
  n_int= N_ELEMENTS(temp)-3
  time_int= temp[3:*]/365D  ; time interval
  Print, 'Number of Interferograms:', n_int

  temp=' '
  READF, lun, temp
  temp= STRSPLIT(temp, STRING(9B),/EXTRACT)
  time_lab= temp[3:*]  ; time label
  Print, 'Time labels are:', time_lab
  Print, 'HELP time_label:'
  Help, time_lab
  
  ; Read all data and get def_range
  def_all= DBLARR(n_int+3, npoints-1) ;为什么多了一行空格？
  READF, lun, def_all
  def_all= def_all[3:*, *]
  def_max= MAX(def_all, min=def_min)
  def_range=[def_min, def_max]
  Print, '[Max, Min] of deformation (mm): ['+STRCOMPRESS(def_min)+STRCOMPRESS(def_max)+' ]'
  FREE_LUN, lun
  ; Open the file again
  temp= STRARR(5)
  OPENR, lun, parfile,/GET_LUN
  READF, lun, temp

  ; 读一行, 画一个
  pPerFolder = 10000
  nFolders = Floor(nPoints / pPerFolder)
  for i=0, nFolders do begin
  	 xFolder = oGraphPath + Strtrim(i, 2) + Path_Sep()
  	 if ~File_Test(xFolder, /directory) then File_Mkdir, xFolder
  endfor


  for i=0, 1 do begin;nPoints-1 do begin
  		xFolder = oGraphPath + Strtrim(Floor((i+1) / pPerFolder), 2) + Path_Sep()

	  	ptind=i + 1
	    temp=' '
	    READF, lun, temp
	   temp= STRSPLIT(temp, STRING(9B),/EXTRACT)
	   time_s= temp[3:*] ; time series
;	   Print, 'Time series are:', time_s
;	   Print, 'HELP time_s'
;	   Help, time_S
	  ;----------------------------------------------------------------------------------------
	              ; Point index

	  ; time_int: time intervals
	  ; time_lab: time labels
	  ; time_s  : time series
	   TLI_PLOT_TS, ptind, def_range,time_int, time_lab, time_s,oGraphPath=xFolder
  endfor
  FREE_LUN, lun
END
