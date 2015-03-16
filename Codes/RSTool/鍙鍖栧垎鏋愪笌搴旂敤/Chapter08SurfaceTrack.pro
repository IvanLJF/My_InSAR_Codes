; Chapter08SurfaceTrack.pro
PRO Chapter08SurfaceTrack_EVENT, sEvent
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
  IF TAG_NAMES(sEvent,/STRUCTURE_NAME) EQ $
                      'WIDGET_KILL_REQUEST' THEN BEGIN
  WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
  OBJ_DESTROY, sState.oView  &  OBJ_DESTROY, sState.oTrack
  WIDGET_CONTROL, sEvent.top, /DESTROY
  RETURN
  ENDIF
  CASE uval OF
    'DRAW': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      IF (sEvent.type EQ 4) THEN BEGIN
        PRINT, 'sEvent.type eq 4'
        sState.oWindow->Draw, sState.oView
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        RETURN
      ENDIF
      bHaveTransform = sState.oTrack->Update(sEvent, TRANSFORM=qmat)
      IF (bHaveTransform NE 0) THEN BEGIN
        sState.oGroup->GetProperty, TRANSFORM=t
        sState.oGroup->SetProperty, TRANSFORM=t#qmat
        sState.oWindow->Draw, sState.oView
      ENDIF
      IF (sEvent.type EQ 0) THEN BEGIN
          WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
          PRINT, 'sEvent.type eq 0'
      ENDIF
      IF (sEvent.type EQ 1) THEN BEGIN
          WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
          PRINT, 'sEvent.type eq 1'
      ENDIF
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
  ENDCASE
END
PRO Chapter08SurfaceTrack, zData
  xdim = 600  &  ydim = 360
  IF N_ELEMENTS(zData) EQ 0 THEN zData=BESELJ(SHIFT(DIST(40),20,20)/2,0)
  zMax = MAX(zData, MIN=zMin)
  zQuart = (zMax - zMin) * 0.25
  zSkirts = [zMin-zQuart, zMin, zMin+zQuart]
  wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
          TITLE="Surface Trackball Example", /TLB_KILL_REQUEST_EVENTS)
  wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
          RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, GRAPHICS_LEVEL=2)
  wGuiBase1 = WIDGET_BASE(wBase, /COLUMN)
  tLabel = WIDGET_LABEL(wGuiBase1, /FRAME, XSIZE=590, /ALIGN_CENTER, $
           VALUE="Left Mouse: Trackball" )
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
  oTrack = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)
  sState = {btndown: 0b, oTrack:oTrack, wDraw: wDraw, oWindow: oWindow,$
            oView: oView, oGroup: oGroup, oSurface: oSurface }
  WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
  XMANAGER, 'Chapter08SurfaceTrack', wBase, /NO_BLOCK
END
