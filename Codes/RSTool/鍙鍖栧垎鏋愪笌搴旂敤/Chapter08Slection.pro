; Chapter08Slection.pro
PRO Chapter08Slection_event, sEvent
   IF (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
                 'WIDGET_KILL_REQUEST') THEN BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      OBJ_DESTROY, sState.oScene
      OBJ_DESTROY, sState.oImage
      WIDGET_CONTROL, sEvent.top, /DESTROY
      RETURN
   ENDIF
   WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
   CASE uval OF
      'DRAW': BEGIN
         WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         CASE sEvent.type OF
            0: BEGIN ; Button Press.
               oViewArr = sState.oWindow->Select(sState.oScene, $
                         [sEvent.x, sEvent.y], DIMENSIONS=[20,20] )
               nSel = N_ELEMENTS(oViewArr)
               IF ((SIZE(oViewArr))[0] NE 0) THEN BEGIN
                  oView = oViewArr[0]
                  oObjArr = sState.oWindow->Select(oView, $
                           [sEvent.x, sEvent.y], DIMENSIONS=[20,20] )
                  nSel = N_ELEMENTS(oObjArr)
                  IF ((SIZE(oObjArr))[0] NE 0) THEN BEGIN
                     FOR i=0, nSel-1 DO BEGIN
                        oObjArr[i]->GetProperty, NAME=name
                        IF (i EQ 0) THEN BEGIN
                           label = 'Current Selections: ' + name
                        ENDIF ELSE BEGIN
                           label = label + ', ' + name
                        ENDELSE
                     ENDFOR
                  ENDIF ELSE BEGIN
                     oView->GetProperty, NAME=name
                     label = 'Current Selections: ' + name
                  ENDELSE
               ENDIF ELSE BEGIN
                  label = 'Current Selections: <None>'
               ENDELSE
               WIDGET_CONTROL, sState.wLabel, SET_VALUE=label
            END
            4: BEGIN ; Exposure.
               sState.oWindow->Draw, sState.oScene
            END
            ELSE: BEGIN
            END
         ENDCASE
         WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
      'SELECT': BEGIN
         WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.oSurfModel->SetProperty, SELECT_TARGET=(1-sEvent.Value)
         sState.oPlotModel->SetProperty, SELECT_TARGET=(1-sEvent.Value)
         WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
   ENDCASE
END
;------------------------------------------------------------------------
PRO Chapter08Slection
   xdim = 600  &  ydim = 300
   wBase = WIDGET_BASE(TITLE='Selection Example', /COLUMN, $
                  /TLB_KILL_REQUEST_EVENTS )
   wDraw = WIDGET_DRAW(wBase,XSIZE=xdim,YSIZE=ydim,GRAPHICS_LEVEL=2, $
         RETAIN=0, /BUTTON_EVENTS, /EXPOSE_EVENTS, UVALUE='DRAW')
   wSelGroup = CW_BGROUP(wBase, ['Model', 'Graphic Atoms'], $
            LABEL_LEFT='Selection Target:', /EXCLUSIVE, /ROW, $
            /NO_RELEASE, SET_VALUE=1, UVALUE='SELECT')
   wLabel = WIDGET_LABEL(wBase, VALUE='Current Selections: <None>', $
            /DYNAMIC_RESIZE)
   WIDGET_CONTROL, wBase, /REALIZE
   WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
   oScene = OBJ_NEW('IDLgrScene')
   aspect = FLOAT(xdim/2) / FLOAT(ydim)
   IF (aspect GT 1.) THEN BEGIN
      vrect = [-aspect, -1, aspect * 2.0, 2.0]
   ENDIF ELSE BEGIN
      vrect = [-1, -1 - (((1./aspect) - 1)/2.), 2, 2.0/aspect]
   ENDELSE
   oView1 = OBJ_NEW('IDLgrView', LOCATION=[0,0], NAME='View 1',  $
                COLOR=[60,60,60],DIMENSIONS=[xdim/2,ydim] )
   oScene->Add, oView1
   oView2 = OBJ_NEW('IDLgrView', LOCATION=[xdim/2,0], NAME='View 2', $
      DIMENSIONS=[xdim/2,ydim], VIEWPLANE_RECT=vrect, COLOR=[0,0,0])
   oScene->Add, oView2
   oPlotModel = OBJ_NEW('IDLgrModel', NAME='Cosine Plot Model')
   oView1->Add, oPlotModel
   xData = FINDGEN(100) / 99.0  &  yData = COS(xData*!PI)
   xMax = MAX(xData, MIN=xMin)  &  yMax = MAX(yData, MIN=yMin)
   xRange = xMax - xMin  &  yRange = yMax - yMin
   xPad = xRange * 0.3   &  yPad = yRange * 0.2
   oView1->SetProperty, VIEWPLANE_RECT = [xMin-xPad, yMin - yPad, $
                          xRange + 2*xPad, yRange + 2*yPad]
   xTickLen = 0.05 * yRange
   oXAxis = OBJ_NEW('IDLgrAxis',0,LOCATION=[xMin,yMin],NAME='X Axis',$
      RANGE=[xMin, xMax], COLOR=[60,200,90],TICKLEN=xTicklen,MAJOR=3)
   oPlotModel->Add, oXAxis
   yTickLen = 0.05 * xRange
   oYAxis = OBJ_NEW('IDLgrAxis',1,LOCATION=[xMin,yMin],NAME='Y Axis',$
          RANGE=[yMin, yMax], COLOR=[60,200,90], TICKLEN=yTicklen )
   oPlotModel->Add, oYAxis
   oPlot = OBJ_NEW('IDLgrPlot', xData, yData, $
                COLOR = [60,200,90], NAME='Plot Line')
   oPlotModel->Add, oPlot
   oSurfModel = OBJ_NEW('IDLgrModel', NAME='DIST Model')
   oSurfModel->Rotate, [1,0,0], -90
   oSurfModel->Rotate, [0,1,0], 30
   oSurfModel->Rotate, [1,0,0], 30
   oView2->Add, oSurfModel
   zData = BESELJ(SHIFT(DIST(20),10,10)/2,0) * 0.8
   xData = (FINDGEN(20) - 10.) / 20.
   yData = xData
   oSurface = OBJ_NEW('IDLgrSurface', zData, xData, yData, $
            COLOR=[255,90,60], STYLE=1, NAME='Surface')
   oSurfModel->Add, oSurface
   oImage = OBJ_NEW('IDLgrImage', BYTSCL(zData), /GREYSCALE)
   xMax = MAX(xData, MIN=xMin)
   yMax = MAX(yData, MIN=yMin)
   zMax = MAX(zData, MIN=zMin)
   zMin = zMin - 0.2
   oPolygon=OBJ_NEW('IDLgrPolygon',[xMin,xMax,xMax,xMin],NAME='Image',$
      [yMin,yMin,yMax,yMax],[zMin,zMin,zMin,zMin],TEXTURE_MAP=oImage, $
      TEXTURE_COORD=[[0,0],[1,0],[1,1],[0,1]],COLOR=[255,255,255] )
   oSurfModel->Add, oPolygon
   oWindow->Draw, oScene
   sState = {wLabel : wLabel, oWindow: oWindow, oScene: oScene, $
      oImage: oImage, oPlotModel: oPlotModel, oSurfModel: oSurfModel }
   WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
   XMANAGER, 'Chapter08Slection', wBase, /NO_BLOCK
END