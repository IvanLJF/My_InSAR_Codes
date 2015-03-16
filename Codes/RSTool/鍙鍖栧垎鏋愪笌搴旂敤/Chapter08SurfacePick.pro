; Chapter08SurfacePick.pro
PRO Chapter08SurfacePick_EVENT, sEvent
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
  IF TAG_NAMES(sEvent,/STRUCTURE_NAME) EQ $
                      'WIDGET_KILL_REQUEST' THEN BEGIN
  WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
  OBJ_DESTROY, sState.oView
  WIDGET_CONTROL, sEvent.top, /DESTROY
  RETURN
  ENDIF
  CASE uval OF
    'DRAW': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      IF (sEvent.type EQ 4) THEN BEGIN
          sState.oWindow->Draw, sState.oView
          WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          RETURN
      ENDIF
      IF (sEvent.type EQ 0) THEN BEGIN
          IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
              pick = sState.oWindow->PickData(sState.oView,$
                 sState.oSurface, [sEvent.x,sEvent.y],dataxyz)
              IF (pick EQ 1) THEN BEGIN
                str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
                FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
                WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
              ENDIF ELSE BEGIN
                WIDGET_CONTROL, sState.wLabel, $
                    SET_VALUE="Data point: In background."
              ENDELSE
              sState.btndown = 4b
              WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
          ENDIF ELSE BEGIN ; other mouse button.
              sState.btndown = 1b
              WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
              sState.oWindow->Draw, sState.oView
          ENDELSE
      ENDIF
      IF (sEvent.type EQ 2) THEN BEGIN
          IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
              pick = sState.oWindow->PickData(sState.oView, $
                 sState.oSurface, [sEvent.x,sEvent.y], dataxyz)
              IF (pick EQ 1) THEN BEGIN
                str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
                FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
                WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
              ENDIF ELSE BEGIN
                WIDGET_CONTROL, sState.wLabel, $
                  SET_VALUE="Data point: In background."
              ENDELSE
          ENDIF
      ENDIF
      IF (sEvent.type EQ 1) THEN BEGIN
          sState.btndown = 0b
          WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
      ENDIF
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
  ENDCASE
END
PRO Chapter08SurfacePick
  xdim = 600  &  ydim = 360
  zData=BESELJ(SHIFT(DIST(40),20,20)/2,0)
  zMax = MAX(zData, MIN=zMin)
  wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
          TITLE='Surface Pick Example', /TLB_KILL_REQUEST_EVENTS)
  wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
          RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, GRAPHICS_LEVEL=2)
  wGuiBase1 = WIDGET_BASE(wBase, /COLUMN)
  tLabel = WIDGET_LABEL(wGuiBase1, /FRAME, XSIZE=590, $
           VALUE="Right Mouse: Data Picking", /ALIGN_CENTER)
  wLabel = WIDGET_LABEL(wGuiBase1,VALUE="", /ALIGN_CENTER, XSIZE=590)
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
  aspect = FLOAT(xdim) / FLOAT(ydim)
  sqrt2 = SQRT(2.0)
  myview = [ -sqrt2*0.5, -sqrt2*0.5, sqrt2, sqrt2 ]
  IF (aspect GT 1) THEN BEGIN
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
  ENDIF ELSE BEGIN
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
  ENDELSE
  oView = OBJ_NEW('IDLgrView', PROJECTION=2, EYE=3, ZCLIP=[1.4,-1.4],$
          VIEWPLANE_RECT=myview, COLOR=[40,40,40])
  oTop = OBJ_NEW('IDLgrModel')
  oGroup = OBJ_NEW('IDLgrModel')
  oTop->Add, oGroup
  sz = SIZE(zData)
  xMax=sz[1]-1  &  yMax=sz[2]-1  &  zMin2=zMin-1 & zMax2 = zMax + 1
  xs = [-0.5,1.0/xMax] & ys = [-0.5,1.0/yMax]
  zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]
  oSurface = OBJ_NEW('IDLgrSurface', zData, STYLE=2, SHADING=1, $
             COLOR=[60,60,255], BOTTOM=[64,192,128], $
             XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
  oGroup->Add, oSurface
  oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1)
  oTop->Add, oLight
  oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
  oTop->Add, oLight
  oView->Add, oTop
  oGroup->Rotate, [1,0,0], -90
  oGroup->Rotate, [0,1,0], 30
  oGroup->Rotate, [1,0,0], 30
  sState = {btndown: 0b, wDraw: wDraw, wLabel: wLabel,  $
        oWindow: oWindow, oView: oView,    $
        oGroup: oGroup, oSurface: oSurface }
  WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
  XMANAGER, 'Chapter08SurfacePick', wBase, /NO_BLOCK
END
